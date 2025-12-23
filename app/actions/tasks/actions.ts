'use server'

import { revalidatePath } from 'next/cache'
import { repositories } from '@/lib/repositories'
import { CreateTaskSchema, UpdateTaskSchema } from '@/types'

export async function createTask(formData: FormData) {
  try {
    const data = {
      project_id: formData.get('project_id') as string,
      activity_id: formData.get('activity_id') as string || null,
      name: formData.get('name') as string,
      description: formData.get('description') as string || null,
      priority: formData.get('priority') as any || 'medium',
      planned_start_date: formData.get('planned_start_date') as string || null,
      planned_end_date: formData.get('planned_end_date') as string || null,
      planned_hours: parseFloat(formData.get('planned_hours') as string) || 0,
      assigned_to: formData.get('assigned_to') as string || null,
      created_by: formData.get('created_by') as string,
    }

    const validatedData = CreateTaskSchema.parse(data)
    const task = await repositories.tasks.create(validatedData)
    
    revalidatePath('/tasks')
    return { success: true, data: task }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create task' }
  }
}

export async function updateTask(id: string, formData: FormData) {
  try {
    const data = {
      name: formData.get('name') as string,
      description: formData.get('description') as string || null,
      status: formData.get('status') as any,
      priority: formData.get('priority') as any,
      planned_end_date: formData.get('planned_end_date') as string || null,
      assigned_to: formData.get('assigned_to') as string || null,
    }

    const validatedData = UpdateTaskSchema.parse(data)
    const task = await repositories.tasks.update(id, validatedData)
    
    revalidatePath('/tasks')
    return { success: true, data: task }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to update task' }
  }
}

export async function updateTaskProgress(id: string, progressPercentage: number, actualHours?: number) {
  try {
    const task = await repositories.tasks.updateProgress(id, progressPercentage, actualHours)
    revalidatePath('/tasks')
    return { success: true, data: task }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to update task progress' }
  }
}

export async function assignTask(id: string, assignedTo: string) {
  try {
    const task = await repositories.tasks.assignTask(id, assignedTo)
    revalidatePath('/tasks')
    return { success: true, data: task }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to assign task' }
  }
}

export async function deleteTask(id: string) {
  try {
    await repositories.tasks.delete(id)
    revalidatePath('/tasks')
    return { success: true }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to delete task' }
  }
}

export async function getTasksByProject(projectId: string) {
  try {
    const tasks = await repositories.tasks.findByProject(projectId)
    return { success: true, data: tasks }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch tasks' }
  }
}

export async function getTasksByActivity(activityId: string) {
  try {
    const tasks = await repositories.tasks.findByActivity(activityId)
    return { success: true, data: tasks }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch tasks' }
  }
}

export async function getOverdueTasks() {
  try {
    const tasks = await repositories.tasks.findOverdueTasks()
    return { success: true, data: tasks }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch overdue tasks' }
  }
}