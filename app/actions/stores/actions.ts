'use server'

import { revalidatePath } from 'next/cache'
import { repositories } from '@/lib/repositories'
import { CreateStoreSchema, CreateStockItemSchema, CreateStockMovementSchema } from '@/types'

export async function createStore(formData: FormData) {
  try {
    const data = {
      project_id: formData.get('project_id') as string,
      name: formData.get('name') as string,
      code: formData.get('code') as string,
      location: formData.get('location') as string || null,
      store_keeper_id: formData.get('store_keeper_id') as string || null,
    }

    const validatedData = CreateStoreSchema.parse(data)
    const store = await repositories.stores.create(validatedData)
    
    revalidatePath('/stores')
    return { success: true, data: store }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create store' }
  }
}

export async function createStockItem(formData: FormData) {
  try {
    const data = {
      item_code: formData.get('item_code') as string,
      description: formData.get('description') as string,
      category: formData.get('category') as string || null,
      unit: formData.get('unit') as string,
      reorder_level: parseFloat(formData.get('reorder_level') as string) || 0,
      maximum_level: parseFloat(formData.get('maximum_level') as string) || 0,
      minimum_level: parseFloat(formData.get('minimum_level') as string) || 0,
    }

    const validatedData = CreateStockItemSchema.parse(data)
    const stockItem = await repositories.stockItems.create(validatedData)
    
    revalidatePath('/stock-items')
    return { success: true, data: stockItem }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create stock item' }
  }
}

export async function createStockMovement(formData: FormData) {
  try {
    const data = {
      store_id: formData.get('store_id') as string,
      stock_item_id: formData.get('stock_item_id') as string,
      movement_type: formData.get('movement_type') as any,
      reference_number: formData.get('reference_number') as string,
      reference_type: formData.get('reference_type') as string,
      reference_id: formData.get('reference_id') as string || null,
      quantity: parseFloat(formData.get('quantity') as string),
      unit_cost: parseFloat(formData.get('unit_cost') as string),
      movement_date: formData.get('movement_date') as string,
      created_by: formData.get('created_by') as string,
      notes: formData.get('notes') as string || null,
    }

    const validatedData = CreateStockMovementSchema.parse(data)
    const movement = await repositories.stockMovements.create(validatedData)
    
    revalidatePath('/stock-movements')
    return { success: true, data: movement }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create stock movement' }
  }
}

export async function getStoresByProject(projectId: string) {
  try {
    const stores = await repositories.stores.findByProject(projectId)
    return { success: true, data: stores }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch stores' }
  }
}

export async function getStockBalancesByStore(storeId: string) {
  try {
    const balances = await repositories.stockBalances.findByStore(storeId)
    return { success: true, data: balances }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch stock balances' }
  }
}

export async function getLowStockItems(storeId: string) {
  try {
    const lowStock = await repositories.stockItems.findLowStockItems(storeId)
    return { success: true, data: lowStock }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch low stock items' }
  }
}

export async function getStockMovements(storeId: string) {
  try {
    const movements = await repositories.stockMovements.findByStore(storeId)
    return { success: true, data: movements }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch stock movements' }
  }
}

export async function getCurrentStock(storeId: string, stockItemId: string) {
  try {
    const quantity = await repositories.stockBalances.getCurrentStock(storeId, stockItemId)
    return { success: true, data: quantity }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch current stock' }
  }
}

export async function getStockValue(storeId: string) {
  try {
    const value = await repositories.stockBalances.getStockValue(storeId)
    return { success: true, data: value }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch stock value' }
  }
}