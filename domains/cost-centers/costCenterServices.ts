import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export class CostCenterService {
  async getCostCentersByCompany(companyCode?: string) {
    let query = supabase
      .from('cost_centers')
      .select('id, cost_center_code, cost_center_name, company_code')
      .eq('is_active', true)
      .order('cost_center_code')
    
    if (companyCode) {
      query = query.eq('company_code', companyCode)
    }
    
    const { data, error } = await query
    if (error) throw error
    
    return data || []
  }
}