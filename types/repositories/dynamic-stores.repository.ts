import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from '../supabase/database.types'

export class DynamicStoresRepository {
  private supabase: SupabaseClient<Database>

  constructor(supabase: SupabaseClient<Database>) {
    this.supabase = supabase
  }

  async issueStockFIFO(
    storeId: string,
    stockItemId: string,
    quantity: number,
    referenceNumber: string,
    referenceType: string,
    createdBy: string,
    referenceId?: string,
    notes?: string
  ) {
    const { data, error } = await this.supabase
      .rpc('create_stock_movement_with_fifo', {
        p_store_id: storeId,
        p_stock_item_id: stockItemId,
        p_movement_type: 'issue',
        p_reference_number: referenceNumber,
        p_reference_type: referenceType,
        p_reference_id: referenceId,
        p_quantity: quantity,
        p_unit_cost: 0,
        p_movement_date: new Date().toISOString().split('T')[0],
        p_created_by: createdBy,
        p_notes: notes
      })

    if (error) throw error
    return data
  }

  async getFIFOLayers(storeId: string, stockItemId: string) {
    const { data, error } = await this.supabase
      .from('stock_fifo_layers')
      .select('*')
      .eq('store_id', storeId)
      .eq('stock_item_id', stockItemId)
      .gt('remaining_quantity', 0)
      .order('receipt_date')

    if (error) throw error
    return data || []
  }

  async getFIFOStockBalances(storeId: string) {
    const { data, error } = await this.supabase
      .from('stock_balances_fifo')
      .select(`
        *,
        stock_items(item_code, description, unit)
      `)
      .eq('store_id', storeId)
      .gt('current_quantity', 0)

    if (error) throw error
    return data || []
  }

  async getStoresBySite(projectId: string, siteCode: string) {
    const { data, error } = await this.supabase
      .from('stores')
      .select('*')
      .eq('project_id', projectId)
      .eq('site_code', siteCode)
      .eq('is_active', true)

    if (error) throw error
    return data || []
  }

  async getAutoCreatedStores(projectId: string) {
    const { data, error } = await this.supabase
      .from('stores')
      .select('*')
      .eq('project_id', projectId)
      .eq('is_auto_created', true)
      .eq('is_active', true)

    if (error) throw error
    return data || []
  }

  async getEmptyStores(projectId: string) {
    const { data, error } = await this.supabase
      .from('stores')
      .select(`
        *,
        stock_balances!inner(current_quantity)
      `)
      .eq('project_id', projectId)
      .eq('is_active', true)
      .eq('stock_balances.current_quantity', 0)

    if (error) throw error
    return data || []
  }

  async processFIFOIssue(storeId: string, stockItemId: string, quantity: number) {
    const { data, error } = await this.supabase
      .rpc('process_fifo_issue', {
        p_store_id: storeId,
        p_stock_item_id: stockItemId,
        p_issue_quantity: quantity
      })

    if (error) throw error
    return data || []
  }

  async getStockMovementHistory(storeId: string, stockItemId: string, limit = 50) {
    const { data, error } = await this.supabase
      .from('stock_movements')
      .select(`
        *,
        stock_items(item_code, description, unit)
      `)
      .eq('store_id', storeId)
      .eq('stock_item_id', stockItemId)
      .order('movement_date', { ascending: false })
      .limit(limit)

    if (error) throw error
    return data || []
  }

  async getStoreUtilization(projectId: string) {
    const { data, error } = await this.supabase
      .from('stores')
      .select(`
        id,
        name,
        code,
        site_code,
        is_auto_created,
        stock_balances(current_quantity, fifo_total_value)
      `)
      .eq('project_id', projectId)
      .eq('is_active', true)

    if (error) throw error
    return data || []
  }

  async transferStockBetweenStores(
    fromStoreId: string,
    toStoreId: string,
    stockItemId: string,
    quantity: number,
    referenceNumber: string,
    createdBy: string,
    notes?: string
  ) {
    // This would be handled by the server action
    // but we can provide a repository method for direct usage
    const today = new Date().toISOString().split('T')[0]

    // Issue from source
    const issueResult = await this.issueStockFIFO(
      fromStoreId,
      stockItemId,
      quantity,
      referenceNumber,
      'TRANSFER_OUT',
      createdBy,
      undefined,
      `Transfer to store: ${toStoreId}`
    )

    // Get FIFO cost
    const fifoLayers = await this.processFIFOIssue(fromStoreId, stockItemId, quantity)
    const avgCost = fifoLayers.reduce((sum: number, layer: any) => 
      sum + (layer.quantity_used * layer.unit_cost), 0) / quantity || 0

    // Receipt to destination
    const { data: receiptResult, error: receiptError } = await this.supabase
      .rpc('create_stock_movement_with_fifo', {
        p_store_id: toStoreId,
        p_stock_item_id: stockItemId,
        p_movement_type: 'receipt',
        p_reference_number: referenceNumber,
        p_reference_type: 'TRANSFER_IN',
        p_reference_id: null,
        p_quantity: quantity,
        p_unit_cost: avgCost,
        p_movement_date: today,
        p_created_by: createdBy,
        p_notes: `Transfer from store: ${fromStoreId}`
      })

    if (receiptError) throw receiptError

    return {
      issue_movement_id: issueResult,
      receipt_movement_id: receiptResult
    }
  }

  async deactivateEmptyStore(storeId: string) {
    const { error } = await this.supabase
      .from('stores')
      .update({ 
        is_active: false, 
        updated_at: new Date().toISOString() 
      })
      .eq('id', storeId)

    if (error) throw error
  }
}