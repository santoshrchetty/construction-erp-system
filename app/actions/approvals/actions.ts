'use server'

import { revalidatePath } from 'next/cache'
import { supabase } from '@/lib/supabase'

export async function getPendingApprovals() {
  try {
    const [pos, timesheets, tasks] = await Promise.all([
      supabase.from('purchase_orders').select(`
        id, po_number, vendor_id, total_amount, issue_date, status, created_at,
        vendors(name), projects(name)
      `).eq('status', 'pending_approval'),
      
      supabase.from('weekly_timesheets').select(`
        id, user_id, week_ending_date, total_hours, status, submitted_at,
        users(first_name, last_name, email)
      `).eq('status', 'submitted'),
      
      supabase.from('tasks').select(`
        id, name, status, priority, assigned_to, created_by, created_at,
        projects(name), users!tasks_assigned_to_fkey(first_name, last_name)
      `).eq('status', 'pending_approval')
    ])

    return {
      success: true,
      data: {
        purchaseOrders: pos.data || [],
        timesheets: timesheets.data || [],
        tasks: tasks.data || []
      }
    }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch approvals' }
  }
}

export async function approvePurchaseOrder(id: string, approvedBy: string) {
  try {
    const { error } = await supabase
      .from('purchase_orders')
      .update({
        status: 'approved',
        approved_by: approvedBy,
        approved_at: new Date().toISOString()
      })
      .eq('id', id)

    if (error) throw error

    revalidatePath('/dashboard')
    return { success: true }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to approve PO' }
  }
}

export async function rejectPurchaseOrder(id: string, rejectedBy: string, reason: string) {
  try {
    const { error } = await supabase
      .from('purchase_orders')
      .update({
        status: 'rejected',
        rejected_by: rejectedBy,
        rejected_at: new Date().toISOString(),
        rejection_reason: reason
      })
      .eq('id', id)

    if (error) throw error

    revalidatePath('/dashboard')
    return { success: true }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to reject PO' }
  }
}

export async function approveTimesheet(id: string, approvedBy: string) {
  try {
    const { error } = await supabase
      .from('weekly_timesheets')
      .update({
        status: 'approved',
        approved_by: approvedBy,
        approved_at: new Date().toISOString()
      })
      .eq('id', id)

    if (error) throw error

    revalidatePath('/dashboard')
    return { success: true }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to approve timesheet' }
  }
}

export async function rejectTimesheet(id: string, rejectedBy: string, reason: string) {
  try {
    const { error } = await supabase
      .from('weekly_timesheets')
      .update({
        status: 'rejected',
        rejected_by: rejectedBy,
        rejected_at: new Date().toISOString(),
        rejection_reason: reason
      })
      .eq('id', id)

    if (error) throw error

    revalidatePath('/dashboard')
    return { success: true }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to reject timesheet' }
  }
}