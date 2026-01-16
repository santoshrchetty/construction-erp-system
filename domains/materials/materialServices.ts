import { createServiceClient } from '@/lib/supabase/server'

export interface CreateMaterialPayload {
  code: string
  name: string
  category: string
  unit_of_measure: string
  company_code: string
  plant: string
  storage_location: string
}

export async function createMaterial(payload: CreateMaterialPayload, userId: string) {
  validateMaterial(payload)
  await checkDuplicateMaterial(payload.code, payload.company_code)
  
  const supabase = createServiceClient()
  const { data, error } = await supabase
    .from('materials')
    .insert({
      ...payload,
      created_by: userId,
      status: 'active'
    })
    .select()
    .single()

  if (error) throw error
  return data
}

export async function getStockOverview(companyCode: string, filters: any) {
  const supabase = createServiceClient()
  
  try {
    // Build base query with proper joins using explicit foreign key names
    let query = supabase
      .from('stock_balances')
      .select(`
        current_quantity,
        reserved_quantity,
        available_quantity,
        total_value,
        stock_items!stock_balances_stock_item_id_fkey (
          item_code,
          description,
          category,
          unit
        ),
        storage_locations!stock_balances_storage_location_id_fkey (
          sloc_code,
          sloc_name,
          plants!storage_locations_plant_id_fkey (
            plant_code,
            plant_name,
            company_codes!plants_company_code_fkey (
              company_code,
              company_name,
              currency
            )
          )
        )
      `)
    
    // Apply company filter
    if (companyCode && companyCode !== 'ALL') {
      query = query.eq('storage_locations.plants.company_codes.company_code', companyCode)
    }
    
    // Apply category filter at database level
    if (filters.material_category) {
      query = query.eq('stock_items.category', filters.material_category)
    }
    
    // Execute query with error handling
    const { data: stockData, error } = await query.limit(1000)
    
    if (error) {
      console.error('Stock query error:', error)
      throw new Error(`Database query failed: ${error.message}`)
    }
    
    if (!stockData || stockData.length === 0) {
      return []
    }
    
    // Get currency formatting data
    const { data: currencyData } = await supabase
      .from('currencies')
      .select('currency_code, currency_symbol, decimal_places')
    
    const currencyMap = currencyData?.reduce((acc, curr) => {
      acc[curr.currency_code] = curr
      return acc
    }, {} as Record<string, any>) || {}
    
    // Transform data with proper null checks
    let results = stockData.map(item => {
      const stockItem = item.stock_items
      const storageLocation = item.storage_locations
      const plant = storageLocation?.plants
      const company = plant?.company_codes
      
      const currentStock = Number(item.current_quantity) || 0
      const reservedStock = Number(item.reserved_quantity) || 0
      const availableStock = Number(item.available_quantity) || 0
      const totalValue = Number(item.total_value) || 0
      
      // Get currency info
      const companyCurrency = company?.currency || 'USD'
      const currencyInfo = currencyMap[companyCurrency] || { currency_symbol: '$', decimal_places: 2 }
      
      // Calculate status based on business rules
      let status = 'Normal'
      if (currentStock <= 0) {
        status = 'Zero Stock'
      } else if (currentStock < 50) { // TODO: Use dynamic reorder levels
        status = 'Low Stock'
      } else if (currentStock > 1000) { // TODO: Use dynamic max levels
        status = 'Overstock'
      }
      
      return {
        code: stockItem?.item_code || 'UNKNOWN',
        description: stockItem?.description || 'No Description',
        category: stockItem?.category || 'MISC',
        company: company?.company_name || company?.company_code || companyCode,
        plant: plant?.plant_code || 'N/A',
        storage: storageLocation?.sloc_code || 'N/A',
        stock: `${currentStock.toLocaleString()} ${stockItem?.unit || 'EA'}`,
        reserved: `${reservedStock.toLocaleString()} ${stockItem?.unit || 'EA'}`,
        available: `${availableStock.toLocaleString()} ${stockItem?.unit || 'EA'}`,
        value: `${currencyInfo.currency_symbol}${totalValue.toLocaleString('en-US', { 
          minimumFractionDigits: currencyInfo.decimal_places, 
          maximumFractionDigits: currencyInfo.decimal_places 
        })}`,
        status,
        currentStock, // For filtering
        reservedStock,
        availableStock
      }
    })
    
    // Apply stock status filter
    if (filters.stock_status) {
      results = results.filter(item => {
        switch (filters.stock_status.toLowerCase()) {
          case 'zero':
            return item.currentStock <= 0
          case 'low':
            return item.currentStock > 0 && item.currentStock < 50
          case 'normal':
            return item.currentStock >= 50 && item.currentStock <= 1000
          case 'overstock':
            return item.currentStock > 1000
          case 'negative':
            return item.currentStock < 0
          default:
            return true
        }
      })
    }
    
    // Sort by material code for consistent results
    results.sort((a, b) => a.code.localeCompare(b.code))
    
    return results
    
  } catch (error) {
    console.error('getStockOverview error:', error)
    
    // Return structured error for better debugging
    if (error instanceof Error) {
      throw new Error(`Stock overview failed: ${error.message}`)
    }
    
    throw new Error('Stock overview failed: Unknown error')
  }
}

