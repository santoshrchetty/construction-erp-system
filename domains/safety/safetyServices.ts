import { createServiceClient } from '@/lib/supabase/server'

export async function getSafetyIncidents(companyCode: string, filters: any = {}) {
  const supabase = createServiceClient()
  
  let query = supabase
    .from('safety_incidents')
    .select(`
      *,
      projects(project_code, project_name),
      employees(employee_id, first_name, last_name)
    `)
    .eq('company_code', companyCode)
  
  if (filters.severity) {
    query = query.eq('severity', filters.severity)
  }
  
  if (filters.status) {
    query = query.eq('status', filters.status)
  }
  
  const { data, error } = await query.order('incident_date', { ascending: false })
  
  if (error) throw error
  return data || []
}

export async function createSafetyIncident(incidentData: any, userId: string) {
  const supabase = createServiceClient()
  
  const { data, error } = await supabase
    .from('safety_incidents')
    .insert({
      ...incidentData,
      created_by: userId,
      created_at: new Date().toISOString()
    })
    .select()
    .single()
  
  if (error) throw error
  return data
}

export async function getSafetyCompliance(companyCode: string) {
  const supabase = createServiceClient()
  
  const { data, error } = await supabase
    .from('safety_compliance')
    .select('*')
    .eq('company_code', companyCode)
    .eq('is_active', true)
    .order('compliance_date', { ascending: false })
  
  if (error) throw error
  return data || []
}