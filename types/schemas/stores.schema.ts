import { z } from 'zod'

export const StoreSchema = z.object({
  id: z.string().uuid(),
  tenant_id: z.string().uuid(),
  project_id: z.string().uuid(),
  name: z.string().min(1).max(255),
  code: z.string().min(1).max(50),
  location: z.string().nullable(),
  store_keeper_id: z.string().uuid().nullable(),
  is_active: z.boolean().default(true),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime()
})

export const StockItemSchema = z.object({
  id: z.string().uuid(),
  tenant_id: z.string().uuid(),
  item_code: z.string().min(1).max(50),
  description: z.string().min(1),
  category: z.string().max(100).nullable(),
  unit: z.string().min(1).max(20),
  reorder_level: z.number().min(0).default(0),
  maximum_level: z.number().min(0).default(0),
  minimum_level: z.number().min(0).default(0),
  is_active: z.boolean().default(true),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime()
})

export const StockBalanceSchema = z.object({
  id: z.string().uuid(),
  tenant_id: z.string().uuid(),
  store_id: z.string().uuid(),
  stock_item_id: z.string().uuid(),
  current_quantity: z.number().min(0).default(0),
  reserved_quantity: z.number().min(0).default(0),
  available_quantity: z.number().min(0),
  average_cost: z.number().min(0).default(0),
  total_value: z.number().min(0),
  last_movement_date: z.string().datetime().nullable()
})

export const StockMovementSchema = z.object({
  id: z.string().uuid(),
  tenant_id: z.string().uuid(),
  store_id: z.string().uuid(),
  stock_item_id: z.string().uuid(),
  movement_type: z.enum(['receipt', 'issue', 'return', 'transfer', 'adjustment', 'write_off']),
  reference_number: z.string().min(1).max(100),
  reference_type: z.string().min(1).max(50),
  reference_id: z.string().uuid().nullable(),
  quantity: z.number().positive(),
  unit_cost: z.number().positive(),
  total_cost: z.number().positive(),
  movement_date: z.string().date(),
  created_by: z.string().uuid(),
  notes: z.string().nullable(),
  created_at: z.string().datetime()
})

export const CreateStoreSchema = StoreSchema.omit({
  id: true,
  tenant_id: true,
  created_at: true,
  updated_at: true
}).partial({
  location: true,
  store_keeper_id: true,
  is_active: true
})

export const CreateStockItemSchema = StockItemSchema.omit({
  id: true,
  tenant_id: true,
  created_at: true,
  updated_at: true
}).partial({
  category: true,
  reorder_level: true,
  maximum_level: true,
  minimum_level: true,
  is_active: true
})

export const CreateStockMovementSchema = StockMovementSchema.omit({
  id: true,
  tenant_id: true,
  total_cost: true,
  created_at: true
}).partial({
  reference_id: true,
  notes: true
})

export const UpdateStoreSchema = CreateStoreSchema.partial()
export const UpdateStockItemSchema = CreateStockItemSchema.partial()

export type Store = z.infer<typeof StoreSchema>
export type StockItem = z.infer<typeof StockItemSchema>
export type StockBalance = z.infer<typeof StockBalanceSchema>
export type StockMovement = z.infer<typeof StockMovementSchema>
export type CreateStore = z.infer<typeof CreateStoreSchema>
export type CreateStockItem = z.infer<typeof CreateStockItemSchema>
export type CreateStockMovement = z.infer<typeof CreateStockMovementSchema>
export type UpdateStore = z.infer<typeof UpdateStoreSchema>
export type UpdateStockItem = z.infer<typeof UpdateStockItemSchema>