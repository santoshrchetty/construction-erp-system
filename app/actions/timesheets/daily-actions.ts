'use server'

import { revalidatePath } from 'next/cache'
import { createServerClient } from '@/lib/supabase'
import { z } from 'zod'

const supabase = createServerClient()

// =====================================================
// EMPLOYEE MANAGEMENT
// =====================================================

const CreateEmployeeSchema = z.object({
  employee_code: z.string().min(1),
  first_name: z.string().min(1),
  last_name: z.string().min(1),
  email: z.string().email().optional(),
  phone: z.string().optional(),
  job_title: z.string().optional(),
  department: z.string().optional(),
  hire_date: z.string(),
  employment_type: z.enum(['permanent', 'contract', 'temporary']).default('permanent')
})

export async function createEmployee(formData: FormData) {
  try {
    const data = CreateEmployeeSchema.parse({
      employee_code: formData.get('employee_code'),
      first_name: formData.get('first_name'),
      last_name: formData.get('last_name'),
      email: formData.get('email'),
      phone: formData.get('phone'),
      job_title: formData.get('job_title'),
      department: formData.get('department'),
      hire_date: formData.get('hire_date'),
      employment_type: formData.get('employment_type')
    })

    const { data: employee, error } = await supabase
      .from('employees')
      .insert(data)
      .select()
      .single()

    if (error) throw error

    revalidatePath('/employees')
    return { success: true, data: employee }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create employee' }
  }
}

export async function getEmployees() {
  try {
    const { data, error } = await supabase
      .from('employees')
      .select('*')
      .eq('is_active', true)
      .order('first_name')

    if (error) throw error
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch employees' }
  }
}

export async function updateEmployee(formData: FormData) {
  try {
    const employeeId = formData.get('employee_id') as string
    const updateData = CreateEmployeeSchema.partial().parse({
      first_name: formData.get('first_name'),
      last_name: formData.get('last_name'),
      email: formData.get('email'),
      phone: formData.get('phone'),
      job_title: formData.get('job_title'),
      department: formData.get('department')
    })

    const { data, error } = await supabase
      .from('employees')
      .update({ ...updateData, updated_at: new Date().toISOString() })
      .eq('id', employeeId)
      .select()
      .single()

    if (error) throw error

    revalidatePath('/employees')
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to update employee' }
  }
}

// =====================================================
// EMPLOYEE RATES
// =====================================================

export async function createEmployeeRate(formData: FormData) {
  try {
    const data = {
      employee_id: formData.get('employee_id') as string,
      project_id: formData.get('project_id') as string || null,
      rate_type: formData.get('rate_type') as string || 'regular',
      hourly_rate: Number(formData.get('hourly_rate')),
      effective_from: formData.get('effective_from') as string,
      effective_to: formData.get('effective_to') as string || null
    }

    const { data: rate, error } = await supabase
      .from('employee_rates')
      .insert(data)
      .select()
      .single()

    if (error) throw error

    revalidatePath('/employees/rates')
    return { success: true, data: rate }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create rate' }
  }
}

export async function getEmployeeRates(employeeId: string) {
  try {
    const { data, error } = await supabase
      .from('employee_rates')
      .select(`
        *,
        projects(name, code)
      `)
      .eq('employee_id', employeeId)
      .eq('is_active', true)
      .order('effective_from', { ascending: false })

    if (error) throw error
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch rates' }
  }
}

// =====================================================
// SUBCONTRACTOR MANAGEMENT
// =====================================================

export async function createSubcontractor(formData: FormData) {
  try {
    const data = {
      contractor_code: formData.get('contractor_code') as string,
      company_name: formData.get('company_name') as string,
      contact_person: formData.get('contact_person') as string,
      email: formData.get('email') as string,
      phone: formData.get('phone') as string,
      specialization: formData.get('specialization') as string
    }

    const { data: subcontractor, error } = await supabase
      .from('subcontractors')
      .insert(data)
      .select()
      .single()

    if (error) throw error

    revalidatePath('/subcontractors')
    return { success: true, data: subcontractor }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create subcontractor' }
  }
}

export async function getSubcontractors() {
  try {
    const { data, error } = await supabase
      .from('subcontractors')
      .select('*')
      .eq('is_active', true)
      .order('company_name')

    if (error) throw error
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch subcontractors' }
  }
}

// =====================================================
// DAILY TIMESHEET CRUD
// =====================================================

const CreateTimesheetSchema = z.object({
  timesheet_date: z.string(),
  project_id: z.string().uuid(),
  employee_id: z.string().uuid().optional(),
  subcontractor_id: z.string().uuid().optional(),
  supervisor_id: z.string().uuid().optional(),
  lines: z.array(z.object({
    task_id: z.string().uuid().optional(),
    activity_id: z.string().uuid().optional(),
    cost_object_id: z.string().uuid(),
    work_description: z.string().min(1),
    start_time: z.string().optional(),
    end_time: z.string().optional(),
    break_minutes: z.number().default(0),
    regular_hours: z.number().nonnegative(),
    overtime_hours: z.number().nonnegative().default(0),
    hourly_rate: z.number().positive(),
    work_location: z.string().optional(),
    equipment_used: z.string().optional(),
    materials_used: z.string().optional(),
    weather_conditions: z.string().optional(),
    remarks: z.string().optional()
  })).min(1)
}).refine(data => data.employee_id || data.subcontractor_id, {
  message: "Either employee_id or subcontractor_id must be provided"
})

