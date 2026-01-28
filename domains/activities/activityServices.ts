import { createServiceClient } from '@/lib/supabase/server'

export class ActivityService {
  async getActivitiesByWBSCode(wbsCode: string) {
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('activities')
      .select('*')
      .eq('wbs_element', wbsCode)
      .order('code')
    
    if (error) throw error
    return data || []
  }

  async getActivitiesByProject(projectCode: string) {
    const supabase = await createServiceClient()
    
    const { data, error } = await supabase
      .from('activities')
      .select('*')
      .eq('project_code', projectCode)
      .order('code')
    
    if (error) throw error
    return data || []
  }
}