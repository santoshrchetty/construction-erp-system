'use server'

import { revalidatePath } from 'next/cache'
import { repositories } from '@/lib/repositories'
import { CreateWBSNodeSchema, UpdateWBSNodeSchema, CreateActivitySchema } from '@/types'

export async function createWBSNode(formData: FormData) {
  try {
    const data = {
      project_id: formData.get('project_id') as string,
      parent_id: formData.get('parent_id') as string || null,
      code: formData.get('code') as string,
      name: formData.get('name') as string,
      description: formData.get('description') as string || null,
      node_type: formData.get('node_type') as any,
      level: parseInt(formData.get('level') as string),
      sequence_order: parseInt(formData.get('sequence_order') as string),
      budget_allocation: parseFloat(formData.get('budget_allocation') as string) || 0,
    }

    const validatedData = CreateWBSNodeSchema.parse(data)
    const wbsNode = await repositories.wbs.create(validatedData)
    
    revalidatePath('/wbs')
    return { success: true, data: wbsNode }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create WBS node' }
  }
}

export async function updateWBSNode(id: string, formData: FormData) {
  try {
    const data = {
      name: formData.get('name') as string,
      description: formData.get('description') as string || null,
      budget_allocation: parseFloat(formData.get('budget_allocation') as string) || 0,
      start_date: formData.get('start_date') as string || null,
      end_date: formData.get('end_date') as string || null,
    }

    const validatedData = UpdateWBSNodeSchema.parse(data)
    const wbsNode = await repositories.wbs.update(id, validatedData)
    
    revalidatePath('/wbs')
    return { success: true, data: wbsNode }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to update WBS node' }
  }
}

export async function deleteWBSNode(id: string) {
  try {
    await repositories.wbs.delete(id)
    revalidatePath('/wbs')
    return { success: true }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to delete WBS node' }
  }
}

export async function getWBSTree(projectId: string) {
  try {
    const wbsTree = await repositories.wbs.getWBSTree(projectId)
    return { success: true, data: wbsTree }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch WBS tree' }
  }
}

export async function createActivity(formData: FormData) {
  try {
    const data = {
      project_id: formData.get('project_id') as string,
      wbs_node_id: formData.get('wbs_node_id') as string,
      code: formData.get('code') as string,
      name: formData.get('name') as string,
      description: formData.get('description') as string || null,
      planned_start_date: formData.get('planned_start_date') as string || null,
      planned_end_date: formData.get('planned_end_date') as string || null,
      budget_amount: parseFloat(formData.get('budget_amount') as string) || 0,
    }

    const validatedData = CreateActivitySchema.parse(data)
    const activity = await repositories.activities.create(validatedData)
    
    revalidatePath('/activities')
    return { success: true, data: activity }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create activity' }
  }
}

export async function getActivitiesByWBS(wbsNodeId: string) {
  try {
    const activities = await repositories.activities.findByWBSNode(wbsNodeId)
    return { success: true, data: activities }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch activities' }
  }
}