// import { z } from 'zod' // Removed - not using Zod validation

export const TenantSchema = z.object({
  id: z.string().uuid(),
  tenant_code: z.string().min(1).max(10),
  tenant_name: z.string().min(1).max(100),
  subdomain: z.string().min(1).max(50).optional(),
  is_active: z.boolean().default(true),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime()
})

export const UserTenantSchema = z.object({
  id: z.string().uuid(),
  user_id: z.string().uuid(),
  tenant_id: z.string().uuid(),
  is_active: z.boolean().default(true),
  role: z.string().max(50).default('user'),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime()
})

export const CreateTenantSchema = TenantSchema.omit({
  id: true,
  created_at: true,
  updated_at: true
}).partial({
  is_active: true
})

export const CreateUserTenantSchema = UserTenantSchema.omit({
  id: true,
  created_at: true,
  updated_at: true
}).partial({
  is_active: true,
  role: true
})

export const UpdateTenantSchema = CreateTenantSchema.partial()
export const UpdateUserTenantSchema = CreateUserTenantSchema.partial()

export type Tenant = z.infer<typeof TenantSchema>
export type UserTenant = z.infer<typeof UserTenantSchema>
export type CreateTenant = z.infer<typeof CreateTenantSchema>
export type CreateUserTenant = z.infer<typeof CreateUserTenantSchema>
export type UpdateTenant = z.infer<typeof UpdateTenantSchema>
export type UpdateUserTenant = z.infer<typeof UpdateUserTenantSchema>
