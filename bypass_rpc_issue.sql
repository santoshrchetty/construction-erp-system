-- Bypass RPC function issue by examining and potentially recreating it

-- 1. Get the RPC function definition to understand the logic
SELECT routine_definition 
FROM information_schema.routines 
WHERE routine_name = 'get_user_authorized_tiles';

-- 2. Check what makes other tiles work - compare with working tiles
SELECT 'WORKING TILE EXAMPLE' as check_type, 
       id, title, module_code, tile_category, auth_object, is_active,
       created_at, updated_at
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title = 'Drawing Management'  -- This one works
LIMIT 1;

-- 3. Compare with our tiles
SELECT 'OUR TILES' as check_type,
       id, title, module_code, tile_category, auth_object, is_active,
       created_at, updated_at
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title IN ('Find Document', 'Create Document', 'Change Document')
ORDER BY title;

-- 4. Alternative approach: Copy the exact structure of a working tile
-- Let's copy the Drawing Management tile structure
INSERT INTO tiles (
  tenant_id, title, subtitle, icon, color, route, auth_object, 
  module_code, tile_category, sequence_order, is_active,
  created_at, updated_at
)
SELECT 
  tenant_id,
  'Test Document Tile' as title,
  'Test tile to see if it works' as subtitle,
  icon,
  color,
  '/test-route' as route,
  auth_object,
  module_code,
  tile_category,
  999 as sequence_order,
  is_active,
  NOW() as created_at,
  NOW() as updated_at
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title = 'Drawing Management'
LIMIT 1;

-- 5. Test if the copied tile appears in RPC
SELECT 'TEST TILE IN RPC' as check_type, tile_id
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f') rpc
JOIN tiles t ON rpc.tile_id = t.id
WHERE t.title = 'Test Document Tile';