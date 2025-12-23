import { z } from 'zod'

export const ProjectStatusEnum = z.enum(['planning', 'active', 'on_hold', 'completed', 'cancelled'])
export const ProjectTypeEnum = z.enum(['residential', 'commercial', 'infrastructure', 'industrial'])

export const ProjectSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1).max(255),
  code: z.string().min(1).max(50),
  description: z.string().nullable(),
  project_type: ProjectTypeEnum,
  status: ProjectStatusEnum.default('planning'),
  start_date: z.string().date(),
  planned_end_date: z.string().date(),
  actual_end_date: z.string().date().nullable(),
  budget: z.number().positive(),
  client_id: z.string().uuid().nullable(),
  project_manager_id: z.string().uuid().nullable(),
  location: z.string().nullable(),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime()
})

export const CreateProjectSchema = ProjectSchema.omit({
  id: true,
  created_at: true,
  updated_at: true
}).partial({
  status: true,
  description: true,
  actual_end_date: true,
  client_id: true,
  project_manager_id: true,
  location: true
})

export const UpdateProjectSchema = CreateProjectSchema.partial()

export type Project = z.infer<typeof ProjectSchema>
export type CreateProject = z.infer<typeof CreateProjectSchema>
export type UpdateProject = z.infer<typeof UpdateProjectSchema>