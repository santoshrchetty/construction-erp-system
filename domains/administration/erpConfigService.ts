import { createServiceClient } from '@/lib/supabase/server'

export class ERPConfigService {
  
  async getCompanies() {
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('company_codes')
      .select('id, company_code, company_name, currency, grpcompany_code')
      .eq('is_active', true)
      .order('company_code')

    if (error) throw error
    return data || []
  }

  async getPlants(companyCode?: string) {
    const supabase = await createServiceClient()
    
    let query = supabase
      .from('plants')
      .select('id, plant_code, plant_name, plant_type, company_code')
      .eq('is_active', true)
    
    if (companyCode) {
      query = query.eq('company_code', companyCode)
    }
    
    const { data, error } = await query.order('plant_code')

    if (error) throw error
    return data || []
  }

  async getStorageLocations(plantCode?: string) {
    const supabase = await createServiceClient()
    
    let query = supabase
      .from('storage_locations')
      .select('sloc_code, sloc_name, plant_code')
      .eq('is_active', true)
    
    if (plantCode) {
      query = query.eq('plant_code', plantCode)
    }
    
    const { data, error } = await query.order('sloc_name')

    if (error) throw error
    return data || []
  }
}