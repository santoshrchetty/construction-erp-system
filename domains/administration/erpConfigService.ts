import { createServiceClient } from '@/lib/supabase/server'

export class ERPConfigService {
  
  async getAccountAssignmentTypes() {
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('account_assignment_types')
      .select('*')
      .eq('is_active', true)
      .order('display_order')

    if (error) throw error
    return data || []
  }

  async getAllowedAccountAssignments(mrType: string) {
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('mr_type_account_assignment_mapping')
      .select(`
        account_assignment_code,
        is_default,
        display_order,
        account_assignment_types (
          code,
          name,
          description,
          requires_cost_center,
          requires_wbs_element,
          requires_activity_code,
          requires_asset_number,
          requires_order_number
        )
      `)
      .eq('mr_type', mrType)
      .eq('is_allowed', true)
      .order('display_order')

    if (error) throw error
    
    return (data || []).map(item => ({
      code: item.account_assignment_code,
      is_default: item.is_default,
      ...(item.account_assignment_types as any)
    }))
  }

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