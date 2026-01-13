import { z } from 'zod';

// User role enum
export const UserRole = z.enum(['admin', 'project_manager', 'site_engineer', 'foreman', 'worker', 'procurement', 'finance']);
export type UserRole = z.infer<typeof UserRole>;

// User schema
export const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string(),
  role: UserRole,
  is_active: z.boolean().default(true),
  created_at: z.string()
});

// Tile schema
export const TileSchema = z.object({
  id: z.string().uuid(),
  title: z.string(),
  subtitle: z.string().optional(),
  icon: z.string(),
  color: z.string().default('blue'),
  route: z.string(),
  roles: z.array(UserRole),
  sequence_order: z.number().default(0),
  is_active: z.boolean().default(true)
});

// Create schemas
export const CreateUserSchema = UserSchema.omit({ id: true, created_at: true });
export const CreateTileSchema = TileSchema.omit({ id: true });

export type User = z.infer<typeof UserSchema>;
export type Tile = z.infer<typeof TileSchema>;
export type CreateUser = z.infer<typeof CreateUserSchema>;
export type CreateTile = z.infer<typeof CreateTileSchema>;