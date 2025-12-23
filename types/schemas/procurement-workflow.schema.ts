import { z } from 'zod'

// Purchase Requisition Schemas
export const CreatePurchaseRequisitionSchema = z.object({
  project_id: z.string().uuid('Invalid project ID'),
  requested_by: z.string().uuid('Invalid user ID'),
  department: z.string().optional(),
  priority: z.number().min(1).max(5).default(3),
  required_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid date'),
  justification: z.string().optional(),
  lines: z.array(z.object({
    description: z.string().min(1, 'Description is required'),
    specification: z.string().optional(),
    quantity: z.number().positive('Quantity must be positive'),
    unit: z.string().min(1, 'Unit is required'),
    estimated_unit_cost: z.number().nonnegative().optional(),
    cost_object_id: z.string().uuid().optional(),
    preferred_vendor_id: z.string().uuid().optional(),
    urgency_level: z.number().min(1).max(5).default(3)
  })).min(1, 'At least one line item is required')
})

export const UpdatePRStatusSchema = z.object({
  pr_id: z.string().uuid(),
  status: z.enum(['draft', 'submitted', 'approved', 'rejected', 'converted_to_po']),
  approved_by: z.string().uuid().optional(),
  rejection_reason: z.string().optional()
})

// Vendor Quotation Schemas
export const CreateVendorQuotationSchema = z.object({
  pr_line_id: z.string().uuid(),
  vendor_id: z.string().uuid(),
  quotation_number: z.string().optional(),
  quoted_price: z.number().positive('Price must be positive'),
  delivery_days: z.number().nonnegative().optional(),
  validity_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid date').optional(),
  terms_conditions: z.string().optional()
})

export const SelectVendorQuotationSchema = z.object({
  quotation_id: z.string().uuid(),
  pr_line_id: z.string().uuid(),
  selection_reason: z.string().optional()
})

// Subcontract Order Schemas
export const CreateSubcontractOrderSchema = z.object({
  project_id: z.string().uuid(),
  vendor_id: z.string().uuid(),
  work_description: z.string().min(1, 'Work description is required'),
  contract_value: z.number().positive('Contract value must be positive'),
  start_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid start date'),
  completion_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid completion date'),
  retention_percentage: z.number().min(0).max(100).default(5),
  advance_percentage: z.number().min(0).max(100).default(0),
  payment_terms: z.string().optional(),
  performance_bond_required: z.boolean().default(false),
  created_by: z.string().uuid(),
  milestones: z.array(z.object({
    milestone_name: z.string().min(1, 'Milestone name is required'),
    description: z.string().optional(),
    planned_completion_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid date'),
    milestone_value: z.number().positive('Milestone value must be positive'),
    sequence_order: z.number().positive('Sequence order must be positive')
  })).optional()
}).refine((data) => {
  const startDate = new Date(data.start_date)
  const completionDate = new Date(data.completion_date)
  return completionDate > startDate
}, {
  message: 'Completion date must be after start date',
  path: ['completion_date']
})

export const UpdateSubcontractStatusSchema = z.object({
  subcontract_id: z.string().uuid(),
  status: z.enum(['draft', 'pending_approval', 'approved', 'active', 'completed', 'terminated']),
  approved_by: z.string().uuid().optional(),
  termination_reason: z.string().optional()
})

export const UpdateMilestoneSchema = z.object({
  milestone_id: z.string().uuid(),
  actual_completion_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid date').optional(),
  completion_percentage: z.number().min(0).max(100),
  is_completed: z.boolean().default(false)
})

// Goods Receipt Schemas
export const CreateGoodsReceiptSchema = z.object({
  po_id: z.string().uuid(),
  store_id: z.string().uuid(),
  receipt_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid receipt date'),
  received_by: z.string().uuid(),
  delivery_note_number: z.string().optional(),
  vehicle_number: z.string().optional(),
  supplier_invoice_number: z.string().optional(),
  lines: z.array(z.object({
    po_line_id: z.string().uuid(),
    ordered_quantity: z.number().positive(),
    received_quantity: z.number().nonnegative(),
    accepted_quantity: z.number().nonnegative(),
    rejected_quantity: z.number().nonnegative().default(0),
    unit_rate: z.number().positive(),
    rejection_reason: z.string().optional(),
    batch_number: z.string().optional(),
    expiry_date: z.string().optional()
  })).min(1, 'At least one line item is required')
}).refine((data) => {
  return data.lines.every(line => 
    line.received_quantity === line.accepted_quantity + line.rejected_quantity
  )
}, {
  message: 'Received quantity must equal accepted + rejected quantities',
  path: ['lines']
})

export const QualityCheckSchema = z.object({
  grn_id: z.string().uuid(),
  quality_status: z.enum(['pending', 'passed', 'failed', 'conditional']),
  quality_notes: z.string().optional(),
  checked_by: z.string().uuid(),
  quality_parameters: z.array(z.object({
    parameter_name: z.string(),
    expected_value: z.string(),
    actual_value: z.string(),
    status: z.enum(['pass', 'fail', 'acceptable'])
  })).optional()
})

// Cost Posting Schemas
export const ManualCostPostingSchema = z.object({
  cost_object_id: z.string().uuid(),
  transaction_type: z.enum(['planned', 'committed', 'actual', 'accrued']),
  amount: z.number(),
  reference_type: z.string().min(1),
  reference_id: z.string().uuid(),
  transaction_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid date'),
  description: z.string().min(1, 'Description is required'),
  created_by: z.string().uuid()
})

export const CostAdjustmentSchema = z.object({
  cost_object_id: z.string().uuid(),
  adjustment_amount: z.number(),
  adjustment_reason: z.string().min(1, 'Reason is required'),
  reference_document: z.string().optional(),
  approved_by: z.string().uuid(),
  adjustment_date: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid date')
})

// Vendor Performance Schemas
export const VendorPerformanceSchema = z.object({
  vendor_id: z.string().uuid(),
  evaluation_period_start: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid date'),
  evaluation_period_end: z.string().refine((date) => !isNaN(Date.parse(date)), 'Invalid date'),
  quality_rating: z.number().min(1).max(5),
  delivery_rating: z.number().min(1).max(5),
  service_rating: z.number().min(1).max(5),
  price_competitiveness: z.number().min(1).max(5),
  overall_rating: z.number().min(1).max(5),
  comments: z.string().optional(),
  evaluated_by: z.string().uuid()
})

// Purchase Order Amendment Schemas
export const POAmendmentSchema = z.object({
  po_id: z.string().uuid(),
  amendment_type: z.enum(['quantity_change', 'price_change', 'delivery_date_change', 'specification_change']),
  amendment_reason: z.string().min(1, 'Reason is required'),
  line_amendments: z.array(z.object({
    po_line_id: z.string().uuid(),
    field_name: z.string(),
    old_value: z.string(),
    new_value: z.string()
  })),
  requested_by: z.string().uuid(),
  vendor_approval_required: z.boolean().default(true)
})

// Type exports for use in components
export type CreatePurchaseRequisition = z.infer<typeof CreatePurchaseRequisitionSchema>
export type CreateVendorQuotation = z.infer<typeof CreateVendorQuotationSchema>
export type CreateSubcontractOrder = z.infer<typeof CreateSubcontractOrderSchema>
export type CreateGoodsReceipt = z.infer<typeof CreateGoodsReceiptSchema>
export type QualityCheck = z.infer<typeof QualityCheckSchema>
export type ManualCostPosting = z.infer<typeof ManualCostPostingSchema>
export type VendorPerformance = z.infer<typeof VendorPerformanceSchema>