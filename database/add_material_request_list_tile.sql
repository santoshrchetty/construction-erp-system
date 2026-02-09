-- Check tiles table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'tiles' 
ORDER BY ordinal_position;

-- Check existing tiles to understand the pattern
SELECT id, title, module_code, subtitle, construction_action, tile_category, sequence_order, icon, route
FROM tiles 
WHERE tile_category = 'MATERIALS' 
LIMIT 3;

-- Add Material Request List tile with all required fields
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
  'Material Request List',
  'View and manage material requests',
  'file-text',
  'MAT',
  'View List',
  '/materials',
  'MATERIALS',
  10,
  'MAT_REQ_READ',
  true,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  NOW(),
  NOW()
) ON CONFLICT DO NOTHING;

-- Verify the tile was added
SELECT id, title, module_code, subtitle, construction_action, tile_category, auth_object
FROM tiles 
WHERE title = 'Material Request List';