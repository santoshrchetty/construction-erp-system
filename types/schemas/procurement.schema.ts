import { z } from 'zod'

export const VendorStatusEnum = z.enum(['active', 'inactive', 'blacklisted'])
export const POStatusEnum = z.enum(['draft', 'pending_approval', 'approved', 'sent', 'acknowledged', 'partially_received', 'fully_received', 'cancelled'])
export const POTypeEnum = z.enum(['standard', 'blanket', 'contract', 'emergency'])

export const VendorSchema = z.object({
  id: z.string().uuid(),
  tenant_id: z.string().uuid(),
  name: z.string().min(1).max(255),
  code: z.string().min(1).max(50),
  contact_person: z.string().max(255).nullable(),
  email: z.string().email().nullable(),
  phone: z.string().max(50).nullable(),
  address: z.string().nullable(),
  tax_id: z.string().max(50).nullable(),
  status: VendorStatusEnum.default('active'),
  credit_limit: z.number().min(0).default(0),
  payment_terms: z.string().max(100).nullable(),
  specializations: z.array(z.string()).nullable(),
  rating: z.number().min(0).max(5).default(0),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime()
})

export const PurchaseOrderSchema = z.object({
  id: z.string().uuid(),
  tenant_id: z.string().uuid(),
  project_id: z.string().uuid(),
  po_number: z.string().min(1).max(50),
  vendor_id: z.string().uuid(),
  po_type: POTypeEnum.default('standard'),
  status: POStatusEnum.default('draft'),
  issue_date: z.string().date(),
  delivery_date: z.string().date(),
  total_amount: z.number().positive(),
  tax_amount: z.number().min(0).default(0),
  grand_total: z.number().positive(),
  payment_terms: z.string().max(100).nullable(),
  delivery_terms: z.string().nullable(),
  created_by: z.string().uuid(),
  approved_by: z.string().uuid().nullable(),
  approved_date: z.string().datetime().nullable(),
  notes: z.string().nullable(),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime()
})

export const POLineSchema = z.object({
  id: z.string().uuid(),
  tenant_id: z.string().uuid(),
  po_id: z.string().uuid(),
  line_number: z.number().int().positive(),
  boq_item_id: z.string().uuid().nullable(),
  description: z.string().min(1),
  specification: z.string().nullable(),
  quantity: z.number().positive(),
  unit: z.string().min(1).max(20),
  unit_rate: z.number().positive(),
  line_total: z.number().positive(),
  received_quantity: z.number().min(0).default(0),
  pending_quantity: z.number().min(0),
  delivery_date: z.string().date().nullable()
})

export const CreateVendorSchema = VendorSchema.omit({
  id: true,
  tenant_id: true,
  created_at: true,
  updated_at: true
}).partial({
  contact_person: true,
  email: true,
  phone: true,
  address: true,
  tax_id: true,
  status: true,
  credit_limit: true,
  payment_terms: true,
  specializations: true,
  rating: true
})

export const CreatePurchaseOrderSchema = PurchaseOrderSchema.omit({
  id: true,
  tenant_id: true,
  grand_total: true,
  created_at: true,
  updated_at: true
}).partial({
  po_type: true,
  status: true,
  tax_amount: true,
  payment_terms: true,
  delivery_terms: true,
  approved_by: true,
  approved_date: true,
  notes: true
})

export const CreatePOLineSchema = POLineSchema.omit({
  id: true,
  tenant_id: true,
  line_total: true,
  received_quantity: true,
  pending_quantity: true
}).partial({
  boq_item_id: true,
  specification: true,
  delivery_date: true
})

export const UpdateVendorSchema = CreateVendorSchema.partial()
export const UpdatePurchaseOrderSchema = CreatePurchaseOrderSchema.partial()
export const UpdatePOLineSchema = CreatePOLineSchema.partial()

export type Vendor = z.infer<typeof VendorSchema>
export type PurchaseOrder = z.infer<typeof PurchaseOrderSchema>
export type POLine = z.infer<typeof POLineSchema>
export type CreateVendor = z.infer<typeof CreateVendorSchema>
export type CreatePurchaseOrder = z.infer<typeof CreatePurchaseOrderSchema>
export type CreatePOLine = z.infer<typeof CreatePOLineSchema>
export type UpdateVendor = z.infer<typeof UpdateVendorSchema>
export type UpdatePurchaseOrder = z.infer<typeof UpdatePurchaseOrderSchema>
export type UpdatePOLine = z.infer<typeof UpdatePOLineSchema>