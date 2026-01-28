import { createServiceClient } from '@/lib/supabase/server'

export interface MaterialMaster {
  material_code: string
  material_name: string
  description?: string
  category: string
  material_group?: string
  base_uom: string
  material_type: string
  weight_unit?: string
  gross_weight?: number
  net_weight?: number
  volume_unit?: string
  volume?: number
}

export interface MaterialPlantData {
  material_code: string
  plant_code: string
  procurement_type: string
  mrp_type: string
  reorder_point: number
  safety_stock: number
  minimum_lot_size: number
  planned_delivery_time: number
}

export interface MaterialPricing {
  material_code: string
  company_code: string
  plant_code?: string
  price_type: string
  price: number
  currency: string
  valid_from: string
  valid_to?: string
}

// Global Material Master Operations
export async function createMaterialMaster(payload: MaterialMaster, userId: string) {
  const supabase = await createServiceClient()
  
  const { data, error } = await supabase
    .from('materials')
    .insert(payload)
    .select()
    .single()

  if (error) throw error
  return data
}

export async function getMaterialMaster(materialCode?: string, searchTerm?: string, filters?: { category?: string, material_type?: string }) {
  const supabase = await createServiceClient()
  
  // Try material_master_view first, fallback to materials table
  let query = supabase
    .from('materials')
    .select('*')
    .eq('is_active', true)
    .order('material_code')

  if (materialCode) {
    query = query.eq('material_code', materialCode)
  } else {
    // Apply text search only to material_name when searching by name
    if (searchTerm) {
      query = query.ilike('material_name', `%${searchTerm}%`)
    }
    
    // Apply additional filters
    if (filters?.category) {
      query = query.eq('category', filters.category)
    }
    
    if (filters?.material_type) {
      query = query.eq('material_type', filters.material_type)
    }
  }

  const { data, error } = await query.limit(100)
  if (error) throw error
  return data || []
}

export async function updateMaterialMaster(materialCode: string, payload: Partial<MaterialMaster>, userId: string) {
  const supabase = await createServiceClient()
  
  const { data, error } = await supabase
    .from('materials')
    .update(payload)
    .eq('material_code', materialCode)
    .select()
    .single()

  if (error) throw error
  return data
}

// Plant Extension Operations
export async function extendMaterialToPlant(payload: MaterialPlantData, userId: string) {
  const supabase = await createServiceClient()
  
  const { data, error } = await supabase
    .from('material_plant_data')
    .insert(payload)
    .select()
    .single()

  if (error) throw error
  return data
}

export async function getMaterialPlantData(materialCode: string, plantCode?: string) {
  const supabase = await createServiceClient()
  
  let query = supabase
    .from('material_plant_data')
    .select(`
      *,
      materials!inner (material_name, category, base_uom)
    `)
    .eq('material_code', materialCode)
    .eq('is_active', true)

  if (plantCode) {
    query = query.eq('plant_code', plantCode)
  }

  const { data, error } = await query
  if (error) throw error
  return data || []
}

export async function updateMaterialPlantData(id: string, payload: Partial<MaterialPlantData>, userId: string) {
  const supabase = await createServiceClient()
  
  const { data, error } = await supabase
    .from('material_plant_data')
    .update(payload)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data
}

// Pricing Operations
export async function createMaterialPricing(payload: MaterialPricing, userId: string) {
  const supabase = await createServiceClient()
  
  const { data, error } = await supabase
    .from('material_pricing')
    .insert(payload)
    .select()
    .single()

  if (error) throw error
  return data
}

export async function getMaterialPricing(materialCode: string, companyCode?: string) {
  const supabase = await createServiceClient()
  
  let query = supabase
    .from('material_pricing')
    .select('*')
    .eq('material_code', materialCode)
    .eq('is_active', true)
    .order('valid_from', { ascending: false })

  if (companyCode) {
    query = query.eq('company_code', companyCode)
  }

  const { data, error } = await query
  if (error) throw error
  return data || []
}