export async function createDailyTimesheet(formData: FormData) {
  try {
    const data = CreateTimesheetSchema.parse({
      timesheet_date: formData.get('timesheet_date'),
      project_id: formData.get('project_id'),
      employee_id: formData.get('employee_id') || undefined,
      subcontractor_id: formData.get('subcontractor_id') || undefined,
      supervisor_id: formData.get('supervisor_id') || undefined,
      lines: JSON.parse(formData.get('lines') as string)
    })

    // Create timesheet
    const { data: timesheet, error: timesheetError } = await supabase
      .from('daily_timesheets')
      .insert({
        timesheet_date: data.timesheet_date,
        project_id: data.project_id,
        employee_id: data.employee_id,
        subcontractor_id: data.subcontractor_id,
        supervisor_id: data.supervisor_id
      })
      .select()
      .single()

    if (timesheetError) throw timesheetError

    // Create timesheet lines
    const lines = data.lines.map(line => ({
      timesheet_id: timesheet.id,
      ...line
    }))

    const { error: linesError } = await supabase
      .from('timesheet_lines')
      .insert(lines)

    if (linesError) throw linesError

    revalidatePath('/timesheets')
    return { success: true, data: timesheet }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create timesheet' }
  }
}

export async function getDailyTimesheets(projectId?: string, date?: string) {
  try {
    let query = supabase
      .from('daily_timesheets')
      .select(`
        *,
        employees(first_name, last_name, employee_code),
        subcontractors(company_name, contractor_code),
        projects(name, code),
        timesheet_lines(*)
      `)

    if (projectId) query = query.eq('project_id', projectId)
    if (date) query = query.eq('timesheet_date', date)

    const { data, error } = await query
      .order('timesheet_date', { ascending: false })
      .order('created_at', { ascending: false })

    if (error) throw error
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch timesheets' }
  }
}

export async function getTimesheetById(timesheetId: string) {
  try {
    const { data, error } = await supabase
      .from('daily_timesheets')
      .select(`
        *,
        employees(first_name, last_name, employee_code),
        subcontractors(company_name, contractor_code),
        projects(name, code),
        timesheet_lines(
          *,
          tasks(name),
          activities(name),
          cost_objects(code, name)
        )
      `)
      .eq('id', timesheetId)
      .single()

    if (error) throw error
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch timesheet' }
  }
}

export async function updateTimesheetLine(formData: FormData) {
  try {
    const lineId = formData.get('line_id') as string
    const updateData = {
      work_description: formData.get('work_description'),
      regular_hours: Number(formData.get('regular_hours')),
      overtime_hours: Number(formData.get('overtime_hours')),
      hourly_rate: Number(formData.get('hourly_rate')),
      work_location: formData.get('work_location'),
      remarks: formData.get('remarks')
    }

    const { data, error } = await supabase
      .from('timesheet_lines')
      .update(updateData)
      .eq('id', lineId)
      .select()
      .single()

    if (error) throw error

    revalidatePath('/timesheets')
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to update timesheet line' }
  }
}

export async function deleteTimesheetLine(lineId: string) {
  try {
    const { error } = await supabase
      .from('timesheet_lines')
      .delete()
      .eq('id', lineId)

    if (error) throw error

    revalidatePath('/timesheets')
    return { success: true }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to delete timesheet line' }
  }
}

// =====================================================
// TIMESHEET APPROVAL WORKFLOW
// =====================================================

export async function submitTimesheet(formData: FormData) {
  try {
    const timesheetId = formData.get('timesheet_id') as string

    const { data, error } = await supabase
      .from('daily_timesheets')
      .update({
        status: 'submitted',
        submitted_at: new Date().toISOString()
      })
      .eq('id', timesheetId)
      .select()
      .single()

    if (error) throw error

    revalidatePath('/timesheets')
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to submit timesheet' }
  }
}

export async function approveTimesheet(formData: FormData) {
  try {
    const timesheetId = formData.get('timesheet_id') as string
    const approvedBy = formData.get('approved_by') as string

    const { data, error } = await supabase
      .from('daily_timesheets')
      .update({
        status: 'approved',
        approved_by: approvedBy,
        approved_at: new Date().toISOString()
      })
      .eq('id', timesheetId)
      .select()
      .single()

    if (error) throw error

    revalidatePath('/timesheets')
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to approve timesheet' }
  }
}

export async function rejectTimesheet(formData: FormData) {
  try {
    const timesheetId = formData.get('timesheet_id') as string
    const rejectionReason = formData.get('rejection_reason') as string

    const { data, error } = await supabase
      .from('daily_timesheets')
      .update({
        status: 'rejected',
        rejection_reason: rejectionReason
      })
      .eq('id', timesheetId)
      .select()
      .single()

    if (error) throw error

    revalidatePath('/timesheets')
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to reject timesheet' }
  }
}

export async function getPendingApprovals() {
  try {
    const { data, error } = await supabase
      .from('daily_timesheets')
      .select(`
        *,
        employees(first_name, last_name),
        subcontractors(company_name),
        projects(name, code)
      `)
      .eq('status', 'submitted')
      .order('submitted_at', { ascending: true })

    if (error) throw error
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch pending approvals' }
  }
}

// =====================================================
// COST ALLOCATION REPORTS
// =====================================================

export async function getCostAllocationsByProject(projectId: string, startDate?: string, endDate?: string) {
  try {
    let query = supabase
      .from('timesheet_cost_allocations')
      .select(`
        *,
        cost_objects(code, name),
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
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch cost allocations' }
  }
}

export async function getLaborCostSummary(projectId: string, period: 'week' | 'month' = 'month') {
  try {
    const { data, error } = await supabase.rpc('get_labor_cost_summary', {
      p_project_id: projectId,
      p_period: period
    })

    if (error) throw error
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch labor cost summary' }
  }
}