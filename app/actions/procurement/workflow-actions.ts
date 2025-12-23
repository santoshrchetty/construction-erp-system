'use server'

import { revalidatePath } from 'next/cache'
import { createServerClient } from '@/lib/supabase'
import { z } from 'zod'

const supabase = createServerClient()

// =====================================================
// PURCHASE REQUISITION ACTIONS
// =====================================================

const CreatePRSchema = z.object({
  project_id: z.string().uuid(),
  requested_by: z.string().uuid(),
  department: z.string().optional(),
  priority: z.number().min(1).max(5).default(3),
  required_date: z.string(),
  justification: z.string().optional(),
  lines: z.array(z.object({
    description: z.string().min(1),
    specification: z.string().optional(),
    quantity: z.number().positive(),
    unit: z.string().min(1),
    estimated_unit_cost: z.number().optional(),
    cost_object_id: z.string().uuid().optional(),
    preferred_vendor_id: z.string().uuid().optional()
  }))
})

export async function createPurchaseRequisition(formData: FormData) {
  try {
    const data = CreatePRSchema.parse({
      project_id: formData.get('project_id'),
      requested_by: formData.get('requested_by'),
      department: formData.get('department'),
      priority: Number(formData.get('priority')),
      required_date: formData.get('required_date'),
      justification: formData.get('justification'),
      lines: JSON.parse(formData.get('lines') as string)
    })

    // Create PR
    const { data: pr, error: prError } = await supabase
      .from('purchase_requisitions')
      .insert({
        project_id: data.project_id,
        requested_by: data.requested_by,
        department: data.department,
        priority: data.priority,
        required_date: data.required_date,
        justification: data.justification
      })
      .select()
      .single()

    if (prError) throw prError

    // Create PR lines
    const prLines = data.lines.map((line, index) => ({
      pr_id: pr.id,
      line_number: index + 1,
      ...line
    }))

    const { error: linesError } = await supabase
      .from('pr_lines')
      .insert(prLines)

    if (linesError) throw linesError

    revalidatePath('/procurement/requisitions')
    return { success: true, data: pr }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create PR' }
  }
}

export async function approvePurchaseRequisition(formData: FormData) {
  try {
    const prId = formData.get('pr_id') as string
    const approvedBy = formData.get('approved_by') as string

    const { data, error } = await supabase
      .from('purchase_requisitions')
      .update({
        status: 'approved',
        approved_by: approvedBy,
        approved_date: new Date().toISOString()
      })
      .eq('id', prId)
      .select()
      .single()

    if (error) throw error

    revalidatePath('/procurement/requisitions')
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to approve PR' }
  }
}

export async function getPendingRequisitions() {
  try {
    const { data, error } = await supabase
      .from('purchase_requisitions')
      .select(`
        *,
        pr_lines(*)
      `)
      .eq('status', 'submitted')
      .order('created_at', { ascending: true })

    if (error) throw error
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch PRs' }
  }
}

// =====================================================
// VENDOR SELECTION ACTIONS
// =====================================================

export async function requestVendorQuotations(formData: FormData) {
  try {
    const prLineId = formData.get('pr_line_id') as string
    const vendorIds = JSON.parse(formData.get('vendor_ids') as string) as string[]

    const quotationRequests = vendorIds.map(vendorId => ({
      pr_line_id: prLineId,
      vendor_id: vendorId,
      quoted_price: 0 // Will be updated when vendor responds
    }))

    const { data, error } = await supabase
      .from('vendor_quotations')
      .insert(quotationRequests)
      .select()

    if (error) throw error

    revalidatePath('/procurement/quotations')
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to request quotations' }
  }
}

export async function submitVendorQuotation(formData: FormData) {
  try {
    const quotationId = formData.get('quotation_id') as string
    const quotedPrice = Number(formData.get('quoted_price'))
    const deliveryDays = Number(formData.get('delivery_days'))
    const validityDate = formData.get('validity_date') as string

    const { data, error } = await supabase
      .from('vendor_quotations')
      .update({
        quoted_price: quotedPrice,
        delivery_days: deliveryDays,
        validity_date: validityDate,
        quotation_number: formData.get('quotation_number'),
        terms_conditions: formData.get('terms_conditions')
      })
      .eq('id', quotationId)
      .select()
      .single()

    if (error) throw error

    revalidatePath('/procurement/quotations')
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to submit quotation' }
  }
}

export async function selectVendorQuotation(formData: FormData) {
  try {
    const quotationId = formData.get('quotation_id') as string
    const prLineId = formData.get('pr_line_id') as string

    // Unselect all quotations for this PR line
    await supabase
      .from('vendor_quotations')
      .update({ is_selected: false })
      .eq('pr_line_id', prLineId)

    // Select the chosen quotation
    const { data, error } = await supabase
      .from('vendor_quotations')
      .update({ is_selected: true })
      .eq('id', quotationId)
      .select()
      .single()

    if (error) throw error

    revalidatePath('/procurement/quotations')
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to select quotation' }
  }
}

// =====================================================
// SUBCONTRACT ACTIONS
// =====================================================

