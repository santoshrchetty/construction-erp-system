'use server'

import { revalidatePath } from 'next/cache'
import { repositories } from '@/lib/repositories'
import { z } from 'zod'

const IssueStockSchema = z.object({
  store_id: z.string().uuid(),
  stock_item_id: z.string().uuid(),
  quantity: z.number().positive(),
  reference_number: z.string().min(1),
  reference_type: z.string().min(1),
  reference_id: z.string().uuid().optional(),
  movement_date: z.string().date(),
  created_by: z.string().uuid(),
  notes: z.string().optional(),
})

const TransferStockSchema = z.object({
  from_store_id: z.string().uuid(),
  to_store_id: z.string().uuid(),
  stock_item_id: z.string().uuid(),
  quantity: z.number().positive(),
  reference_number: z.string().min(1),
  created_by: z.string().uuid(),
  notes: z.string().optional(),
})

export async function issueStockFIFO(formData: FormData) {
  try {
    const data = {
      store_id: formData.get('store_id') as string,
      stock_item_id: formData.get('stock_item_id') as string,
      quantity: parseFloat(formData.get('quantity') as string),
      reference_number: formData.get('reference_number') as string,
      reference_type: formData.get('reference_type') as string,
      reference_id: formData.get('reference_id') as string || undefined,
      movement_date: formData.get('movement_date') as string,
      created_by: formData.get('created_by') as string,
      notes: formData.get('notes') as string || undefined,
    }

    const validatedData = IssueStockSchema.parse(data)

    // Check available stock
    const currentStock = await repositories.stockBalances.getCurrentStock(
      validatedData.store_id, 
      validatedData.stock_item_id
    )

    if (currentStock < validatedData.quantity) {
      return { 
        success: false, 
        error: `Insufficient stock. Available: ${currentStock}, Requested: ${validatedData.quantity}` 
      }
    }

    // Create FIFO stock movement using stored procedure
    const { data: result, error } = await repositories.supabase
      .rpc('create_stock_movement_with_fifo', {
        p_store_id: validatedData.store_id,
        p_stock_item_id: validatedData.stock_item_id,
        p_movement_type: 'issue',
        p_reference_number: validatedData.reference_number,
        p_reference_type: validatedData.reference_type,
        p_reference_id: validatedData.reference_id,
        p_quantity: validatedData.quantity,
        p_unit_cost: 0, // Will be calculated by FIFO
        p_movement_date: validatedData.movement_date,
        p_created_by: validatedData.created_by,
        p_notes: validatedData.notes
      })

    if (error) throw error

    revalidatePath('/stock-movements')
    revalidatePath('/stock-balances')
    
    return { success: true, data: { movement_id: result } }
  } catch (error) {
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Failed to issue stock' 
    }
  }
}

export async function transferStockBetweenSites(formData: FormData) {
  try {
    const data = {
      from_store_id: formData.get('from_store_id') as string,
      to_store_id: formData.get('to_store_id') as string,
      stock_item_id: formData.get('stock_item_id') as string,
      quantity: parseFloat(formData.get('quantity') as string),
      reference_number: formData.get('reference_number') as string,
      created_by: formData.get('created_by') as string,
      notes: formData.get('notes') as string || undefined,
    }

    const validatedData = TransferStockSchema.parse(data)

    // Check available stock in source store
    const currentStock = await repositories.stockBalances.getCurrentStock(
      validatedData.from_store_id, 
      validatedData.stock_item_id
    )

    if (currentStock < validatedData.quantity) {
      return { 
        success: false, 
        error: `Insufficient stock in source store. Available: ${currentStock}` 
      }
    }

    const today = new Date().toISOString().split('T')[0]

    // Issue from source store (FIFO)
    const issueResult = await repositories.supabase
      .rpc('create_stock_movement_with_fifo', {
        p_store_id: validatedData.from_store_id,
        p_stock_item_id: validatedData.stock_item_id,
        p_movement_type: 'issue',
        p_reference_number: validatedData.reference_number,
        p_reference_type: 'TRANSFER_OUT',
        p_reference_id: null,
        p_quantity: validatedData.quantity,
        p_unit_cost: 0,
        p_movement_date: today,
        p_created_by: validatedData.created_by,
        p_notes: `Transfer to store: ${validatedData.to_store_id}`
      })

    if (issueResult.error) throw issueResult.error

    // Get FIFO cost for receipt
    const { data: fifoLayers, error: fifoError } = await repositories.supabase
      .rpc('process_fifo_issue', {
        p_store_id: validatedData.from_store_id,
        p_stock_item_id: validatedData.stock_item_id,
        p_issue_quantity: validatedData.quantity
      })

    if (fifoError) throw fifoError

    const avgCost = fifoLayers?.reduce((sum: number, layer: any) => 
      sum + (layer.quantity_used * layer.unit_cost), 0) / validatedData.quantity || 0

    // Receipt to destination store
    const receiptResult = await repositories.supabase
      .rpc('create_stock_movement_with_fifo', {
        p_store_id: validatedData.to_store_id,
        p_stock_item_id: validatedData.stock_item_id,
        p_movement_type: 'receipt',
        p_reference_number: validatedData.reference_number,
        p_reference_type: 'TRANSFER_IN',
        p_reference_id: null,
        p_quantity: validatedData.quantity,
        p_unit_cost: avgCost,
        p_movement_date: today,
        p_created_by: validatedData.created_by,
        p_notes: `Transfer from store: ${validatedData.from_store_id}`
      })

    if (receiptResult.error) throw receiptResult.error

    revalidatePath('/stock-movements')
    revalidatePath('/stock-balances')
    
    return { 
      success: true, 
      data: { 
        issue_movement_id: issueResult.data,
        receipt_movement_id: receiptResult.data
      } 
    }
  } catch (error) {
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Failed to transfer stock' 
    }
  }
}

