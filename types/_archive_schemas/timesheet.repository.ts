import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from '../supabase/database.types'
import { BaseRepository } from './base.repository'

type EmployeeRow = Database['public']['Tables']['employees']['Row']
type SubcontractorRow = Database['public']['Tables']['subcontractors']['Row']
type DailyTimesheetRow = Database['public']['Tables']['daily_timesheets']['Row']
type TimesheetLineRow = Database['public']['Tables']['timesheet_lines']['Row']
type CostAllocationRow = Database['public']['Tables']['timesheet_cost_allocations']['Row']

export class EmployeeRepository extends BaseRepository {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase)
  }

  async findActive(): Promise<EmployeeRow[]> {
    const { data, error } = await this.supabase
      .from('employees')
      .select('*')
      .eq('is_active', true)
      .order('first_name')

    if (error) throw error
    return data || []
  }

  async findByCode(employeeCode: string): Promise<EmployeeRow | null> {
    const { data, error } = await this.supabase
      .from('employees')
      .select('*')
      .eq('employee_code', employeeCode)
      .eq('is_active', true)
      .single()

    if (error) throw error
    return data
  }

  async findByDepartment(department: string): Promise<EmployeeRow[]> {
    const { data, error } = await this.supabase
      .from('employees')
      .select('*')
      .eq('department', department)
      .eq('is_active', true)
      .order('first_name')

    if (error) throw error
    return data || []
  }

  async createWithRate(employeeData: any, rateData: any) {
    const { data: employee, error: empError } = await this.supabase
      .from('employees')
      .insert(employeeData)
      .select()
      .single()

    if (empError) throw empError

    const { data: rate, error: rateError } = await this.supabase
      .from('employee_rates')
      .insert({
        employee_id: employee.id,
        ...rateData
      })
      .select()
      .single()

    if (rateError) throw rateError

    return { employee, rate }
  }

  async getCurrentRate(employeeId: string, projectId?: string, date: string = new Date().toISOString().split('T')[0]) {
    let query = this.supabase
      .from('employee_rates')
      .select('*')
      .eq('employee_id', employeeId)
      .eq('is_active', true)
      .lte('effective_from', date)

    if (projectId) {
      query = query.or(`project_id.eq.${projectId},project_id.is.null`)
    } else {
      query = query.is('project_id', null)
    }

    const { data, error } = await query
      .or('effective_to.is.null,effective_to.gte.' + date)
      .order('project_id', { ascending: false, nullsLast: true })
      .order('effective_from', { ascending: false })
      .limit(1)

    if (error) throw error
    return data?.[0] || null
  }
}

export class SubcontractorRepository extends BaseRepository {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase)
  }

  async findActive(): Promise<SubcontractorRow[]> {
    const { data, error } = await this.supabase
      .from('subcontractors')
      .select('*')
      .eq('is_active', true)
      .order('company_name')

    if (error) throw error
    return data || []
  }

  async findBySpecialization(specialization: string): Promise<SubcontractorRow[]> {
    const { data, error } = await this.supabase
      .from('subcontractors')
      .select('*')
      .eq('specialization', specialization)
      .eq('is_active', true)
      .order('company_name')

    if (error) throw error
    return data || []
  }

  async getCurrentRate(subcontractorId: string, workType: string, projectId?: string, date: string = new Date().toISOString().split('T')[0]) {
    let query = this.supabase
      .from('subcontractor_rates')
      .select('*')
      .eq('subcontractor_id', subcontractorId)
      .eq('work_type', workType)
      .eq('is_active', true)
      .lte('effective_from', date)

    if (projectId) {
      query = query.or(`project_id.eq.${projectId},project_id.is.null`)
    } else {
      query = query.is('project_id', null)
    }

    const { data, error } = await query
      .or('effective_to.is.null,effective_to.gte.' + date)
      .order('project_id', { ascending: false, nullsLast: true })
      .order('effective_from', { ascending: false })
      .limit(1)

    if (error) throw error
    return data?.[0] || null
  }
}

