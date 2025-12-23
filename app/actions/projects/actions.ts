'use server'

import { revalidatePath } from 'next/cache'
import { repositories } from '@/lib/repositories'
import { CreateProjectSchema, UpdateProjectSchema } from '@/types'

export async function createProject(formData: FormData) {
  try {
    const data = {
      name: formData.get('name') as string,
      code: formData.get('code') as string,
      description: formData.get('description') as string || null,
      project_type: formData.get('project_type') as any,
      start_date: formData.get('start_date') as string,
      planned_end_date: formData.get('planned_end_date') as string,
      budget: parseFloat(formData.get('budget') as string),
      location: formData.get('location') as string || null,
    }

    const validatedData = CreateProjectSchema.parse(data)
    const project = await repositories.projects.create(validatedData)
    
    revalidatePath('/projects')
    return { success: true, data: project }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to create project' }
  }
}

export async function updateProject(id: string, formData: FormData) {
  try {
    const data = {
      name: formData.get('name') as string,
      description: formData.get('description') as string || null,
      status: formData.get('status') as any,
      planned_end_date: formData.get('planned_end_date') as string,
      budget: parseFloat(formData.get('budget') as string),
      location: formData.get('location') as string || null,
    }

    const validatedData = UpdateProjectSchema.parse(data)
    const project = await repositories.projects.update(id, validatedData)
    
    revalidatePath('/projects')
    return { success: true, data: project }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to update project' }
  }
}

export async function deleteProject(id: string) {
  try {
    await repositories.projects.delete(id)
    revalidatePath('/projects')
    return { success: true }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to delete project' }
  }
}

export async function getProjects() {
  try {
    const projects = await repositories.projects.findAll()
    return { success: true, data: projects }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch projects' }
  }
}

export async function getProject(id: string) {
  try {
    const project = await repositories.projects.findById(id)
    return { success: true, data: project }
  } catch (error) {
    return { success: false, error: error instanceof Error ? error.message : 'Failed to fetch project' }
  }
}