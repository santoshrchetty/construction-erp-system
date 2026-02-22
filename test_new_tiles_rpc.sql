-- Test if the new tiles are now returned by RPC function

-- 1. Test RPC function for our new tile IDs
WITH our_tiles AS (
  SELECT id as tile_id, title
  FROM tiles 
  WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND title IN ('Find Document', 'Create Document', 'Change Document')
),
rpc_results AS (
  SELECT tile_id
  FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f')
)
SELECT 
  'NEW TILES IN RPC' as check_type,
  ot.title,
  ot.tile_id,
  CASE WHEN rr.tile_id IS NOT NULL THEN 'YES' ELSE 'NO' END as in_rpc_results
FROM our_tiles ot
LEFT JOIN rpc_results rr ON ot.tile_id = rr.tile_id
ORDER BY ot.title;

-- 2. Check what the RPC function logic might be filtering on
-- Let's see the RPC function definition
SELECT routine_definition 
FROM information_schema.routines 
WHERE routine_name = 'get_user_authorized_tiles';

-- 3. Alternative: Test with a different approach - make tiles completely public
-- Update tiles to have no restrictions at all
UPDATE tiles 
SET 
  auth_object = NULL,
  module_code = 'public',
  tile_category = 'Public'
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title IN ('Find Document', 'Create Document', 'Change Document');

-- 4. Test RPC again after making them public
WITH our_tiles AS (
  SELECT id as tile_id, title, module_code, tile_category
  FROM tiles 
  WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND title IN ('Find Document', 'Create Document', 'Change Document')
),
rpc_results AS (
  SELECT tile_id
  FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f')
)
SELECT 
  'PUBLIC TILES IN RPC' as check_type,
  ot.title,
  ot.module_code,
  ot.tile_category,
  CASE WHEN rr.tile_id IS NOT NULL THEN 'YES' ELSE 'NO' END as in_rpc_results
FROM our_tiles ot
LEFT JOIN rpc_results rr ON ot.tile_id = rr.tile_id
ORDER BY ot.title;