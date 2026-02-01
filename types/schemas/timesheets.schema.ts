import { z } from 'zod'

export const TimesheetStatusEnum = z.enum(['draft', 'submitted', 'approved', 'rejected'])
export const EntryTypeEnum = z.enum(['regular', 'overtime', 'holiday', 'sick_leave', 'vacation'])

export const TimesheetSchema = z.object({
  id: z.string().uuid(),
  tenant_id: z.string().uuid(),
  user_id: z.string().uuid(),
  project_id: z.string().uuid(),
  week_ending_date: z.string().date(),
  status: TimesheetStatusEnum.default('draft'),
  total_hours: z.number().min(0).default(0),
  total_overtime_hours: z.number().min(0).default(0),
  submitted_date: z.string().datetime().nullable(),
  approved_by: z.string().uuid().nullable(),
  approved_date: z.string().datetime().nullable(),
  rejection_reason: z.string().nullable(),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime()
})

export const TimesheetEntrySchema = z.object({
  id: z.string().uuid(),
  tenant_id: z.string().uuid(),
  timesheet_id: z.string().uuid(),
  task_id: z.string().uuid().nullable(),
  activity_id: z.string().uuid().nullable(),
  cost_object_id: z.string().uuid().nullable(),
  entry_date: z.string().date(),
  entry_type: EntryTypeEnum.default('regular'),
  hours: z.number().positive().max(24),
  description: z.string().nullable(),
  billable: z.boolean().default(true),
  created_at: z.string().datetime()
})

export const CreateTimesheetSchema = TimesheetSchema.omit({
  id: true,
  tenant_id: true,
  created_at: true,
  updated_at: true
}).partial({
  status: true,
  total_hours: true,
  total_overtime_hours: true,
  submitted_date: true,
  approved_by: true,
  approved_date: true,
  rejection_reason: true
})

export const CreateTimesheetEntrySchema = TimesheetEntrySchema.omit({
  id: true,
  tenant_id: true,
  created_at: true
}).partial({
  task_id: true,
  activity_id: true,
  cost_object_id: true,
  entry_type: true,
  description: true,
  billable: true
})

export const UpdateTimesheetSchema = CreateTimesheetSchema.partial()
export const UpdateTimesheetEntrySchema = CreateTimesheetEntrySchema.partial()

export type Timesheet = z.infer<typeof TimesheetSchema>
export type TimesheetEntry = z.infer<typeof TimesheetEntrySchema>
export type CreateTimesheet = z.infer<typeof CreateTimesheetSchema>
export type CreateTimesheetEntry = z.infer<typeof CreateTimesheetEntrySchema>
export type UpdateTimesheet = z.infer<typeof UpdateTimesheetSchema>
export type UpdateTimesheetEntry = z.infer<typeof UpdateTimesheetEntrySchema>