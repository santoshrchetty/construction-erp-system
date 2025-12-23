import { z } from 'zod'

export const FIFOLayerSchema = z.object({
  id: z.string().uuid(),
  store_id: z.string().uuid(),
  stock_item_id: z.string().uuid(),
  batch_reference: z.string(),
  receipt_date: z.string().datetime(),
  original_quantity: z.number().positive(),
  remaining_quantity: z.number().min(0),
  unit_cost: z.number().positive(),
  grn_line_id: z.string().uuid().nullable(),
  created_at: z.string().datetime()
})

export const EnhancedStoreSchema = z.object({
  id: z.string().uuid(),
  project_id: z.string().uuid(),
  name: z.string().min(1),
  code: z.string().min(1),
  location: z.string().nullable(),
  store_keeper_id: z.string().uuid().nullable(),
  site_code: z.string().max(10).nullable(),
  is_auto_created: z.boolean().default(false),
  auto_delete_when_empty: z.boolean().default(true),
  is_active: z.boolean().default(true),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime()
})

export const StockIssueSchema = z.object({
  store_id: z.string().uuid(),
  stock_item_id: z.string().uuid(),
  quantity: z.number().positive(),
  reference_number: z.string().min(1),
  reference_type: z.string().min(1),
  reference_id: z.string().uuid().optional(),
  movement_date: z.string().date(),
  created_by: z.string().uuid(),
  notes: z.string().optional()
})

export const StockTransferSchema = z.object({
  from_store_id: z.string().uuid(),
  to_store_id: z.string().uuid(),
  stock_item_id: z.string().uuid(),
  quantity: z.number().positive(),
  reference_number: z.string().min(1),
  created_by: z.string().uuid(),
  notes: z.string().optional()
})

export const FIFOStockBalanceSchema = z.object({
  store_id: z.string().uuid(),
  stock_item_id: z.string().uuid(),
  current_quantity: z.number().min(0),
  reserved_quantity: z.number().min(0),
  available_quantity: z.number().min(0),
  fifo_average_cost: z.number().min(0),
  fifo_total_value: z.number().min(0),
  last_movement_date: z.string().datetime().nullable()
})

export const SiteProjectSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  code: z.string().min(1),
  site_code: z.string().max(10).nullable(),
  site_name: z.string().nullable(),
  location: z.string().nullable()
})

export type FIFOLayer = z.infer<typeof FIFOLayerSchema>
export type EnhancedStore = z.infer<typeof EnhancedStoreSchema>
export type StockIssue = z.infer<typeof StockIssueSchema>
export type StockTransfer = z.infer<typeof StockTransferSchema>
export type FIFOStockBalance = z.infer<typeof FIFOStockBalanceSchema>
export type SiteProject = z.infer<typeof SiteProjectSchema>