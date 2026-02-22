-- Final solution: Copy exact structure from working tiles

-- 1. Delete our problematic tiles
DELETE FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title IN ('Find Document', 'Create Document', 'Change Document');

-- 2. Create new tiles by copying the exact structure of "User Management" (which works)
INSERT INTO tiles (
  tenant_id, title, subtitle, icon, color, route, roles, sequence_order, 
  is_active, auth_object, construction_action, module_code, tile_category, 
  created_at, updated_at
)
SELECT 
  tenant_id,
  'Find Document' as title,
  'Search and view document records' as subtitle,
  'search' as icon,
  color,
  '/document-governance/records/list' as route,
  roles,
  1 as sequence_order,
  is_active,
  NULL as auth_object,  -- No auth restriction
  'find-document' as construction_action,
  'DG' as module_code,
  'Document Governance' as tile_category,
  NOW() as created_at,
  NOW() as updated_at
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title = 'User Management'
LIMIT 1;

INSERT INTO tiles (
  tenant_id, title, subtitle, icon, color, route, roles, sequence_order, 
  is_active, auth_object, construction_action, module_code, tile_category, 
  created_at, updated_at
)
SELECT 
  tenant_id,
  'Create Document' as title,
  'Create new document record' as subtitle,
  'plus-circle' as icon,
  'bg-green-500' as color,
  '/document-governance/records/new' as route,
  roles,
  2 as sequence_order,
  is_active,
  NULL as auth_object,  -- No auth restriction
  'create-document' as construction_action,
  'DG' as module_code,
  'Document Governance' as tile_category,
  NOW() as created_at,
  NOW() as updated_at
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title = 'User Management'
LIMIT 1;

INSERT INTO tiles (
  tenant_id, title, subtitle, icon, color, route, roles, sequence_order, 
  is_active, auth_object, construction_action, module_code, tile_category, 
  created_at, updated_at
)
SELECT 
  tenant_id,
  'Change Document' as title,
  'Modify existing document record' as subtitle,
  'edit' as icon,
  'bg-orange-500' as color,
  '/document-governance/records/change' as route,
  roles,
  3 as sequence_order,
  is_active,
  NULL as auth_object,  -- No auth restriction
  'change-document' as construction_action,
  'DG' as module_code,
  'Document Governance' as tile_category,
  NOW() as created_at,
  NOW() as updated_at
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title = 'User Management'
LIMIT 1;

-- 3. Verify they were created
SELECT 'NEW TILES CREATED' as check_type, 
       id, title, construction_action, module_code, tile_category, auth_object
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title IN ('Find Document', 'Create Document', 'Change Document')
ORDER BY sequence_order;

-- 4. Test RPC function
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
  'FINAL RPC TEST' as check_type,
  ot.title,
  CASE WHEN rr.tile_id IS NOT NULL THEN 'YES' ELSE 'NO' END as in_rpc_results
FROM our_tiles ot
LEFT JOIN rpc_results rr ON ot.tile_id = rr.tile_id
ORDER BY ot.title;