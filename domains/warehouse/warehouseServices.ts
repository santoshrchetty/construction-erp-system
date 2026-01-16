import { createServiceClient } from '@/lib/supabase/server'

export async function getWarehouseOverview(companyCode: string) {
  const supabase = createServiceClient()
  
  const { data, error } = await supabase
    .from('storage_locations')
    .select(`
      *,
      plants(plant_code, plant_name),
      stock_balances(
        material_id,
        current_stock,
        reserved_stock,
        available_stock,
        stock_items(material_code, material_name)
      )
    `)
    .eq('plants.company_code', companyCode)
    .eq('is_active', true)
  
  if (error) throw error
  return data || []
}

export async function processStockMovement(movementData: any, userId: string) {
  const supabase = createServiceClient()
  
  const { data, error } = await supabase
    .from('stock_movements')
    .insert({
      ...movementData,
      created_by: userId,
      created_at: new Date().toISOString()
    })
    .select()
    .single()
  
  if (error) throw error
  return data
}

export async function getStockMovements(companyCode: string, filters: any = {}) {
  const supabase = createServiceClient()
  
  let query = supabase
    .from('stock_movements')
    .select(`
      *,
      stock_items(material_code, material_name),
      storage_locations(location_code, location_name)
    `)
    .eq('company_code', companyCode)
  
  if (filters.movement_type) {
    query = query.eq('movement_type', filters.movement_type)
  }
  
  if (filters.material_id) {
    query = query.eq('material_id', filters.material_id)
  }
  
  const { data, error } = await query.order('movement_date', { ascending: false })
  
  if (error) throw error
  return data || []
}