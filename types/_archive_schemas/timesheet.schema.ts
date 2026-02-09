// import { z } from 'zod' // Removed - not using Zod validation

// Employee Schemas
export const CreateEmployeeSchema = z.object({
  tenant_id: z.string().uuid(),
  employee_code: z.string().min(1, 'Employee code is required'),
  first_name: z.string().min(1, 'First name is required'),
  last_name: z.string().min(1, 'Last name is required'),
  email: z.string().email('Invalid email format').optional(),
  phone: z.string().optional(),
  job_title: z.string().optional(),
  department: z.string().optional(),
  hire_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid hire date'),
  employment_type: z.enum(['permanent', 'contract', 'temporary']).default('permanent')
})

export const UpdateEmployeeSchema = CreateEmployeeSchema.partial().omit({ employee_code: true, hire_date: true })

// Employee Rate Schemas
export const CreateEmployeeRateSchema = z.object({
  tenant_id: z.string().uuid(),
  employee_id: z.string().uuid('Invalid employee ID'),
  project_id: z.string().uuid('Invalid project ID').optional(),
  rate_type: z.enum(['regular', 'overtime', 'holiday']).default('regular'),
  hourly_rate: z.number().positive('Hourly rate must be positive'),
  effective_from: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid effective from date'),
  effective_to: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid effective to date').optional()
}).refine((data) => {
  if (data.effective_to) {
    return new Date(data.effective_to) > new Date(data.effective_from)
  }
  return true
}, {
  message: 'Effective to date must be after effective from date',
  path: ['effective_to']
})

// Subcontractor Schemas
export const CreateSubcontractorSchema = z.object({
  tenant_id: z.string().uuid(),
  contractor_code: z.string().min(1, 'Contractor code is required'),
  company_name: z.string().min(1, 'Company name is required'),
  contact_person: z.string().optional(),
  email: z.string().email('Invalid email format').optional(),
  phone: z.string().optional(),
  specialization: z.string().optional()
})

export const UpdateSubcontractorSchema = CreateSubcontractorSchema.partial().omit({ contractor_code: true })

// Subcontractor Rate Schemas
export const CreateSubcontractorRateSchema = z.object({
  tenant_id: z.string().uuid(),
  subcontractor_id: z.string().uuid('Invalid subcontractor ID'),
  project_id: z.string().uuid('Invalid project ID').optional(),
  work_type: z.string().min(1, 'Work type is required'),
  unit_type: z.enum(['hour', 'day', 'piece']).default('hour'),
  unit_rate: z.number().positive('Unit rate must be positive'),
  effective_from: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid effective from date'),
  effective_to: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid effective to date').optional()
})

// Timesheet Line Schema
export const TimesheetLineSchema = z.object({
  task_id: z.string().uuid().optional(),
  activity_id: z.string().uuid().optional(),
  cost_object_id: z.string().uuid('Cost object is required'),
  work_description: z.string().min(1, 'Work description is required'),
  start_time: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Invalid time format (HH:MM)').optional(),
  end_time: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Invalid time format (HH:MM)').optional(),
  break_minutes: z.number().min(0).max(480).default(0), // Max 8 hours break
  regular_hours: z.number().min(0).max(24, 'Regular hours cannot exceed 24'),
  overtime_hours: z.number().min(0).max(12, 'Overtime hours cannot exceed 12').default(0),
  hourly_rate: z.number().positive('Hourly rate must be positive'),
  work_location: z.string().optional(),
  equipment_used: z.string().optional(),
  materials_used: z.string().optional(),
  weather_conditions: z.string().optional(),
  remarks: z.string().optional()
}).refine((data) => {
  if (data.start_time && data.end_time) {
    const start = new Date(`1970-01-01T${data.start_time}:00`)
    const end = new Date(`1970-01-01T${data.end_time}:00`)
    const diffHours = (end.getTime() - start.getTime()) / (1000 * 60 * 60)
    const workHours = diffHours - (data.break_minutes / 60)
    return workHours >= 0 && workHours <= (data.regular_hours + data.overtime_hours + 0.5) // Allow 30min tolerance
  }
  return true
}, {
  message: 'Work hours do not match time range',
  path: ['regular_hours']
})

// Daily Timesheet Schema
export const CreateDailyTimesheetSchema = z.object({
  tenant_id: z.string().uuid(),
  timesheet_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid timesheet date'),
  project_id: z.string().uuid('Invalid project ID'),
  employee_id: z.string().uuid().optional(),
  subcontractor_id: z.string().uuid().optional(),
  supervisor_id: z.string().uuid().optional(),
  lines: z.array(TimesheetLineSchema).min(1, 'At least one timesheet line is required')
}).refine((data) => {
  return (data.employee_id && !data.subcontractor_id) || (!data.employee_id && data.subcontractor_id)
}, {
  message: 'Either employee or subcontractor must be selected, but not both',
  path: ['employee_id']
}).refine((data) => {
  const timesheetDate = new Date(data.timesheet_date)
  const today = new Date()
  today.setHours(23, 59, 59, 999) // End of today
  return timesheetDate <= today
}, {
  message: 'Timesheet date cannot be in the future',
  path: ['timesheet_date']
})

