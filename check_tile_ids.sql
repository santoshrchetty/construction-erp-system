-- Find our new tile IDs and check if they're in RPC results

-- 1. Get the IDs of our new tiles
SELECT 'OUR TILE IDS' as check_type, id, title, auth_object, is_active
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title IN ('Find Document', 'Create Document', 'Change Document')
ORDER BY sequence_order;

-- 2. Check if these specific tile IDs are in the RPC results
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
  'TILE IN RPC CHECK' as check_type,
  ot.title,
  ot.tile_id,
  CASE WHEN rr.tile_id IS NOT NULL THEN 'YES' ELSE 'NO' END as in_rpc_results
FROM our_tiles ot
LEFT JOIN rpc_results rr ON ot.tile_id = rr.tile_id
ORDER BY ot.title;

-- 3. Now remove auth_object to test if that's the issue
UPDATE tiles 
SET auth_object = NULL
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title IN ('Find Document', 'Create Document', 'Change Document');

-- 4. Test RPC again after removing auth_object
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
  'AFTER REMOVING AUTH' as check_type,
  ot.title,
  ot.tile_id,
  CASE WHEN rr.tile_id IS NOT NULL THEN 'YES' ELSE 'NO' END as in_rpc_results
FROM our_tiles ot
LEFT JOIN rpc_results rr ON ot.tile_id = rr.tile_id
ORDER BY ot.title;