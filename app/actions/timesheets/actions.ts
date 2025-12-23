'use server'

import { revalidatePath } from 'next/cache'
import { repositories } from '@/lib/repositories'
import { CreateTimesheetSchema, CreateTimesheetEntrySchema, UpdateTimesheetSchema } from '@/types'

export async function createTimesheet(formData: FormData) {
  try {
    const data = {
      user_id: formData.get('user_id') as string,
      project_id: formData.get('project_id') as string,
      week_ending_date: formData.get('week_ending_date') as string,
    }

    const validatedData = CreateTimesheetSchema.parse(data)
    const timesheet = await repositories.timesheets.create(validatedData)
    
    revalidatePath('/timesheets')
    return { success: true, data: timesheet }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create timesheet' }
  }
}

export async function createTimesheetEntry(formData: FormData) {
  try {
    const data = {
      timesheet_id: formData.get('timesheet_id') as string,
      task_id: formData.get('task_id') as string || null,
      activity_id: formData.get('activity_id') as string || null,
      cost_object_id: formData.get('cost_object_id') as string || null,
      entry_date: formData.get('entry_date') as string,
      entry_type: formData.get('entry_type') as any || 'regular',
      hours: parseFloat(formData.get('hours') as string),
      description: formData.get('description') as string || null,
      billable: formData.get('billable') === 'true',
    }

    const validatedData = CreateTimesheetEntrySchema.parse(data)
    const entry = await repositories.timesheetEntries.create(validatedData)
    
    // Update timesheet totals
    const totals = await repositories.timesheets.calculateTotalHours(data.timesheet_id)
    await repositories.timesheets.update(data.timesheet_id, {
      total_hours: totals.totalHours,
      total_overtime_hours: totals.overtimeHours
    })
    
    revalidatePath('/timesheets')
    return { success: true, data: entry }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create timesheet entry' }
  }
}

export async function submitTimesheet(id: string) {
  try {
    const timesheet = await repositories.timesheets.submitTimesheet(id)
    revalidatePath('/timesheets')
    return { success: true, data: timesheet }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to submit timesheet' }
  }
}

export async function approveTimesheet(id: string, approvedBy: string) {
  try {
    const timesheet = await repositories.timesheets.approveTimesheet(id, approvedBy)
    revalidatePath('/timesheets')
    return { success: true, data: timesheet }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to approve timesheet' }
  }
}

export async function rejectTimesheet(id: string, rejectionReason: string) {
  try {
    const timesheet = await repositories.timesheets.rejectTimesheet(id, rejectionReason)
    revalidatePath('/timesheets')
    return { success: true, data: timesheet }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to reject timesheet' }
  }
}

export async function updateTimesheetEntry(id: string, formData: FormData) {
  try {
    const data = {
      hours: parseFloat(formData.get('hours') as string),
      description: formData.get('description') as string || null,
      billable: formData.get('billable') === 'true',
    }

    const entry = await repositories.timesheetEntries.update(id, data)
    revalidatePath('/timesheets')
    return { success: true, data: entry }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to update timesheet entry' }
  }
}

export async function deleteTimesheetEntry(id: string) {
  try {
    await repositories.timesheetEntries.delete(id)
    revalidatePath('/timesheets')
    return { success: true }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to delete timesheet entry' }
  }
}

export async function getTimesheetsByUser(userId: string) {
  try {
    const timesheets = await repositories.timesheets.findByUser(userId)
    return { success: true, data: timesheets }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch timesheets' }
  }
}

export async function getTimesheetsByProject(projectId: string) {
  try {
    const timesheets = await repositories.timesheets.findByProject(projectId)
    return { success: true, data: timesheets }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch timesheets' }
  }
}

export async function getPendingApprovals() {
  try {
    const timesheets = await repositories.timesheets.findPendingApproval()
    return { success: true, data: timesheets }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch pending approvals' }
  }
}

export async function getTimesheetWithEntries(id: string) {
  try {
    const data = await repositories.timesheets.getTimesheetWithEntries(id)
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch timesheet with entries' }
  }
}