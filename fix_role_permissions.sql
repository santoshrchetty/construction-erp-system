-- Fix: Assign DG permissions to existing user roles
-- Since users have Admin, Manager, Engineer roles (not DataGov Admin)

-- 1. First, ensure auth objects exist
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

-- 2. Grant to Admin role (full access)
INSERT INTO role_authorization_objects (tenant_id, role_id, auth_object_id, field_values)
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  r.id,
  ao.id,
  '{}' as field_values
FROM roles r
CROSS JOIN authorization_objects ao
WHERE r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.name = 'Admin'
AND ao.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND ao.object_name IN ('Z_DG_RECORDS_DISPLAY', 'Z_DG_RECORDS_CREATE', 'Z_DG_RECORDS_CHANGE')
AND NOT EXISTS (
  SELECT 1 FROM role_authorization_objects 
  WHERE role_id = r.id AND auth_object_id = ao.id
);

-- 3. Grant to Manager role (full access)
INSERT INTO role_authorization_objects (tenant_id, role_id, auth_object_id, field_values)
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  r.id,
  ao.id,
  '{}' as field_values
FROM roles r
CROSS JOIN authorization_objects ao
WHERE r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.name = 'Manager'
AND ao.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND ao.object_name IN ('Z_DG_RECORDS_DISPLAY', 'Z_DG_RECORDS_CREATE', 'Z_DG_RECORDS_CHANGE')
AND NOT EXISTS (
  SELECT 1 FROM role_authorization_objects 
  WHERE role_id = r.id AND auth_object_id = ao.id
);

-- 4. Grant to Engineer role (display and create only)
INSERT INTO role_authorization_objects (tenant_id, role_id, auth_object_id, field_values)
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  r.id,
  ao.id,
  '{}' as field_values
FROM roles r
CROSS JOIN authorization_objects ao
WHERE r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.name = 'Engineer'
AND ao.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND ao.object_name IN ('Z_DG_RECORDS_DISPLAY', 'Z_DG_RECORDS_CREATE')
AND NOT EXISTS (
  SELECT 1 FROM role_authorization_objects 
  WHERE role_id = r.id AND auth_object_id = ao.id
);

-- 5. Update tiles to use correct auth objects
UPDATE tiles 
SET auth_object = CASE 
  WHEN title = 'Find Document' THEN 'Z_DG_RECORDS_DISPLAY'
  WHEN title = 'Create Document' THEN 'Z_DG_RECORDS_CREATE'
  WHEN title = 'Change Document' THEN 'Z_DG_RECORDS_CHANGE'
END
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module_code = 'DG'
AND title IN ('Find Document', 'Create Document', 'Change Document');

-- 6. Verify the setup
SELECT 
  'VERIFICATION' as check_type,
  t.title,
  t.auth_object,
  r.name as role_name,
  COUNT(*) as user_count
FROM tiles t
JOIN authorization_objects ao ON t.auth_object = ao.object_name
JOIN role_authorization_objects rao ON ao.id = rao.auth_object_id
JOIN roles r ON rao.role_id = r.id
JOIN user_roles ur ON r.id = ur.role_id
WHERE t.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND t.module_code = 'DG'
GROUP BY t.title, t.auth_object, r.name
ORDER BY t.title, r.name;