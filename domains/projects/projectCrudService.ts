// Layer 3: Service Layer - Business Logic
import { createServiceClient } from '@/lib/supabase/server'

export async function getAllProjects(companyCode?: string) {
  const supabase = await createServiceClient()
  
  let query = supabase
    .from('projects')
    .select(`
      *,
      company:company_codes!company_code(company_name)
    `)
    .order('created_at', { ascending: false })
  
  if (companyCode) {
    query = query.eq('company_code', companyCode)
  }
  
  const { data, error } = await query
  
  if (error) throw error
  return data || []
}

export async function getProjectById(id: string) {
  const supabase = await createServiceClient()
  
  const { data, error } = await supabase
    .from('projects')
    .select(`
      *,
      company:company_codes!company_code(company_name)
    `)
    .eq('id', id)
    .single()
  
  if (error) throw error
  return data
}

export async function createProject(payload: any, userId: string) {
  const supabase = await createServiceClient()
  
  const { data, error } = await supabase
    .from('projects')
    .insert({
      code: payload.code,
      name: payload.name,
      description: payload.description,
      category_code: payload.category_code,
      project_type: payload.project_type,
      status: payload.status,
      start_date: payload.start_date,
      planned_end_date: payload.planned_end_date,
      budget: payload.budget,
      location: payload.location,
      company_code: payload.company_code,
      plant_code: payload.plant_code,
      cost_center: payload.cost_center,
      profit_center: payload.profit_center,
      created_by: userId
    })
    .select()
    .single()
  
  if (error) throw error
  return data
}

export async function updateProject(id: string, payload: any, userId: string) {
  const supabase = await createServiceClient()
  
  const { data, error } = await supabase
    .from('projects')
    .update({
      code: payload.code,
      name: payload.name,
      description: payload.description,
      category_code: payload.category_code,
      project_type: payload.project_type,
      status: payload.status,
      start_date: payload.start_date,
      planned_end_date: payload.planned_end_date,
      budget: payload.budget,
      location: payload.location,
      company_code: payload.company_code,
      plant_code: payload.plant_code,
      cost_center: payload.cost_center,
      profit_center: payload.profit_center,
      updated_at: new Date().toISOString()
    })
    .eq('id', id)
    .select()
    .single()
  
  if (error) throw error
  return data
}

export async function deleteProject(id: string) {
  const supabase = await createServiceClient()
  
  const { error } = await supabase
    .from('projects')
    .delete()
    .eq('id', id)
  
  if (error) throw error
  return { success: true }
}
