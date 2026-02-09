// import { z } from 'zod' // Removed - not using Zod validation

export const TaskStatusEnum = z.enum(['not_started', 'in_progress', 'on_hold', 'completed', 'cancelled'])
export const TaskPriorityEnum = z.enum(['low', 'medium', 'high', 'critical'])

export const TaskSchema = z.object({
  id: z.string().uuid(),
  tenant_id: z.string().uuid(),
  project_id: z.string().uuid(),
  wbs_node_id: z.string().uuid().nullable(),
  activity_id: z.string().uuid().nullable(),
  name: z.string().min(1).max(255),
  description: z.string().nullable(),
  status: TaskStatusEnum.default('not_started'),
  priority: TaskPriorityEnum.default('medium'),
  planned_start_date: z.string().date().nullable(),
  planned_end_date: z.string().date().nullable(),
  actual_start_date: z.string().date().nullable(),
  actual_end_date: z.string().date().nullable(),
  planned_hours: z.number().min(0).default(0),
  actual_hours: z.number().min(0).default(0),
  progress_percentage: z.number().min(0).max(100).default(0),
  assigned_to: z.string().uuid().nullable(),
  created_by: z.string().uuid(),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime()
})

export const TaskDependencySchema = z.object({
  id: z.string().uuid(),
  tenant_id: z.string().uuid(),
  predecessor_task_id: z.string().uuid(),
  successor_task_id: z.string().uuid(),
  dependency_type: z.enum(['finish_to_start', 'start_to_start', 'finish_to_finish', 'start_to_finish']).default('finish_to_start'),
  lag_days: z.number().int().default(0),
  created_at: z.string().datetime()
})

export const CreateTaskSchema = TaskSchema.omit({
  id: true,
  tenant_id: true,
  created_at: true,
  updated_at: true
}).partial({
  wbs_node_id: true,
  activity_id: true,
  description: true,
  status: true,
  priority: true,
  planned_start_date: true,
  planned_end_date: true,
  actual_start_date: true,
  actual_end_date: true,
  planned_hours: true,
  actual_hours: true,
  progress_percentage: true,
  assigned_to: true
})

export const CreateTaskDependencySchema = TaskDependencySchema.omit({
  id: true,
  tenant_id: true,
  created_at: true
}).partial({
  dependency_type: true,
  lag_days: true
})

export const UpdateTaskSchema = CreateTaskSchema.partial()
export const UpdateTaskDependencySchema = CreateTaskDependencySchema.partial()

export type Task = z.infer<typeof TaskSchema>
export type TaskDependency = z.infer<typeof TaskDependencySchema>
export type CreateTask = z.infer<typeof CreateTaskSchema>
export type CreateTaskDependency = z.infer<typeof CreateTaskDependencySchema>
export type UpdateTask = z.infer<typeof UpdateTaskSchema>
export type UpdateTaskDependency = z.infer<typeof UpdateTaskDependencySchema>