function getStockStatus(quantity: number, lowThreshold: number = 50): string {
  if (quantity <= 0) return 'Zero Stock'
  if (quantity < lowThreshold) return 'Low Stock'
  return 'Normal'
}

function validateMaterial(payload: CreateMaterialPayload) {
  if (!payload.code) throw new Error('Material code required')
  if (!payload.name) throw new Error('Material name required')
  if (!payload.company_code) throw new Error('Company code required')
}

async function checkDuplicateMaterial(code: string, companyCode: string) {
  const supabase = createServiceClient()
  const { data } = await supabase
    .from('materials')
    .select('id')
    .eq('code', code)
    .eq('company_code', companyCode)
    .single()
  
  if (data) throw new Error(`Material ${code} already exists`)
}

export async function bulkUploadMaterials(materials: any[], userId: string) {
  const supabase = createServiceClient()
  const results = []
  const errors = []

  for (const material of materials) {
    try {
      const { data: materialData, error: materialError } = await supabase
        .from('stock_items')
        .upsert({
          material_code: material.material_code,
          material_name: material.material_name,
          description: material.description,
          category: material.category,
          base_uom: material.base_uom,
          material_type: material.material_type,
          standard_price: material.standard_price,
          is_active: true,
          created_by: userId
        }, { onConflict: 'material_code' })
        .select()
        .single()

      if (materialError) {
        errors.push(`Material ${material.material_code}: ${materialError.message}`)
        continue
      }

      results.push(material.material_code)
    } catch (error) {
      errors.push(`Error processing ${material.material_code}: ${error}`)
    }
  }

  return {
    count: results.length,
    uploaded: results,
    errors: errors.length > 0 ? errors : undefined,
    message: `Successfully uploaded ${results.length} materials${errors.length > 0 ? ` with ${errors.length} errors` : ''}`
  }
}

export async function getMaterialMaster(companyCode: string, filters: any = {}) {
  const supabase = createServiceClient()
  
  let query = supabase
    .from('stock_items')
    .select('*')
    .eq('is_active', true)
  
  if (filters.category) {
    query = query.eq('category', filters.category)
  }
  
  if (filters.search) {
    query = query.or(`material_code.ilike.%${filters.search}%,material_name.ilike.%${filters.search}%`)
  }
  
  const { data, error } = await query.order('material_code')
  
  if (error) throw error
  return data || []
}

export async function searchMaterials(query: string, companyCode: string) {
  const supabase = createServiceClient()
  
  const { data, error } = await supabase
    .from('stock_items')
    .select('*')
    .or(`material_code.ilike.%${query}%,material_name.ilike.%${query}%,description.ilike.%${query}%`)
    .eq('is_active', true)
    .limit(50)
  
  if (error) throw error
  return data || []
}