export async function getStoresByProject(projectId: string) {
  try {
    const { data, error } = await repositories.supabase
      .from('stores')
      .select('*, projects(site_code, site_name)')
      .eq('project_id', projectId)
      .eq('is_active', true)
      .order('site_code')

    if (error) throw error

    return { success: true, data }
  } catch (error) {
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Failed to fetch stores' 
    }
  }
}

export async function getStoresBySite(projectId: string, siteCode: string) {
  try {
    const { data, error } = await repositories.supabase
      .from('stores')
      .select('*')
      .eq('project_id', projectId)
      .eq('site_code', siteCode)
      .eq('is_active', true)

    if (error) throw error

    return { success: true, data }
  } catch (error) {
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Failed to fetch stores by site' 
    }
  }
}

export async function getFIFOStockBalances(storeId: string) {
  try {
    const { data, error } = await repositories.supabase
      .from('stock_balances_fifo')
      .select(`
        *,
        stock_items(item_code, description, unit)
      `)
      .eq('store_id', storeId)
      .gt('current_quantity', 0)

    if (error) throw error

    return { success: true, data }
  } catch (error) {
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Failed to fetch FIFO stock balances' 
    }
  }
}

export async function getFIFOLayers(storeId: string, stockItemId: string) {
  try {
    const { data, error } = await repositories.supabase
      .from('stock_fifo_layers')
      .select('*')
      .eq('store_id', storeId)
      .eq('stock_item_id', stockItemId)
      .gt('remaining_quantity', 0)
      .order('receipt_date')

    if (error) throw error

    return { success: true, data }
  } catch (error) {
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Failed to fetch FIFO layers' 
    }
  }
}

export async function getAutoCreatedStores(projectId: string) {
  try {
    const { data, error } = await repositories.supabase
      .from('stores')
      .select('*')
      .eq('project_id', projectId)
      .eq('is_auto_created', true)
      .eq('is_active', true)

    if (error) throw error

    return { success: true, data }
  } catch (error) {
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Failed to fetch auto-created stores' 
    }
  }
}

export async function getEmptyStores(projectId: string) {
  try {
    const { data, error } = await repositories.supabase
      .from('stores')
      .select(`
        *,
        stock_balances!inner(current_quantity)
      `)
      .eq('project_id', projectId)
      .eq('is_active', true)
      .eq('stock_balances.current_quantity', 0)

    if (error) throw error

    return { success: true, data }
  } catch (error) {
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Failed to fetch empty stores' 
    }
  }
}

export async function manuallyDeleteEmptyStore(storeId: string) {
  try {
    // Check if store is empty
    const { data: balances, error: balanceError } = await repositories.supabase
      .from('stock_balances')
      .select('current_quantity')
      .eq('store_id', storeId)

    if (balanceError) throw balanceError

    const totalStock = balances?.reduce((sum, b) => sum + (b.current_quantity || 0), 0) || 0

    if (totalStock > 0) {
      return { 
        success: false, 
        error: `Cannot delete store with remaining stock: ${totalStock}` 
      }
    }

    // Deactivate store
    const { error } = await repositories.supabase
      .from('stores')
      .update({ is_active: false, updated_at: new Date().toISOString() })
      .eq('id', storeId)

    if (error) throw error

    revalidatePath('/stores')
    return { success: true }
  } catch (error) {
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Failed to delete empty store' 
    }
  }
}