export class DailyTimesheetRepository extends BaseRepository {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase)
  }

  async createWithLines(timesheetData: any, lines: any[]) {
    const { data: timesheet, error: timesheetError } = await this.supabase
      .from('daily_timesheets')
      .insert(timesheetData)
      .select()
      .single()

    if (timesheetError) throw timesheetError

    const timesheetLines = lines.map(line => ({
      timesheet_id: timesheet.id,
      ...line
    }))

    const { error: linesError } = await this.supabase
      .from('timesheet_lines')
      .insert(timesheetLines)

    if (linesError) throw linesError

    return timesheet
  }

  async findByProject(projectId: string, startDate?: string, endDate?: string): Promise<DailyTimesheetRow[]> {
    let query = this.supabase
      .from('daily_timesheets')
      .select(`
        *,
        employees(first_name, last_name, employee_code),
        subcontractors(company_name, contractor_code),
        timesheet_lines(*)
      `)
      .eq('project_id', projectId)

    if (startDate) query = query.gte('timesheet_date', startDate)
    if (endDate) query = query.lte('timesheet_date', endDate)

    const { data, error } = await query
      .order('timesheet_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async findByEmployee(employeeId: string, startDate?: string, endDate?: string): Promise<DailyTimesheetRow[]> {
    let query = this.supabase
      .from('daily_timesheets')
      .select(`
        *,
        projects(name, code),
        timesheet_lines(*)
      `)
      .eq('employee_id', employeeId)

    if (startDate) query = query.gte('timesheet_date', startDate)
    if (endDate) query = query.lte('timesheet_date', endDate)

    const { data, error } = await query
      .order('timesheet_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async findByStatus(status: string): Promise<DailyTimesheetRow[]> {
    const { data, error } = await this.supabase
      .from('daily_timesheets')
      .select(`
        *,
        employees(first_name, last_name, employee_code),
        subcontractors(company_name, contractor_code),
        projects(name, code)
      `)
      .eq('status', status)
      .order('timesheet_date', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findPendingApproval(): Promise<DailyTimesheetRow[]> {
    return this.findByStatus('submitted')
  }

  async updateStatus(timesheetId: string, status: string, userId?: string, reason?: string) {
    const updateData: any = { status }

    if (status === 'submitted') {
      updateData.submitted_at = new Date().toISOString()
    } else if (status === 'approved' && userId) {
      updateData.approved_by = userId
      updateData.approved_at = new Date().toISOString()
    } else if (status === 'rejected' && reason) {
      updateData.rejection_reason = reason
    }

    const { data, error } = await this.supabase
      .from('daily_timesheets')
      .update(updateData)
      .eq('id', timesheetId)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async bulkUpdateStatus(timesheetIds: string[], status: string, userId?: string, reason?: string) {
    const updateData: any = { status }

    if (status === 'approved' && userId) {
      updateData.approved_by = userId
      updateData.approved_at = new Date().toISOString()
    } else if (status === 'rejected' && reason) {
      updateData.rejection_reason = reason
    }

    const { data, error } = await this.supabase
      .from('daily_timesheets')
      .update(updateData)
      .in('id', timesheetIds)
      .select()

    if (error) throw error
    return data
  }

  async getTimesheetSummary(projectId: string, startDate: string, endDate: string) {
    const { data, error } = await this.supabase
      .from('daily_timesheets')
      .select(`
        *,
        employees(first_name, last_name),
        subcontractors(company_name),
        timesheet_lines(*)
      `)
      .eq('project_id', projectId)
      .gte('timesheet_date', startDate)
      .lte('timesheet_date', endDate)

    if (error) throw error

    const timesheets = data || []
    const summary = {
      total_timesheets: timesheets.length,
      total_employees: new Set(timesheets.filter(t => t.employee_id).map(t => t.employee_id)).size,
      total_subcontractors: new Set(timesheets.filter(t => t.subcontractor_id).map(t => t.subcontractor_id)).size,
      total_regular_hours: timesheets.reduce((sum, t) => sum + (t.total_regular_hours || 0), 0),
      total_overtime_hours: timesheets.reduce((sum, t) => sum + (t.total_overtime_hours || 0), 0),
      total_cost: timesheets.reduce((sum, t) => sum + (t.total_cost || 0), 0),
      status_breakdown: {
        draft: timesheets.filter(t => t.status === 'draft').length,
        submitted: timesheets.filter(t => t.status === 'submitted').length,
        approved: timesheets.filter(t => t.status === 'approved').length,
        rejected: timesheets.filter(t => t.status === 'rejected').length
      }
    }

    return summary
  }

  async validateTimesheet(timesheetId: string) {
    const { data: timesheet, error } = await this.supabase
      .from('daily_timesheets')
      .select(`
        *,
        timesheet_lines(*)
      `)
      .eq('id', timesheetId)
      .single()

    if (error) throw error

    const lines = timesheet.timesheet_lines || []
    const validationResults = {
      is_valid: true,
      errors: [] as string[],
      warnings: [] as string[]
    }

    // Check total hours per day
    const totalHours = lines.reduce((sum, line) => sum + (line.regular_hours || 0) + (line.overtime_hours || 0), 0)
    if (totalHours > 24) {
      validationResults.is_valid = false
      validationResults.errors.push('Total hours cannot exceed 24 per day')
    }

    // Check for excessive overtime
    const totalOvertime = lines.reduce((sum, line) => sum + (line.overtime_hours || 0), 0)
    if (totalOvertime > 12) {
      validationResults.warnings.push('Overtime hours exceed 12 hours')
    }

    // Check for missing cost objects
    const missingCostObjects = lines.filter(line => !line.cost_object_id)
    if (missingCostObjects.length > 0) {
      validationResults.is_valid = false
      validationResults.errors.push('All timesheet lines must have a cost object assigned')
    }

    // Check for zero hours
    const zeroHourLines = lines.filter(line => (line.regular_hours || 0) + (line.overtime_hours || 0) === 0)
    if (zeroHourLines.length > 0) {
      validationResults.warnings.push('Some timesheet lines have zero hours')
    }

    return validationResults
  }
}

export class TimesheetCostAllocationRepository extends BaseRepository {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase)
  }

  async findByProject(projectId: string, startDate?: string, endDate?: string): Promise<CostAllocationRow[]> {
    let query = this.supabase
      .from('timesheet_cost_allocations')
      .select(`
        *,
        cost_objects(code, name, project_id),
        timesheet_lines(
          work_description,
          daily_timesheets(
            timesheet_date,
            employees(first_name, last_name),
            subcontractors(company_name)
          )
        )
      `)
      .eq('cost_objects.project_id', projectId)

    if (startDate) query = query.gte('allocation_date', startDate)
    if (endDate) query = query.lte('allocation_date', endDate)

    const { data, error } = await query
      .order('allocation_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async findByCostObject(costObjectId: string): Promise<CostAllocationRow[]> {
    const { data, error } = await this.supabase
      .from('timesheet_cost_allocations')
      .select(`
        *,
        timesheet_lines(
          work_description,
          daily_timesheets(
            timesheet_date,
            employees(first_name, last_name),
            subcontractors(company_name)
          )
        )
      `)
      .eq('cost_object_id', costObjectId)
      .order('allocation_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async getCostSummaryByPeriod(projectId: string, period: 'week' | 'month' | 'quarter') {
    const { data, error } = await this.supabase.rpc('get_labor_cost_summary_by_period', {
      p_project_id: projectId,
      p_period: period
    })

    if (error) throw error
    return data || []
  }

  async getLaborProductivity(projectId: string, startDate: string, endDate: string) {
    const { data, error } = await this.supabase
      .from('timesheet_cost_allocations')
      .select(`
        cost_object_id,
        cost_objects(code, name),
        labor_hours,
        labor_cost
      `)
      .eq('cost_objects.project_id', projectId)
      .gte('allocation_date', startDate)
      .lte('allocation_date', endDate)

    if (error) throw error

    const allocations = data || []
    const productivity = allocations.reduce((acc, allocation) => {
      const costObjectId = allocation.cost_object_id
      if (!acc[costObjectId]) {
        acc[costObjectId] = {
          cost_object: allocation.cost_objects,
          total_hours: 0,
          total_cost: 0,
          cost_per_hour: 0
        }
      }
      acc[costObjectId].total_hours += allocation.labor_hours
      acc[costObjectId].total_cost += allocation.labor_cost
      acc[costObjectId].cost_per_hour = acc[costObjectId].total_cost / acc[costObjectId].total_hours
      return acc
    }, {} as any)

    return Object.values(productivity)
  }

  async createManualAllocation(allocationData: any) {
    const { data, error } = await this.supabase
      .from('timesheet_cost_allocations')
      .insert(allocationData)
      .select()
      .single()

    if (error) throw error

    // Update cost object totals
    await this.updateCostObjectFromAllocations(allocationData.cost_object_id)

    return data
  }

  private async updateCostObjectFromAllocations(costObjectId: string) {
    const allocations = await this.findByCostObject(costObjectId)
    const totalLaborCost = allocations.reduce((sum, allocation) => sum + allocation.labor_cost, 0)

    await this.supabase
      .from('cost_objects')
      .update({
        actual_amount: totalLaborCost,
        updated_at: new Date().toISOString()
      })
      .eq('id', costObjectId)
  }
}