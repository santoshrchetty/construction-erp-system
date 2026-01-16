import { createServiceClient } from '@/lib/supabase/server'

export async function getCostCenterOverview(companyCode: string) {
  const supabase = createServiceClient()
  
  const { data, error } = await supabase
    .from('cost_centers')
    .select('*')
    .eq('company_code', companyCode)
    .eq('is_active', true)
    .order('cost_center_code')
  
  if (error) throw error
  return data || []
}

export async function getProjectCostAnalysis(projectCode: string) {
  if (!projectCode) throw new Error('Project code required')
  
  const supabase = createServiceClient()
  const { data, error } = await supabase
    .from('project_line_items')
    .select('*')
    .eq('project_code', projectCode)
    .order('posting_date', { ascending: false })
  
  if (error) throw error
  return data || []
}

export async function getBudgetMonitoring(companyCode: string) {
  const supabase = createServiceClient()
  
  const { data, error } = await supabase
    .from('projects')
    .select(`
      id, name, code, budget,
      project_line_items(amount)
    `)
    .eq('company_code', companyCode)
    .eq('status', 'active')
  
  if (error) throw error
  
  return data?.map(project => ({
    ...project,
    actualCost: project.project_line_items?.reduce((sum: number, item: any) => sum + (item.amount || 0), 0) || 0,
    variance: (project.budget || 0) - (project.project_line_items?.reduce((sum: number, item: any) => sum + (item.amount || 0), 0) || 0)
  })) || []
}