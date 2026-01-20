// Repository Layer - Data Access
import { createServiceClient } from '@/lib/supabase/server'

export class ProjectRepository {
  async getUniversalJournalData(companyCode: string) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('universal_journal')
      .select(`
        project_code,
        gl_account,
        debit_credit,
        company_amount,
        posting_date,
        cost_center,
        wbs_element
      `)
      .eq('company_code', companyCode)
      .not('project_code', 'is', null)
      .order('posting_date', { ascending: false })

    if (error) throw error
    return data
  }

  async getProjectBudgets() {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('projects')
      .select('code, budget')

    if (error) throw error
    return data
  }

  async generateProjectCode(request: { entity_type: string; company_code: string; pattern: string }) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .rpc('generate_project_number_with_pattern', {
        p_entity_type: request.entity_type,
        p_company_code: request.company_code,
        p_pattern: request.pattern
      })
    
    if (error) throw error
    return data
  }

  async getCurrentUser() {
    const supabase = await createServiceClient()
    const { data: { user }, error } = await supabase.auth.getUser()
    if (error) throw error
    return user
  }

  async createProject(projectData: any) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('projects')
      .insert(projectData)
      .select('id, code')
      .single()
    
    if (error) throw error
    return { id: data.id, code: data.code }
  }

  async getProjectCategories() {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('project_categories')
      .select('category_code, category_name')
      .eq('is_active', true)
      .order('category_code')
    
    if (error) throw error
    return data || []
  }

  async getCompanyCodes() {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('company_codes')
      .select('id, company_code, company_name')
      .eq('is_active', true)
    
    if (error) throw error
    return data || []
  }

  async getPersonsResponsible() {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('employees')
      .select('id, first_name, last_name, job_title')
      .eq('is_active', true)
    
    if (error) throw error
    return (data || []).map(emp => ({
      id: emp.id,
      name: `${emp.first_name} ${emp.last_name}`,
      role: emp.job_title || 'employee'
    }))
  }

  async getOrganizationalData(companyCode: string) {
    const supabase = await createServiceClient()
    
    const [costCenters, profitCenters, plants] = await Promise.all([
      supabase.from('cost_centers').select('id, cost_center_code, cost_center_name').eq('company_code', companyCode).eq('is_active', true),
      supabase.from('profit_centers').select('id, profit_center_code, profit_center_name').eq('is_active', true),
      supabase.from('plants').select('id, plant_code, plant_name, address').eq('is_active', true)
    ])
    
    return {
      costCenters: costCenters.data || [],
      profitCenters: profitCenters.data || [],
      plants: plants.data || []
    }
  }

  async getNumberingPatterns(params: any) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .from('project_numbering_rules')
      .select('id, pattern, description, entity_type')
      .eq('entity_type', params.entity_type)
      .eq('is_active', true)
    
    if (error) throw error
    return data || []
  }

  async getProjectTypes(categoryCode: string) {
    return [
      { type_code: 'residential', type_name: 'Residential', category_code: categoryCode },
      { type_code: 'commercial', type_name: 'Commercial', category_code: categoryCode },
      { type_code: 'infrastructure', type_name: 'Infrastructure', category_code: categoryCode },
      { type_code: 'industrial', type_name: 'Industrial', category_code: categoryCode }
    ]
  }

  async getProjectReport(companyCode: string, projectCode: string, fromDate?: string, toDate?: string) {
    const supabase = await createServiceClient()
    const { data, error } = await supabase
      .rpc('get_project_report', {
        p_company_code: companyCode,
        p_project_code: projectCode,
        p_from_date: fromDate,
        p_to_date: toDate || new Date().toISOString().split('T')[0]
      })

    if (error) throw error
    return data || []
  }
}