// Update Timesheet Schema
export const UpdateTimesheetLineSchema = z.object({
  line_id: z.string().uuid(),
  work_description: z.string().min(1, 'Work description is required'),
  regular_hours: z.number().min(0).max(24),
  overtime_hours: z.number().min(0).max(12).default(0),
  hourly_rate: z.number().positive('Hourly rate must be positive'),
  work_location: z.string().optional(),
  equipment_used: z.string().optional(),
  materials_used: z.string().optional(),
  weather_conditions: z.string().optional(),
  remarks: z.string().optional()
})

// Timesheet Status Update Schemas
export const SubmitTimesheetSchema = z.object({
  timesheet_id: z.string().uuid('Invalid timesheet ID')
})

export const ApproveTimesheetSchema = z.object({
  timesheet_id: z.string().uuid('Invalid timesheet ID'),
  approved_by: z.string().uuid('Invalid approver ID'),
  approval_notes: z.string().optional()
})

export const RejectTimesheetSchema = z.object({
  timesheet_id: z.string().uuid('Invalid timesheet ID'),
  rejection_reason: z.string().min(1, 'Rejection reason is required'),
  rejected_by: z.string().uuid('Invalid rejector ID')
})

// Cost Allocation Schemas
export const ManualCostAllocationSchema = z.object({
  timesheet_line_id: z.string().uuid(),
  cost_object_id: z.string().uuid(),
  allocation_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid allocation date'),
  labor_hours: z.number().positive('Labor hours must be positive'),
  labor_cost: z.number().positive('Labor cost must be positive'),
  allocation_method: z.enum(['direct', 'allocated']).default('direct'),
  allocation_notes: z.string().optional()
})

// Report Schemas
export const TimesheetReportSchema = z.object({
  project_id: z.string().uuid().optional(),
  employee_id: z.string().uuid().optional(),
  subcontractor_id: z.string().uuid().optional(),
  start_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid start date'),
  end_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid end date'),
  status: z.enum(['draft', 'submitted', 'approved', 'rejected']).optional(),
  cost_object_id: z.string().uuid().optional()
}).refine((data) => {
  return new Date(data.end_date) >= new Date(data.start_date)
}, {
  message: 'End date must be after or equal to start date',
  path: ['end_date']
})

export const LaborCostSummarySchema = z.object({
  project_id: z.string().uuid('Invalid project ID'),
  period: z.enum(['week', 'month', 'quarter', 'year']).default('month'),
  start_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid start date').optional(),
  end_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid end date').optional(),
  group_by: z.enum(['employee', 'cost_object', 'task', 'activity']).default('cost_object')
})

// Bulk Operations Schemas
export const BulkTimesheetActionSchema = z.object({
  timesheet_ids: z.array(z.string().uuid()).min(1, 'At least one timesheet must be selected'),
  action: z.enum(['submit', 'approve', 'reject']),
  reason: z.string().optional(), // Required for reject action
  performed_by: z.string().uuid('Invalid user ID')
}).refine((data) => {
  if (data.action === 'reject') {
    return data.reason && data.reason.length > 0
  }
  return true
}, {
  message: 'Reason is required for reject action',
  path: ['reason']
})

// Time Tracking Validation
export const TimeValidationSchema = z.object({
  employee_id: z.string().uuid().optional(),
  subcontractor_id: z.string().uuid().optional(),
  date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid date'),
  total_hours: z.number().min(0).max(24, 'Total hours cannot exceed 24 per day')
})

// Export types for use in components
export type CreateEmployee = z.infer<typeof CreateEmployeeSchema>
export type UpdateEmployee = z.infer<typeof UpdateEmployeeSchema>
export type CreateEmployeeRate = z.infer<typeof CreateEmployeeRateSchema>
export type CreateSubcontractor = z.infer<typeof CreateSubcontractorSchema>
export type CreateSubcontractorRate = z.infer<typeof CreateSubcontractorRateSchema>
export type TimesheetLine = z.infer<typeof TimesheetLineSchema>
export type CreateDailyTimesheet = z.infer<typeof CreateDailyTimesheetSchema>
export type UpdateTimesheetLine = z.infer<typeof UpdateTimesheetLineSchema>
export type ApproveTimesheet = z.infer<typeof ApproveTimesheetSchema>
export type RejectTimesheet = z.infer<typeof RejectTimesheetSchema>
export type TimesheetReport = z.infer<typeof TimesheetReportSchema>
export type LaborCostSummary = z.infer<typeof LaborCostSummarySchema>