-- Fix our tiles to match the exact structure of working tiles

-- 1. Update our tiles with missing fields
UPDATE tiles 
SET 
  construction_action = CASE 
    WHEN title = 'Find Document' THEN 'find-document'
    WHEN title = 'Create Document' THEN 'create-document'
    WHEN title = 'Change Document' THEN 'change-document'
  END,
  color = CASE 
    WHEN title = 'Find Document' THEN 'bg-blue-500'
    WHEN title = 'Create Document' THEN 'bg-green-500'
    WHEN title = 'Change Document' THEN 'bg-orange-500'
  END,
  module_code = 'DG-RECORDS',
  tile_category = 'Document Governance'
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title IN ('Find Document', 'Create Document', 'Change Document');

-- 2. Verify the update
SELECT 'UPDATED TILES' as check_type, 
       id, title, construction_action, color, module_code, tile_category, auth_object
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title IN ('Find Document', 'Create Document', 'Change Document')
ORDER BY sequence_order;

-- 3. Test if they now appear in RPC
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
  'TILES IN RPC AFTER UPDATE' as check_type,
  ot.title,
  CASE WHEN rr.tile_id IS NOT NULL THEN 'YES' ELSE 'NO' END as in_rpc_results
FROM our_tiles ot
LEFT JOIN rpc_results rr ON ot.tile_id = rr.tile_id
ORDER BY ot.title;