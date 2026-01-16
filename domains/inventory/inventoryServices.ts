import { createServiceClient } from '@/lib/supabase/server'

export interface GoodsReceiptPayload {
  material_id: string
  quantity: number
  plant: string
  storage_location: string
  po_number?: string
  project_code?: string
}

export async function processGoodsReceipt(payload: GoodsReceiptPayload, userId: string) {
  validateGoodsReceipt(payload)
  
  const supabase = createServiceClient()
  const { data, error } = await supabase.rpc('post_goods_receipt', {
    p_material_id: payload.material_id,
    p_quantity: payload.quantity,
    p_plant: payload.plant,
    p_storage_location: payload.storage_location,
    p_po_number: payload.po_number,
    p_project_code: payload.project_code,
    p_user_id: userId
  })
  
  if (error) throw error
  return data
}

export async function processGoodsIssue(payload: any, userId: string) {
  validateGoodsIssue(payload)
  
  const supabase = createServiceClient()
  const { data, error } = await supabase.rpc('post_goods_issue', {
    p_material_id: payload.material_id,
    p_quantity: payload.quantity,
    p_plant: payload.plant,
    p_storage_location: payload.storage_location,
    p_project_code: payload.project_code,
    p_user_id: userId
  })
  
  if (error) throw error
  return data
}

function validateGoodsReceipt(payload: GoodsReceiptPayload) {
  if (!payload.material_id) throw new Error('Material ID required')
  if (!payload.quantity || payload.quantity <= 0) throw new Error('Valid quantity required')
  if (!payload.plant) throw new Error('Plant required')
  if (!payload.storage_location) throw new Error('Storage location required')
}

function validateGoodsIssue(payload: any) {
  if (!payload.material_id) throw new Error('Material ID required')
  if (!payload.quantity || payload.quantity <= 0) throw new Error('Valid quantity required')
}