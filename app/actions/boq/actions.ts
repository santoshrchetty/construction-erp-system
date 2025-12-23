'use server'

import { revalidatePath } from 'next/cache'
import { repositories } from '@/lib/repositories'
import { z } from 'zod'

const CreateBOQCategorySchema = z.object({
  project_id: z.string().uuid(),
  name: z.string().min(1),
  code: z.string().min(1),
  description: z.string().nullable(),
  parent_category_id: z.string().uuid().nullable(),
  sequence_order: z.number().int().default(0),
})

const CreateBOQItemSchema = z.object({
  project_id: z.string().uuid(),
  wbs_node_id: z.string().uuid().nullable(),
  category_id: z.string().uuid(),
  item_code: z.string().min(1),
  description: z.string().min(1),
  specification: z.string().nullable(),
  unit: z.string().min(1),
  quantity: z.number().positive(),
  rate: z.number().positive(),
  is_provisional: z.boolean().default(false),
})

export async function createBOQCategory(formData: FormData) {
  try {
    const data = {
      project_id: formData.get('project_id') as string,
      name: formData.get('name') as string,
      code: formData.get('code') as string,
      description: formData.get('description') as string || null,
      parent_category_id: formData.get('parent_category_id') as string || null,
      sequence_order: parseInt(formData.get('sequence_order') as string) || 0,
    }

    const validatedData = CreateBOQCategorySchema.parse(data)
    const category = await repositories.supabase
      .from('boq_categories')
      .insert(validatedData)
      .select()
      .single()
    
    if (category.error) throw category.error
    
    revalidatePath('/boq')
    return { success: true, data: category.data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create BOQ category' }
  }
}

export async function createBOQItem(formData: FormData) {
  try {
    const data = {
      project_id: formData.get('project_id') as string,
      wbs_node_id: formData.get('wbs_node_id') as string || null,
      category_id: formData.get('category_id') as string,
      item_code: formData.get('item_code') as string,
      description: formData.get('description') as string,
      specification: formData.get('specification') as string || null,
      unit: formData.get('unit') as string,
      quantity: parseFloat(formData.get('quantity') as string),
      rate: parseFloat(formData.get('rate') as string),
      is_provisional: formData.get('is_provisional') === 'true',
    }

    const validatedData = CreateBOQItemSchema.parse(data)
    const item = await repositories.supabase
      .from('boq_items')
      .insert(validatedData)
      .select()
      .single()
    
    if (item.error) throw item.error
    
    revalidatePath('/boq')
    return { success: true, data: item.data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create BOQ item' }
  }
}

export async function updateBOQItem(id: string, formData: FormData) {
  try {
    const data = {
      description: formData.get('description') as string,
      specification: formData.get('specification') as string || null,
      quantity: parseFloat(formData.get('quantity') as string),
      rate: parseFloat(formData.get('rate') as string),
      is_provisional: formData.get('is_provisional') === 'true',
    }

    const item = await repositories.supabase
      .from('boq_items')
      .update(data)
      .eq('id', id)
      .select()
      .single()
    
    if (item.error) throw item.error
    
    revalidatePath('/boq')
    return { success: true, data: item.data }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to update BOQ item' }
  }
}

export async function deleteBOQItem(id: string) {
  try {
    const { error } = await repositories.supabase
      .from('boq_items')
      .delete()
      .eq('id', id)
    
    if (error) throw error
    
    revalidatePath('/boq')
    return { success: true }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to delete BOQ item' }
  }
}

export async function getBOQByProject(projectId: string) {
  try {
    const { data: categories, error: catError } = await repositories.supabase
      .from('boq_categories')
      .select('*')
      .eq('project_id', projectId)
      .order('sequence_order')
    
    if (catError) throw catError

    const { data: items, error: itemError } = await repositories.supabase
      .from('boq_items')
      .select('*')
      .eq('project_id', projectId)
      .order('item_code')
    
    if (itemError) throw itemError
    
    return { success: true, data: { categories, items } }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch BOQ' }
  }
}

export async function getBOQSummary(projectId: string) {
  try {
    const { data, error } = await repositories.supabase
      .from('boq_items')
      .select('amount')
      .eq('project_id', projectId)
    
    if (error) throw error
    
    const totalAmount = data?.reduce((sum, item) => sum + (item.amount || 0), 0) || 0
    
    return { success: true, data: { totalAmount, itemCount: data?.length || 0 } }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch BOQ summary' }
  }
}