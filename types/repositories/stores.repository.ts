import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from '../supabase/database.types'
import { BaseRepository } from './base.repository'

type StoreRow = Database['public']['Tables']['stores']['Row']
type StockItemRow = Database['public']['Tables']['stock_items']['Row']

export class StoresRepository extends BaseRepository<'stores'> {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase, 'stores')
  }

  async findByProject(projectId: string): Promise<StoreRow[]> {
    const { data, error } = await this.supabase
      .from('stores')
      .select('*')
      .eq('project_id', projectId)
      .eq('is_active', true)
      .order('name', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findByStoreKeeper(storeKeeperId: string): Promise<StoreRow[]> {
    const { data, error } = await this.supabase
      .from('stores')
      .select('*')
      .eq('store_keeper_id', storeKeeperId)
      .eq('is_active', true)

    if (error) throw error
    return data || []
  }

  async findByCode(projectId: string, code: string): Promise<StoreRow | null> {
    const { data, error } = await this.supabase
      .from('stores')
      .select('*')
      .eq('project_id', projectId)
      .eq('code', code)
      .single()

    if (error) throw error
    return data
  }
}

export class StockItemsRepository extends BaseRepository<'stock_items'> {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase, 'stock_items')
  }

  async findByCode(itemCode: string): Promise<StockItemRow | null> {
    const { data, error } = await this.supabase
      .from('stock_items')
      .select('*')
      .eq('item_code', itemCode)
      .single()

    if (error) throw error
    return data
  }

  async findByCategory(category: string): Promise<StockItemRow[]> {
    const { data, error } = await this.supabase
      .from('stock_items')
      .select('*')
      .eq('category', category)
      .eq('is_active', true)
      .order('description', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findLowStockItems(storeId: string): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('stock_balances')
      .select(`
        *,
        stock_item:stock_items(*)
      `)
      .eq('store_id', storeId)
      .filter('current_quantity', 'lte', 'stock_items.reorder_level')

    if (error) throw error
    return data || []
  }
}

export class StockBalancesRepository {
  private supabase: SupabaseClient<Database>

  constructor(supabase: SupabaseClient<Database>) {
    this.supabase = supabase
  }

  async findByStore(storeId: string): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('stock_balances')
      .select(`
        *,
        stock_item:stock_items(*)
      `)
      .eq('store_id', storeId)
      .order('stock_items.description', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findByStockItem(storeId: string, stockItemId: string): Promise<any | null> {
    const { data, error } = await this.supabase
      .from('stock_balances')
      .select(`
        *,
        stock_item:stock_items(*)
      `)
      .eq('store_id', storeId)
      .eq('stock_item_id', stockItemId)
      .single()

    if (error) throw error
    return data
  }

  async getCurrentStock(storeId: string, stockItemId: string): Promise<number> {
    const { data, error } = await this.supabase
      .from('stock_balances')
      .select('current_quantity')
      .eq('store_id', storeId)
      .eq('stock_item_id', stockItemId)
      .single()

    if (error) throw error
    return data?.current_quantity || 0
  }

  async getStockValue(storeId: string): Promise<number> {
    const { data, error } = await this.supabase
      .from('stock_balances')
      .select('total_value')
      .eq('store_id', storeId)

    if (error) throw error
    return data?.reduce((sum, item) => sum + (item.total_value || 0), 0) || 0
  }
}

export class StockMovementsRepository {
  private supabase: SupabaseClient<Database>

  constructor(supabase: SupabaseClient<Database>) {
    this.supabase = supabase
  }

  async create(movementData: Database['public']['Tables']['stock_movements']['Insert']): Promise<any> {
    const { data, error } = await this.supabase
      .from('stock_movements')
      .insert(movementData)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async findByStore(storeId: string, limit = 100): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('stock_movements')
      .select(`
        *,
        stock_item:stock_items(*)
      `)
      .eq('store_id', storeId)
      .order('movement_date', { ascending: false })
      .limit(limit)

    if (error) throw error
    return data || []
  }

  async findByStockItem(storeId: string, stockItemId: string, limit = 50): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('stock_movements')
      .select(`
        *,
        stock_item:stock_items(*)
      `)
      .eq('store_id', storeId)
      .eq('stock_item_id', stockItemId)
      .order('movement_date', { ascending: false })
      .limit(limit)

    if (error) throw error
    return data || []
  }

  async findByReference(referenceType: string, referenceId: string): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('stock_movements')
      .select(`
        *,
        stock_item:stock_items(*)
      `)
      .eq('reference_type', referenceType)
      .eq('reference_id', referenceId)
      .order('movement_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async getMovementsByDateRange(
    storeId: string,
    startDate: string,
    endDate: string
  ): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('stock_movements')
      .select(`
        *,
        stock_item:stock_items(*)
      `)
      .eq('store_id', storeId)
      .gte('movement_date', startDate)
      .lte('movement_date', endDate)
      .order('movement_date', { ascending: false })

    if (error) throw error
    return data || []
  }
}