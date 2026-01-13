import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from '@/types/supabase/database.types'

type Activity = Database['public']['Tables']['activities']['Row']
type ActivityInsert = Database['public']['Tables']['activities']['Insert']
type ActivityUpdate = Database['public']['Tables']['activities']['Update']

export class ActivitiesRepository {
  constructor(private supabase: SupabaseClient<Database>) {}

  async findByProject(projectId: string) {
    const { data, error } = await this.supabase
      .from('activities')
      .select(`
        *,
        wbs_nodes(code, name)
      `)
      .eq('project_id', projectId)
      .eq('is_active', true)
      .order('code')

    if (error) throw error
    return data
  }

  async create(activity: ActivityInsert) {
    const { data, error } = await this.supabase
      .from('activities')
      .insert(activity)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async update(id: string, updates: ActivityUpdate) {
    const { data, error } = await this.supabase
      .from('activities')
      .update(updates)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async updateProgress(id: string, progress: number, actualStartDate?: string, actualEndDate?: string) {
    const updates: ActivityUpdate = {
      progress_percentage: progress,
      status: progress === 0 ? 'not_started' : progress === 100 ? 'completed' : 'in_progress'
    }

    if (actualStartDate) updates.actual_start_date = actualStartDate
    if (actualEndDate) updates.actual_end_date = actualEndDate

    return this.update(id, updates)
  }
}