const CreateSubcontractSchema = z.object({
  project_id: z.string().uuid(),
  vendor_id: z.string().uuid(),
  work_description: z.string().min(1),
  contract_value: z.number().positive(),
  start_date: z.string(),
  completion_date: z.string(),
  retention_percentage: z.number().min(0).max(100).default(5),
  advance_percentage: z.number().min(0).max(100).default(0),
  payment_terms: z.string().optional(),
  performance_bond_required: z.boolean().default(false),
  milestones: z.array(z.object({
    milestone_name: z.string().min(1),
    description: z.string().optional(),
    planned_completion_date: z.string(),
    milestone_value: z.number().positive(),
    sequence_order: z.number().positive()
  }))
})

export async function createSubcontractOrder(formData: FormData) {
  try {
    const data = CreateSubcontractSchema.parse({
      project_id: formData.get('project_id'),
      vendor_id: formData.get('vendor_id'),
      work_description: formData.get('work_description'),
      contract_value: Number(formData.get('contract_value')),
      start_date: formData.get('start_date'),
      completion_date: formData.get('completion_date'),
      retention_percentage: Number(formData.get('retention_percentage')),
      advance_percentage: Number(formData.get('advance_percentage')),
      payment_terms: formData.get('payment_terms'),
      performance_bond_required: formData.get('performance_bond_required') === 'true',
      milestones: JSON.parse(formData.get('milestones') as string)
    })

    // Generate subcontract number
    const { data: sequence } = await supabase.rpc('nextval', { sequence_name: 'subcontract_sequence' })
    const subcontractNumber = `SC-${String(sequence).padStart(6, '0')}-${new Date().getFullYear()}`

    // Create subcontract
    const { data: subcontract, error: scError } = await supabase
      .from('subcontract_orders')
      .insert({
        ...data,
        subcontract_number: subcontractNumber,
        created_by: formData.get('created_by') as string
      })
      .select()
      .single()

    if (scError) throw scError

    // Create milestones
    const milestones = data.milestones.map(milestone => ({
      subcontract_id: subcontract.id,
      ...milestone
    }))

    const { error: milestonesError } = await supabase
      .from('subcontract_milestones')
      .insert(milestones)

    if (milestonesError) throw milestonesError

    revalidatePath('/procurement/subcontracts')
    return { success: true, data: subcontract }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create subcontract' }
  }
}

// =====================================================
// GOODS RECEIPT ACTIONS
// =====================================================

export async function createGoodsReceipt(formData: FormData) {
  try {
    const poId = formData.get('po_id') as string
    const storeId = formData.get('store_id') as string
    const receivedBy = formData.get('received_by') as string
    const receiptDate = formData.get('receipt_date') as string
    const lines = JSON.parse(formData.get('lines') as string)

    // Generate GRN number
    const grnNumber = `GRN-${Date.now()}`

    // Create GRN
    const { data: grn, error: grnError } = await supabase
      .from('goods_receipts')
      .insert({
        po_id: poId,
        store_id: storeId,
        grn_number: grnNumber,
        receipt_date: receiptDate,
        received_by: receivedBy,
        receipt_status: 'received'
      })
      .select()
      .single()

    if (grnError) throw grnError

    // Create GRN lines
    const grnLines = lines.map((line: any) => ({
      grn_id: grn.id,
      po_line_id: line.po_line_id,
      ordered_quantity: line.ordered_quantity,
      received_quantity: line.received_quantity,
      accepted_quantity: line.accepted_quantity,
      rejected_quantity: line.rejected_quantity,
      unit_rate: line.unit_rate,
      rejection_reason: line.rejection_reason
    }))

    const { error: linesError } = await supabase
      .from('grn_lines')
      .insert(grnLines)

    if (linesError) throw linesError

    revalidatePath('/procurement/receipts')
    return { success: true, data: grn }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create GRN' }
  }
}

export async function performQualityCheck(formData: FormData) {
  try {
    const grnId = formData.get('grn_id') as string
    const qualityStatus = formData.get('quality_status') as string
    const qualityNotes = formData.get('quality_notes') as string
    const checkedBy = formData.get('checked_by') as string

    const { data, error } = await supabase
      .from('goods_receipts')
      .update({
        quality_status: qualityStatus,
        quality_checked_by: checkedBy,
        quality_check_date: new Date().toISOString(),
        quality_notes: qualityNotes
      })
      .eq('id', grnId)
      .select()
      .single()

    if (error) throw error

    revalidatePath('/procurement/receipts')
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to update quality check' }
  }
}

// =====================================================
// COST POSTING ACTIONS
// =====================================================

export async function getCostSummaryByProject(projectId: string) {
  try {
    const { data, error } = await supabase
      .from('cost_objects')
      .select(`
        *,
        cost_transactions(*)
      `)
      .eq('project_id', projectId)
      .order('code')

    if (error) throw error
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch cost summary' }
  }
}

export async function getCostTransactionHistory(costObjectId: string) {
  try {
    const { data, error } = await supabase
      .from('cost_transactions')
      .select('*')
      .eq('cost_object_id', costObjectId)
      .order('transaction_date', { ascending: false })

    if (error) throw error
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch cost history' }
  }
}