import { createServiceClient } from '@/lib/supabase/server'

export interface CreatePOPayload {
  vendor_id: string
  company_code: string
  purchase_requisition_ids?: string[]
  items: POItem[]
  delivery_date: string
  terms_conditions?: string
}

export interface POItem {
  material_id: string
  quantity: number
  unit_price: number
  delivery_date: string
  cost_center?: string
  project_code?: string
}

export async function createPurchaseOrder(payload: CreatePOPayload, userId: string) {
  // Business Logic
  await validatePurchaseOrder(payload)
  await checkBudgetAvailability(payload)
  const poNumber = await generatePONumber(payload.company_code)
  
  // Data Access
  const supabase = createServiceClient()
  
  const { data: po, error: poError } = await supabase
    .from('purchase_orders')
    .insert({
      po_number: poNumber,
      vendor_id: payload.vendor_id,
      company_code: payload.company_code,
      total_amount: calculateTotalAmount(payload.items),
      delivery_date: payload.delivery_date,
      terms_conditions: payload.terms_conditions,
      status: 'draft',
      created_by: userId
    })
    .select()
    .single()

  if (poError) throw poError

  const poItems = payload.items.map(item => ({
    po_id: po.id,
    material_id: item.material_id,
    quantity: item.quantity,
    unit_price: item.unit_price,
    total_amount: item.quantity * item.unit_price,
    delivery_date: item.delivery_date,
    cost_center: item.cost_center,
    project_code: item.project_code
  }))

  const { error: itemsError } = await supabase
    .from('po_items')
    .insert(poItems)

  if (itemsError) throw itemsError

  // Link to PRs if provided
  if (payload.purchase_requisition_ids?.length) {
    await linkPurchaseRequisitions(po.id, payload.purchase_requisition_ids)
  }

  return { po, items: poItems }
}

async function validatePurchaseOrder(payload: CreatePOPayload) {
  if (!payload.vendor_id) throw new Error('Vendor required')
  if (!payload.items?.length) throw new Error('At least one item required')
  
  const supabase = createServiceClient()
  const { data: vendor } = await supabase
    .from('vendors')
    .select('id, status')
    .eq('id', payload.vendor_id)
    .single()
  
  if (!vendor || vendor.status !== 'active') {
    throw new Error('Invalid or inactive vendor')
  }
}

async function checkBudgetAvailability(payload: CreatePOPayload) {
  const totalAmount = calculateTotalAmount(payload.items)
  
  // Check project budgets if project codes exist
  const projectItems = payload.items.filter(item => item.project_code)
  
  for (const item of projectItems) {
    const supabase = createServiceClient()
    const { data: project } = await supabase
      .from('projects')
      .select('budget')
      .eq('code', item.project_code)
      .single()
    
    if (project && project.budget < (item.quantity * item.unit_price)) {
      throw new Error(`Insufficient budget for project ${item.project_code}`)
    }
  }
}

function calculateTotalAmount(items: POItem[]): number {
  return items.reduce((sum, item) => sum + (item.quantity * item.unit_price), 0)
}

async function generatePONumber(companyCode: string): Promise<string> {
  const year = new Date().getFullYear()
  const prefix = `PO-${companyCode}-${year}`
  
  const supabase = createServiceClient()
  const { data } = await supabase
    .from('purchase_orders')
    .select('po_number')
    .like('po_number', `${prefix}%`)
    .order('po_number', { ascending: false })
    .limit(1)

  const lastNumber = data?.[0]?.po_number?.split('-')[3] || '0000'
  const nextNumber = (parseInt(lastNumber) + 1).toString().padStart(4, '0')
  
  return `${prefix}-${nextNumber}`
}

async function linkPurchaseRequisitions(poId: string, prIds: string[]) {
  const supabase = createServiceClient()
  
  const links = prIds.map(prId => ({
    po_id: poId,
    pr_id: prId
  }))
  
  await supabase.from('po_pr_links').insert(links)
  
  // Update PR status
  await supabase
    .from('purchase_requisitions')
    .update({ status: 'po_created' })
    .in('id', prIds)
}