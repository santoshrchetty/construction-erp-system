-- ============================================================================
-- Check and Create Material Request List Tile
-- ============================================================================

-- Check if Material Request List tile exists
SELECT 
  id,
  title,
  subtitle,
  module_code,
  auth_object,
  route,
  is_active
FROM tiles
WHERE title ILIKE '%material request%list%'
   OR title ILIKE '%request%list%'
   OR auth_object ILIKE '%REQ%LIST%'
ORDER BY title;

-- If not found, create it
INSERT INTO tiles (
  title,
  subtitle,
  icon,
  module_code,
  auth_object,
  route,
  tile_category,
  sequence_order,
  is_active,
  tenant_id
) 
SELECT 
  'Material Request List',
  'View and manage all material requests',
  'list',
  'materials',
  'MM_REQ_LIST',
  '/materials/requests',
  'Materials',
  15,
  true,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid
WHERE NOT EXISTS (
  SELECT 1 FROM tiles 
  WHERE auth_object = 'MM_REQ_LIST'
);

-- Create authorization object if needed
INSERT INTO authorization_objects (object_name, description, module, is_active, tenant_id)
SELECT 
  'MM_REQ_LIST',
  'Material Request List',
  'materials',
  true,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid
WHERE NOT EXISTS (
  SELECT 1 FROM authorization_objects 
  WHERE object_name = 'MM_REQ_LIST'
);

-- Assign to Admin role
INSERT INTO role_authorization_objects (
  role_id,
  auth_object_id,
  field_values,
  object_full_access,
  tenant_id,
  is_active
)
SELECT 
  r.id,
  ao.id,
  '{"ACTVT": ["*"], "COMP_CODE": ["*"], "PLANT": ["*"], "DEPT": ["*"]}'::jsonb,
  true,
  r.tenant_id,
  true
FROM roles r, authorization_objects ao
WHERE r.name = 'Admin'
  AND ao.object_name = 'MM_REQ_LIST'
  AND NOT EXISTS (
    SELECT 1 FROM role_authorization_objects rao
    WHERE rao.role_id = r.id AND rao.auth_object_id = ao.id
  );

-- Verify
SELECT 
  t.title,
  t.auth_object,
  ao.object_name,
  'Tile and Auth Object exist' as status
FROM tiles t
LEFT JOIN authorization_objects ao ON t.auth_object = ao.object_name
WHERE t.auth_object = 'MM_REQ_LIST';
