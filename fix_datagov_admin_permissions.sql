-- Fix: Assign new DG permissions to DataGov Admin role
-- Since user has DataGov Admin role, not Internal User

-- 1. Create the auth objects if missing
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

-- 2. Check table structure first
SELECT 'TABLE STRUCTURE' as check_type, column_name, is_nullable, data_type
FROM information_schema.columns 
WHERE table_name = 'role_authorization_objects';

-- 3. Grant to DataGov Admin role with field_values
INSERT INTO role_authorization_objects (tenant_id, role_id, auth_object_id, field_values)
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  r.id,
  ao.id,
  '{}' as field_values  -- Empty JSON object
FROM roles r
CROSS JOIN authorization_objects ao
WHERE r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.name = 'DataGov Admin'
AND ao.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND ao.object_name IN ('Z_DG_RECORDS_DISPLAY', 'Z_DG_RECORDS_CREATE', 'Z_DG_RECORDS_CHANGE')
AND NOT EXISTS (
  SELECT 1 FROM role_authorization_objects 
  WHERE role_id = r.id 
  AND auth_object_id = ao.id
);

-- 4. Update tiles to use correct auth objects
UPDATE tiles 
SET auth_object = CASE 
  WHEN title = 'Find Document' THEN 'Z_DG_RECORDS_DISPLAY'
  WHEN title = 'Create Document' THEN 'Z_DG_RECORDS_CREATE'
  WHEN title = 'Change Document' THEN 'Z_DG_RECORDS_CHANGE'
END
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module_code = 'DG'
AND title IN ('Find Document', 'Create Document', 'Change Document');

-- 5. Verify
SELECT 'FINAL CHECK' as status, title, auth_object, is_active 
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module_code = 'DG'
ORDER BY sequence_order;