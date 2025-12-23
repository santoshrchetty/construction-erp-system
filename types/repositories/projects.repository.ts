import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from '../supabase/database.types'
import { BaseRepository } from './base.repository'

type ProjectRow = Database['public']['Tables']['projects']['Row']
type ProjectInsert = Database['public']['Tables']['projects']['Insert']
type ProjectUpdate = Database['public']['Tables']['projects']['Update']

export class ProjectsRepository extends BaseRepository<'projects'> {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase, 'projects')
  }

  async findByCode(code: string): Promise<ProjectRow | null> {
    const { data, error } = await this.supabase
      .from('projects')
      .select('*')
      .eq('code', code)
      .single()

    if (error) throw error
    return data
  }

  async findByStatus(status: Database['public']['Enums']['project_status']): Promise<ProjectRow[]> {
    const { data, error } = await this.supabase
      .from('projects')
      .select('*')
      .eq('status', status)

    if (error) throw error
    return data || []
  }

  async findByProjectManager(projectManagerId: string): Promise<ProjectRow[]> {
    const { data, error } = await this.supabase
      .from('projects')
      .select('*')
      .eq('project_manager_id', projectManagerId)

    if (error) throw error
    return data || []
  }

  async findActiveProjects(): Promise<ProjectRow[]> {
    const { data, error } = await this.supabase
      .from('projects')
      .select('*')
      .eq('status', 'active')
      .order('start_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async updateStatus(id: string, status: Database['public']['Enums']['project_status']): Promise<ProjectRow> {
    const { data, error } = await this.supabase
      .from('projects')
      .update({ status })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async getProjectSummary(id: string): Promise<{
    project: ProjectRow
    totalBudget: number
    actualSpend: number
    remainingBudget: number
  } | null> {
    const project = await this.findById(id)
    if (!project) return null

    // This would typically join with cost tables
    // For now, returning basic project info
    return {
      project,
      totalBudget: project.budget,
      actualSpend: 0, // Would calculate from actual_costs table
      remainingBudget: project.budget
    }
  }
}