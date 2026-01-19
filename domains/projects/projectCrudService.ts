// Layer 3: Service Layer - Business Logic
import { createServiceClient } from '@/lib/supabase/server'

export async function getAllProjects(companyId?: string) {
  const supabase = await createServiceClient()
  
  let query = supabase
    .from('projects')
    .select(`
      *,
      company:company_code_id(company_code, company_name)
    `)
    .order('created_at', { ascending: false })
  
  if (companyId) {
    query = query.eq('company_code_id', companyId)
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
      company:company_code_id(company_code, company_name)
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
      ...payload,
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
      ...payload,
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
