import { createServiceClient } from '@/lib/supabase/server'

export async function getMRPShortages(companyCode: string) {
  const supabase = createServiceClient()
  const { data, error } = await supabase
    .from('material_shortages')
    .select('*')
    .eq('company_code', companyCode)
    .order('shortage_date', { ascending: false })
  if (error) throw error
  return { shortages: data || [], total: data?.length || 0 }
}

export async function getMaterialForecast(companyCode: string, projectId?: string) {
  const supabase = createServiceClient()
  let query = supabase
    .from('material_forecast')
    .select('*')
    .eq('company_code', companyCode)
  if (projectId) query = query.eq('project_id', projectId)
  const { data, error } = await query.order('forecast_date', { ascending: true })
  if (error) throw error
  return { forecast: data || [], timeline: data?.map(d => d.forecast_date) || [] }
}

export async function getDemandForecast(companyCode: string) {
  const supabase = createServiceClient()
  const { data, error } = await supabase
    .from('demand_forecast')
    .select('*')
    .eq('company_code', companyCode)
    .order('period', { ascending: true })
  if (error) throw error
  return { demand: data || [], confidence: 0.85 }
}