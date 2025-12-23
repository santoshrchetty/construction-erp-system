'use server'

import { revalidatePath } from 'next/cache'
import { repositories } from '@/lib/repositories'
import { CreateVendorSchema, CreatePurchaseOrderSchema, UpdateVendorSchema } from '@/types'

export async function createVendor(formData: FormData) {
  try {
    const data = {
      name: formData.get('name') as string,
      code: formData.get('code') as string,
      contact_person: formData.get('contact_person') as string || null,
      email: formData.get('email') as string || null,
      phone: formData.get('phone') as string || null,
      address: formData.get('address') as string || null,
      tax_id: formData.get('tax_id') as string || null,
      status: formData.get('status') as any || 'active',
      credit_limit: parseFloat(formData.get('credit_limit') as string) || 0,
      payment_terms: formData.get('payment_terms') as string || null,
    }

    const validatedData = CreateVendorSchema.parse(data)
    const vendor = await repositories.vendors.create(validatedData)
    
    revalidatePath('/vendors')
    return { success: true, data: vendor }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create vendor' }
  }
}

export async function updateVendor(id: string, formData: FormData) {
  try {
    const data = {
      name: formData.get('name') as string,
      contact_person: formData.get('contact_person') as string || null,
      email: formData.get('email') as string || null,
      phone: formData.get('phone') as string || null,
      address: formData.get('address') as string || null,
      status: formData.get('status') as any,
      credit_limit: parseFloat(formData.get('credit_limit') as string) || 0,
      payment_terms: formData.get('payment_terms') as string || null,
    }

    const validatedData = UpdateVendorSchema.parse(data)
    const vendor = await repositories.vendors.update(id, validatedData)
    
    revalidatePath('/vendors')
    return { success: true, data: vendor }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to update vendor' }
  }
}

export async function createPurchaseOrder(formData: FormData) {
  try {
    const data = {
      project_id: formData.get('project_id') as string,
      po_number: formData.get('po_number') as string,
      vendor_id: formData.get('vendor_id') as string,
      po_type: formData.get('po_type') as any || 'standard',
      issue_date: formData.get('issue_date') as string,
      delivery_date: formData.get('delivery_date') as string,
      total_amount: parseFloat(formData.get('total_amount') as string),
      tax_amount: parseFloat(formData.get('tax_amount') as string) || 0,
      payment_terms: formData.get('payment_terms') as string || null,
      delivery_terms: formData.get('delivery_terms') as string || null,
      created_by: formData.get('created_by') as string,
      notes: formData.get('notes') as string || null,
    }

    const validatedData = CreatePurchaseOrderSchema.parse(data)
    const po = await repositories.purchaseOrders.create(validatedData)
    
    revalidatePath('/purchase-orders')
    return { success: true, data: po }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create purchase order' }
  }
}

export async function approvePurchaseOrder(id: string, approvedBy: string) {
  try {
    const po = await repositories.purchaseOrders.approvePO(id, approvedBy)
    revalidatePath('/purchase-orders')
    return { success: true, data: po }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to approve purchase order' }
  }
}

export async function updatePOStatus(id: string, status: string) {
  try {
    const po = await repositories.purchaseOrders.updateStatus(id, status as any)
    revalidatePath('/purchase-orders')
    return { success: true, data: po }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to update PO status' }
  }
}

export async function getVendors() {
  try {
    const vendors = await repositories.vendors.findAll()
    return { success: true, data: vendors }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch vendors' }
  }
}

export async function getPurchaseOrdersByProject(projectId: string) {
  try {
    const pos = await repositories.purchaseOrders.findByProject(projectId)
    return { success: true, data: pos }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch purchase orders' }
  }
}

export async function getPendingPOApprovals() {
  try {
    const pos = await repositories.purchaseOrders.findPendingApproval()
    return { success: true, data: pos }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch pending approvals' }
  }
}