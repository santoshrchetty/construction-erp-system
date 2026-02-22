-- Add Document Governance Record Management tiles
-- These tiles replace the old Drawing Management approach

-- First, deactivate old drawing tiles if they exist
UPDATE tiles 
SET is_active = false 
WHERE module_code = 'DG' 
AND title IN ('Drawing Management', 'Create Drawing')
AND tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

-- Insert new Document Governance tiles
INSERT INTO tiles (tenant_id, title, subtitle, icon, color, route, auth_object, module_code, tile_category, sequence_order, is_active)
VALUES
  -- Find Document
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 
   'Find Document', 
   'Search and view records', 
   'search', 
   'blue', 
   '/document-governance/records/list', 
   'Z_DG_RECORDS_DISPLAY', 
   'DG', 
   'Document Governance', 
   1, 
   true),
  
  -- Create Document
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 
   'Create Document', 
   'Create new record', 
   'plus-circle', 
   'green', 
   '/document-governance/records/new', 
   'Z_DG_RECORDS_CREATE', 
   'DG', 
   'Document Governance', 
   2, 
   true),
  
  -- Change Document
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 
   'Change Document', 
   'Modify existing record', 
   'edit', 
   'orange', 
   '/document-governance/records/change', 
   'Z_DG_RECORDS_CHANGE', 
   'DG', 
   'Document Governance', 
   3, 
   true);

-- Create authorization objects if they don't exist
INSERT INTO authorization_objects (object_name, description, module, tenant_id)
SELECT object_name, description, module, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' as tenant_id
FROM (VALUES
  ('Z_DG_RECORDS_DISPLAY', 'Display Document Records', 'DG'),
  ('Z_DG_RECORDS_CREATE', 'Create Document Records', 'DG'),
  ('Z_DG_RECORDS_CHANGE', 'Change Document Records', 'DG')
) AS t(object_name, description, module)
WHERE NOT EXISTS (
  SELECT 1 FROM authorization_objects 
  WHERE object_name = t.object_name 
  AND tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
);

-- Grant access to internal users
INSERT INTO role_authorization_objects (tenant_id, role_id, auth_object_id)
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  r.id,
  ao.id
FROM roles r
CROSS JOIN authorization_objects ao
WHERE r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.role_name = 'Internal User'
AND ao.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND ao.object_name IN ('Z_DG_RECORDS_DISPLAY', 'Z_DG_RECORDS_CREATE', 'Z_DG_RECORDS_CHANGE')
AND NOT EXISTS (
  SELECT 1 FROM role_authorization_objects 
  WHERE role_id = r.id 
  AND auth_object_id = ao.id
);

-- Verify the tiles
SELECT 
  title, 
  subtitle,
  icon,
  route, 
  auth_object, 
  sequence_order,
  is_active
FROM tiles
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module_code = 'DG'
AND title IN ('Find Document', 'Create Document', 'Change Document')
ORDER BY sequence_order;
