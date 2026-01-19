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

  async findWithResourceCounts(projectId: string, dateFrom: string, dateTo: string, limit = 50) {
    const { data: activities, error } = await this.supabase
      .from('activities')
      .select('id, code, name, planned_start_date, planned_end_date, status, priority')
      .eq('project_id', projectId)
      .gte('planned_start_date', dateFrom)
      .lte('planned_start_date', dateTo)
      .eq('is_active', true)
      .order('planned_start_date')
      .limit(limit)

    if (error) throw error

    const activitiesWithCounts = await Promise.all(
      (activities || []).map(async (activity) => {
        const [materials, equipment, manpower, services, subcontractors] = await Promise.all([
          this.supabase.from('activity_materials').select('id', { count: 'exact', head: true }).eq('activity_id', activity.id),
          this.supabase.from('activity_equipment').select('id', { count: 'exact', head: true }).eq('activity_id', activity.id),
          this.supabase.from('activity_manpower').select('id', { count: 'exact', head: true }).eq('activity_id', activity.id),
          this.supabase.from('activity_services').select('id', { count: 'exact', head: true }).eq('activity_id', activity.id),
          this.supabase.from('activity_subcontractors').select('id', { count: 'exact', head: true }).eq('activity_id', activity.id)
        ])

        return {
          ...activity,
          material_count: materials.count || 0,
          equipment_count: equipment.count || 0,
          manpower_count: manpower.count || 0,
          services_count: services.count || 0,
          subcontractor_count: subcontractors.count || 0
        }
      })
    )

    return activitiesWithCounts
  }

  // Services methods
  async findServicesByActivity(activityId: string) {
    const { data, error } = await this.supabase
      .from('activity_services')
      .select('*, vendors(name)')
      .eq('activity_id', activityId)
      .order('scheduled_date')

    if (error) throw error
    return data
  }

  async createService(service: any) {
    const { data, error } = await this.supabase
      .from('activity_services')
      .insert(service)
      .select()
      .single()

    if (error) throw error
    return data
  }

  // Subcontractors methods
  async findSubcontractorsByActivity(activityId: string) {
    const { data, error } = await this.supabase
      .from('activity_subcontractors')
      .select('*, vendors(name)')
      .eq('activity_id', activityId)
      .order('planned_start_date')

    if (error) throw error
    return data
  }

  async createSubcontractor(subcontractor: any) {
    const { data, error } = await this.supabase
      .from('activity_subcontractors')
      .insert(subcontractor)
      .select()
      .single()

    if (error) throw error
    return data
  }
}