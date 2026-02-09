// Layer 3: Service Layer - Business Logic
import { createServiceClient } from '@/lib/supabase/server'

export async function getAllProjects() {
  const supabase = await createServiceClient()
  
  const { data, error } = await supabase
    .from('projects')
    .select(`
      *,
      category:project_categories!category_code(category_name)
    `)
    .order('created_at', { ascending: false })
  
  if (error) throw error
  return data || []
}

export async function getProjectById(id: string) {
  const supabase = await createServiceClient()
  
  const { data, error } = await supabase
    .from('projects')
    .select(`
      *,
      category:project_categories!category_code(category_name)
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
      project_code: payload.project_code,
      name: payload.name,
      description: payload.description,
      category_code: payload.category_code,
      project_type: payload.project_type,
      status: payload.status || 'PLANNING',
      start_date: payload.start_date,
      planned_end_date: payload.planned_end_date,
      budget: payload.budget,
      location: payload.location,
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
      project_code: payload.project_code,
      name: payload.name,
      description: payload.description,
      category_code: payload.category_code,
      project_type: payload.project_type,
      status: payload.status,
      start_date: payload.start_date,
      planned_end_date: payload.planned_end_date,
      budget: payload.budget,
      location: payload.location,
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
