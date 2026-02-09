// COMMENTED OUT - References non-existent tables: timesheets, timesheet_entries
// Uncomment when these tables are created in Supabase

/*
import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from '../supabase/database.types'
import { BaseRepository } from './base.repository'

type TimesheetRow = Database['public']['Tables']['timesheets']['Row']
type TimesheetEntryRow = Database['public']['Tables']['timesheet_entries']['Row']

export class TimesheetsRepository extends BaseRepository<'timesheets'> {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase, 'timesheets')
  }

  async findByUser(userId: string): Promise<TimesheetRow[]> {
    const { data, error } = await this.supabase
      .from('timesheets')
      .select('*')
      .eq('user_id', userId)
      .order('week_ending_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async findByProject(projectId: string): Promise<TimesheetRow[]> {
    const { data, error } = await this.supabase
      .from('timesheets')
      .select('*')
      .eq('project_id', projectId)
      .order('week_ending_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async findByStatus(status: Database['public']['Enums']['timesheet_status']): Promise<TimesheetRow[]> {
    const { data, error } = await this.supabase
      .from('timesheets')
      .select('*')
      .eq('status', status)
      .order('submitted_date', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findByUserAndWeek(userId: string, projectId: string, weekEndingDate: string): Promise<TimesheetRow | null> {
    const { data, error } = await this.supabase
      .from('timesheets')
      .select('*')
      .eq('user_id', userId)
      .eq('project_id', projectId)
      .eq('week_ending_date', weekEndingDate)
      .single()

    if (error) throw error
    return data
  }

  async findPendingApproval(): Promise<TimesheetRow[]> {
    const { data, error } = await this.supabase
      .from('timesheets')
      .select('*')
      .eq('status', 'submitted')
      .order('submitted_date', { ascending: true })

    if (error) throw error
    return data || []
  }

  async submitTimesheet(id: string): Promise<TimesheetRow> {
    const { data, error } = await this.supabase
      .from('timesheets')
      .update({
        status: 'submitted',
        submitted_date: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async approveTimesheet(id: string, approvedBy: string): Promise<TimesheetRow> {
    const { data, error } = await this.supabase
      .from('timesheets')
      .update({
        status: 'approved',
        approved_by: approvedBy,
        approved_date: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async rejectTimesheet(id: string, rejectionReason: string): Promise<TimesheetRow> {
    const { data, error } = await this.supabase
      .from('timesheets')
      .update({
        status: 'rejected',
        rejection_reason: rejectionReason
      })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async getTimesheetWithEntries(id: string): Promise<{
    timesheet: TimesheetRow
    entries: TimesheetEntryRow[]
  } | null> {
    const timesheet = await this.findById(id)
    if (!timesheet) return null

    const { data: entries, error } = await this.supabase
      .from('timesheet_entries')
      .select('*')
      .eq('timesheet_id', id)
      .order('entry_date', { ascending: true })

    if (error) throw error

    return {
      timesheet,
      entries: entries || []
    }
  }

  async calculateTotalHours(id: string): Promise<{ totalHours: number; overtimeHours: number }> {
    const { data, error } = await this.supabase
      .from('timesheet_entries')
      .select('hours, entry_type')
      .eq('timesheet_id', id)

    if (error) throw error

    const entries = data || []
    const regularHours = entries
      .filter(e => e.entry_type === 'regular')
      .reduce((sum, e) => sum + e.hours, 0)
    
    const overtimeHours = entries
      .filter(e => e.entry_type === 'overtime')
      .reduce((sum, e) => sum + e.hours, 0)

    return {
      totalHours: regularHours + overtimeHours,
      overtimeHours
    }
  }
}

export class TimesheetEntriesRepository {
  private supabase: SupabaseClient<Database>

  constructor(supabase: SupabaseClient<Database>) {
    this.supabase = supabase
  }

  async create(entryData: Database['public']['Tables']['timesheet_entries']['Insert']): Promise<TimesheetEntryRow> {
    const { data, error } = await this.supabase
      .from('timesheet_entries')
      .insert(entryData)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async findByTimesheet(timesheetId: string): Promise<TimesheetEntryRow[]> {
    const { data, error } = await this.supabase
      .from('timesheet_entries')
      .select('*')
      .eq('timesheet_id', timesheetId)
      .order('entry_date', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findByTask(taskId: string): Promise<TimesheetEntryRow[]> {
    const { data, error } = await this.supabase
      .from('timesheet_entries')
      .select('*')
      .eq('task_id', taskId)
      .order('entry_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async findByActivity(activityId: string): Promise<TimesheetEntryRow[]> {
    const { data, error } = await this.supabase
      .from('timesheet_entries')
      .select('*')
      .eq('activity_id', activityId)
      .order('entry_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async findByDateRange(
    timesheetId: string,
    startDate: string,
    endDate: string
  ): Promise<TimesheetEntryRow[]> {
    const { data, error } = await this.supabase
      .from('timesheet_entries')
      .select('*')
      .eq('timesheet_id', timesheetId)
      .gte('entry_date', startDate)
      .lte('entry_date', endDate)
      .order('entry_date', { ascending: true })

    if (error) throw error
    return data || []
  }

  async update(id: string, updateData: Partial<TimesheetEntryRow>): Promise<TimesheetEntryRow> {
    const { data, error } = await this.supabase
      .from('timesheet_entries')
      .update(updateData)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async delete(id: string): Promise<void> {
    const { error } = await this.supabase
      .from('timesheet_entries')
      .delete()
      .eq('id', id)

    if (error) throw error
  }

  async getTotalHoursByTask(taskId: string): Promise<number> {
    const { data, error } = await this.supabase
      .from('timesheet_entries')
      .select('hours')
      .eq('task_id', taskId)

    if (error) throw error
    return data?.reduce((sum, entry) => sum + entry.hours, 0) || 0
  }
}
*/
