import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from '../supabase/database.types'
import { BaseRepository } from './base.repository'

type TaskRow = Database['public']['Tables']['tasks']['Row']
type TaskInsert = Database['public']['Tables']['tasks']['Insert']

export class TasksRepository extends BaseRepository<'tasks'> {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase, 'tasks')
  }

  async findByProject(projectId: string): Promise<TaskRow[]> {
    const { data, error } = await this.supabase
      .from('tasks')
      .select('*')
      .eq('project_id', projectId)
      .order('planned_start_date', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findByActivity(activityId: string): Promise<TaskRow[]> {
    const { data, error } = await this.supabase
      .from('tasks')
      .select('*')
      .eq('activity_id', activityId)
      .order('planned_start_date', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findByAssignee(userId: string): Promise<TaskRow[]> {
    const { data, error } = await this.supabase
      .from('tasks')
      .select('*')
      .eq('assigned_to', userId)
      .order('priority', { ascending: false })
      .order('planned_start_date', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findByStatus(status: Database['public']['Enums']['task_status']): Promise<TaskRow[]> {
    const { data, error } = await this.supabase
      .from('tasks')
      .select('*')
      .eq('status', status)
      .order('priority', { ascending: false })

    if (error) throw error
    return data || []
  }

  async findOverdueTasks(): Promise<TaskRow[]> {
    const today = new Date().toISOString().split('T')[0]
    
    const { data, error } = await this.supabase
      .from('tasks')
      .select('*')
      .lt('planned_end_date', today)
      .neq('status', 'completed')
      .neq('status', 'cancelled')
      .order('planned_end_date', { ascending: true })

    if (error) throw error
    return data || []
  }

  async updateProgress(id: string, progressPercentage: number, actualHours?: number): Promise<TaskRow> {
    const updateData: any = { progress_percentage: progressPercentage }
    if (actualHours !== undefined) updateData.actual_hours = actualHours

    // Auto-update status based on progress
    if (progressPercentage === 0) updateData.status = 'not_started'
    else if (progressPercentage === 100) updateData.status = 'completed'
    else updateData.status = 'in_progress'

    const { data, error } = await this.supabase
      .from('tasks')
      .update(updateData)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async assignTask(id: string, assignedTo: string): Promise<TaskRow> {
    const { data, error } = await this.supabase
      .from('tasks')
      .update({ assigned_to: assignedTo })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async getTasksWithDependencies(projectId: string): Promise<{
    tasks: TaskRow[]
    dependencies: any[]
  }> {
    const tasks = await this.findByProject(projectId)

    const { data: dependencies, error } = await this.supabase
      .from('task_dependencies')
      .select(`
        *,
        predecessor:predecessor_task_id(*),
        successor:successor_task_id(*)
      `)
      .in('predecessor_task_id', tasks.map(t => t.id))

    if (error) throw error

    return {
      tasks,
      dependencies: dependencies || []
    }
  }

  async createTaskWithDependencies(
    taskData: TaskInsert,
    dependencies?: { predecessor_task_id: string; dependency_type?: string; lag_days?: number }[]
  ): Promise<TaskRow> {
    const task = await this.create(taskData)

    if (dependencies && dependencies.length > 0) {
      const dependencyInserts = dependencies.map(dep => ({
        predecessor_task_id: dep.predecessor_task_id,
        successor_task_id: task.id,
        dependency_type: dep.dependency_type || 'finish_to_start',
        lag_days: dep.lag_days || 0
      }))

      const { error } = await this.supabase
        .from('task_dependencies')
        .insert(dependencyInserts)

      if (error) throw error
    }

    return task
  }
}