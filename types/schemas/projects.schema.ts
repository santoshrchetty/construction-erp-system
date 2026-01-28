import { z } from 'zod'

export const ProjectStatusEnum = z.enum(['planning', 'active', 'on_hold', 'completed', 'cancelled'])
export const ProjectTypeEnum = z.enum(['residential', 'commercial', 'infrastructure', 'industrial'])

export const ProjectSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1).max(255),
  code: z.string().min(1).max(50),
  description: z.string().nullable(),
  category_code: z.string().min(1).max(20),
  project_type: ProjectTypeEnum.nullable(),
  status: ProjectStatusEnum.default('planning'),
  start_date: z.string().date().nullable(),
  planned_end_date: z.string().date().nullable(),
  actual_end_date: z.string().date().nullable(),
  budget: z.number().positive().nullable(),
  location: z.string().nullable(),
  company_code: z.string().min(1).max(10),
  plant_code: z.string().max(10).nullable(),
  cost_center: z.string().max(20).nullable(),
  profit_center: z.string().max(20).nullable(),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime(),
  created_by: z.string(),
  updated_by: z.string().nullable()
})

export const CreateProjectSchema = ProjectSchema.omit({
  id: true,
  created_at: true,
  updated_at: true,
  updated_by: true
}).partial({
  status: true,
  description: true,
  project_type: true,
  start_date: true,
  planned_end_date: true,
  actual_end_date: true,
  budget: true,
  location: true,
  plant_code: true,
  cost_center: true,
  profit_center: true
})

export const UpdateProjectSchema = CreateProjectSchema.partial()

// Company Group Schema
export const CompanyGroupSchema = z.object({
  grpcompany_code: z.string().min(1).max(10),
  grpcompany_name: z.string().min(1).max(100),
  description: z.string().nullable(),
  is_active: z.boolean().default(true),
  created_at: z.string().datetime()
})

// Project Category Schema
export const ProjectCategorySchema = z.object({
  id: z.number(),
  category_code: z.string().min(1).max(20),
  category_name: z.string().min(1).max(100),
  description: z.string().nullable(),
  is_active: z.boolean().default(true),
  created_at: z.string().datetime()
})

export type Project = z.infer<typeof ProjectSchema>
export type CreateProject = z.infer<typeof CreateProjectSchema>
export type UpdateProject = z.infer<typeof UpdateProjectSchema>
export type CompanyGroup = z.infer<typeof CompanyGroupSchema>
export type ProjectCategory = z.infer<typeof ProjectCategorySchema>