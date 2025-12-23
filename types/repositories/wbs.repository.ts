import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from '../supabase/database.types'
import { BaseRepository } from './base.repository'

type WBSNodeRow = Database['public']['Tables']['wbs_nodes']['Row']
type ActivityRow = Database['public']['Tables']['activities']['Row']

export class WBSRepository extends BaseRepository<'wbs_nodes'> {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase, 'wbs_nodes')
  }

  async findByProject(projectId: string): Promise<WBSNodeRow[]> {
    const { data, error } = await this.supabase
      .from('wbs_nodes')
      .select('*')
      .eq('project_id', projectId)
      .order('level', { ascending: true })
      .order('sequence_order', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findChildren(parentId: string): Promise<WBSNodeRow[]> {
    const { data, error } = await this.supabase
      .from('wbs_nodes')
      .select('*')
      .eq('parent_id', parentId)
      .order('sequence_order', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findRootNodes(projectId: string): Promise<WBSNodeRow[]> {
    const { data, error } = await this.supabase
      .from('wbs_nodes')
      .select('*')
      .eq('project_id', projectId)
      .is('parent_id', null)
      .order('sequence_order', { ascending: true })

    if (error) throw error
    return data || []
  }

  async getWBSTree(projectId: string): Promise<WBSNodeRow[]> {
    const { data, error } = await this.supabase
      .from('wbs_nodes')
      .select('*')
      .eq('project_id', projectId)
      .eq('is_active', true)
      .order('level', { ascending: true })
      .order('sequence_order', { ascending: true })

    if (error) throw error
    return data || []
  }

  async updateBudgetAllocation(id: string, budgetAllocation: number): Promise<WBSNodeRow> {
    const { data, error } = await this.supabase
      .from('wbs_nodes')
      .update({ budget_allocation: budgetAllocation })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }
}

export class ActivitiesRepository extends BaseRepository<'activities'> {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase, 'activities')
  }

  async findByWBSNode(wbsNodeId: string): Promise<ActivityRow[]> {
    const { data, error } = await this.supabase
      .from('activities')
      .select('*')
      .eq('wbs_node_id', wbsNodeId)
      .eq('is_active', true)
      .order('created_at', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findByProject(projectId: string): Promise<ActivityRow[]> {
    const { data, error } = await this.supabase
      .from('activities')
      .select('*')
      .eq('project_id', projectId)
      .eq('is_active', true)
      .order('planned_start_date', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findByResponsibleUser(userId: string): Promise<ActivityRow[]> {
    const { data, error } = await this.supabase
      .from('activities')
      .select('*')
      .eq('responsible_user_id', userId)
      .eq('is_active', true)

    if (error) throw error
    return data || []
  }

  async updateProgress(id: string, actualStartDate?: string, actualEndDate?: string): Promise<ActivityRow> {
    const updateData: any = {}
    if (actualStartDate) updateData.actual_start_date = actualStartDate
    if (actualEndDate) updateData.actual_end_date = actualEndDate

    const { data, error } = await this.supabase
      .from('activities')
      .update(updateData)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }
}