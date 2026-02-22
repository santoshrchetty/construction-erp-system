-- Add Admin Dashboard tile
INSERT INTO tiles (
  id,
  title,
  subtitle,
  icon,
  module_code,
  construction_action,
  route,
  tile_category,
  sequence_order,
  auth_object,
  is_active,
  tenant_id,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  'Admin Dashboard',
  'System overview and analytics',
  'bar-chart-3',
  'ADMIN',
  'admin-dashboard',
  '/dashboard',
  'Administration',
  1,
  'ADMIN_DASHBOARD',
  true,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  NOW(),
  NOW()
) ON CONFLICT (construction_action) DO UPDATE SET
  route = '/dashboard',
  updated_at = NOW();

-- Verify the tile was added
SELECT id, title, subtitle, route, tile_category, auth_object
FROM tiles 
WHERE title = 'Admin Dashboard';