// Master Data Helpers
export async function getMaterialCategories() {
  const supabase = await createServiceClient()
  
  const { data, error } = await supabase
    .from('material_categories')
    .select('*')
    .eq('is_active', true)
    .order('category_name')

  if (error) throw error
  return data || []
}

export async function getMaterialGroups(categoryCode?: string) {
  const supabase = await createServiceClient()
  
  let query = supabase
    .from('material_groups')
    .select('*')
    .eq('is_active', true)
    .order('group_name')

  if (categoryCode) {
    query = query.eq('category_code', categoryCode)
  }

  const { data, error } = await query
  if (error) throw error
  return data || []
}

// Enhanced Stock Overview with new structure
export async function getStockOverviewERP(companyCode: string, filters: any) {
  const supabase = await createServiceClient()
  
  try {
    let query = supabase
      .from('stock_balances')
      .select(`
        current_quantity,
        reserved_quantity,
        available_quantity,
        total_value,
        material_code,
        materials!inner (
          material_name,
          description,
          category,
          base_uom
        ),
        storage_locations!inner (
          sloc_code,
          sloc_name,
          plants!inner (
            plant_code,
            plant_name,
            company_codes!inner (
              company_code,
              company_name,
              currency
            )
          )
        )
      `)
    
    if (companyCode && companyCode !== 'ALL') {
      query = query.eq('storage_locations.plants.company_codes.company_code', companyCode)
    }
    
    if (filters.material_category) {
      query = query.eq('materials.category', filters.material_category)
    }
    
    const { data: stockData, error } = await query.limit(1000)
    
    if (error) throw error
    if (!stockData || stockData.length === 0) return []
    
    // Get currency formatting data
    const { data: currencyData } = await supabase
      .from('currencies')
      .select('currency_code, currency_symbol, decimal_places')
    
    const currencyMap = currencyData?.reduce((acc, curr) => {
      acc[curr.currency_code] = curr
      return acc
    }, {} as Record<string, any>) || {}
    
    let results = stockData.map(item => {
      const material = item.materials
      const storageLocation = item.storage_locations
      const plant = storageLocation?.plants
      const company = plant?.company_codes
      
      const currentStock = Number(item.current_quantity) || 0
      const totalValue = Number(item.total_value) || 0
      
      const companyCurrency = company?.currency || 'USD'
      const currencyInfo = currencyMap[companyCurrency] || { currency_symbol: '$', decimal_places: 2 }
      
      let status = 'Normal'
      if (currentStock <= 0) status = 'Zero Stock'
      else if (currentStock < 50) status = 'Low Stock'
      else if (currentStock > 1000) status = 'Overstock'
      
      return {
        code: item.material_code || 'UNKNOWN',
        description: material?.material_name || 'No Description',
        category: material?.category || 'MISC',
        company: company?.company_name || company?.company_code || companyCode,
        plant: plant?.plant_code || 'N/A',
        storage: storageLocation?.sloc_code || 'N/A',
        stock: `${currentStock.toLocaleString()} ${material?.base_uom || 'EA'}`,
        value: `${currencyInfo.currency_symbol}${totalValue.toLocaleString('en-US', { 
          minimumFractionDigits: currencyInfo.decimal_places, 
          maximumFractionDigits: currencyInfo.decimal_places 
        })}`,
        status,
        currentStock
      }
    })
    
    if (filters.stock_status) {
      results = results.filter(item => {
        switch (filters.stock_status.toLowerCase()) {
          case 'zero': return item.currentStock <= 0
          case 'low': return item.currentStock > 0 && item.currentStock < 50
          case 'normal': return item.currentStock >= 50 && item.currentStock <= 1000
          case 'overstock': return item.currentStock > 1000
          default: return true
        }
      })
    }
    
    results.sort((a, b) => a.code.localeCompare(b.code))
    return results
    
  } catch (error) {
    console.error('getStockOverviewERP error:', error)
    throw new Error(`Stock overview failed: ${error instanceof Error ? error.message : 'Unknown error'}`)
  }
}