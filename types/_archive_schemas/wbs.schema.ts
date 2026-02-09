// import { z } from 'zod' // Removed - not using Zod validation

export const WBSNodeTypeEnum = z.enum(['project', 'phase', 'deliverable', 'work_package'])

export const WBSNodeSchema = z.object({
  id: z.string().uuid(),
  tenant_id: z.string().uuid(),
  project_id: z.string().uuid(),
  parent_id: z.string().uuid().nullable(),
  code: z.string().min(1).max(50),
  name: z.string().min(1).max(255),
  description: z.string().nullable(),
  node_type: WBSNodeTypeEnum,
  level: z.number().int().min(1),
  sequence_order: z.number().int().min(1),
  budget_allocation: z.number().min(0).default(0),
  planned_hours: z.number().min(0).default(0),
  responsible_user_id: z.string().uuid().nullable(),
  start_date: z.string().date().nullable(),
  end_date: z.string().date().nullable(),
  is_active: z.boolean().default(true),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime()
})

export const ActivitySchema = z.object({
  id: z.string().uuid(),
  tenant_id: z.string().uuid(),
  project_id: z.string().uuid(),
  wbs_node_id: z.string().uuid(),
  code: z.string().min(1).max(50),
  name: z.string().min(1).max(255),
  description: z.string().nullable(),
  planned_start_date: z.string().date().nullable(),
  planned_end_date: z.string().date().nullable(),
  actual_start_date: z.string().date().nullable(),
  actual_end_date: z.string().date().nullable(),
  planned_hours: z.number().min(0).default(0),
  budget_amount: z.number().min(0).default(0),
  responsible_user_id: z.string().uuid().nullable(),
  is_active: z.boolean().default(true),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime()
})

export const CreateWBSNodeSchema = WBSNodeSchema.omit({
  id: true,
  tenant_id: true,
  created_at: true,
  updated_at: true
}).partial({
  parent_id: true,
  description: true,
  budget_allocation: true,
  planned_hours: true,
  responsible_user_id: true,
  start_date: true,
  end_date: true,
  is_active: true
})

export const CreateActivitySchema = ActivitySchema.omit({
  id: true,
  tenant_id: true,
  created_at: true,
  updated_at: true
}).partial({
  description: true,
  planned_start_date: true,
  planned_end_date: true,
  actual_start_date: true,
  actual_end_date: true,
  planned_hours: true,
  budget_amount: true,
  responsible_user_id: true,
  is_active: true
})

export const UpdateWBSNodeSchema = CreateWBSNodeSchema.partial()
export const UpdateActivitySchema = CreateActivitySchema.partial()

export type WBSNode = z.infer<typeof WBSNodeSchema>
export type Activity = z.infer<typeof ActivitySchema>
export type CreateWBSNode = z.infer<typeof CreateWBSNodeSchema>
export type CreateActivity = z.infer<typeof CreateActivitySchema>
export type UpdateWBSNode = z.infer<typeof UpdateWBSNodeSchema>
export type UpdateActivity = z.infer<typeof UpdateActivitySchema>