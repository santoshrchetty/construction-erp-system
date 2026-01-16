import { createServiceClient } from '@/lib/supabase/server'

export async function getQualityInspections(companyCode: string, filters: any = {}) {
  const supabase = createServiceClient()
  
  let query = supabase
    .from('quality_inspections')
    .select(`
      *,
      projects(project_code, project_name),
      employees(employee_id, first_name, last_name)
    `)
    .eq('company_code', companyCode)
  
  if (filters.status) {
    query = query.eq('status', filters.status)
  }
  
  if (filters.project_id) {
    query = query.eq('project_id', filters.project_id)
  }
  
  const { data, error } = await query.order('inspection_date', { ascending: false })
  
  if (error) throw error
  return data || []
}

export async function createQualityInspection(inspectionData: any, userId: string) {
  const supabase = createServiceClient()
  
  const { data, error } = await supabase
    .from('quality_inspections')
    .insert({
      ...inspectionData,
      created_by: userId,
      created_at: new Date().toISOString()
    })
    .select()
    .single()
  
  if (error) throw error
  return data
}

export async function getQualityReports(companyCode: string, fromDate?: string, toDate?: string) {
  const supabase = createServiceClient()
  
  let query = supabase
    .from('quality_inspections')
    .select('*')
    .eq('company_code', companyCode)
  
  if (fromDate) {
    query = query.gte('inspection_date', fromDate)
  }
  
  if (toDate) {
    query = query.lte('inspection_date', toDate)
  }
  
  const { data, error } = await query.order('inspection_date', { ascending: false })
  
  if (error) throw error
  return data || []
}