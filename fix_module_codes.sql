-- Fix: Update module codes for new DG tiles to match existing pattern

-- 1. Check current DG tiles with module codes
SELECT 'CURRENT DG TILES' as check_type, title, module_code, auth_object
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title IN ('Find Document', 'Create Document', 'Change Document')
ORDER BY sequence_order;

-- 2. Update the module codes to match existing pattern
UPDATE tiles 
SET module_code = CASE 
  WHEN title = 'Find Document' THEN 'DG-RECORDS'
  WHEN title = 'Create Document' THEN 'DG-RECORDS'
  WHEN title = 'Change Document' THEN 'DG-RECORDS'
END
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title IN ('Find Document', 'Create Document', 'Change Document');

-- 3. Verify the update
SELECT 'UPDATED DG TILES' as check_type, title, module_code, auth_object, is_active
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title IN ('Find Document', 'Create Document', 'Change Document')
ORDER BY sequence_order;

-- 4. Test if user can now see these tiles
SELECT 
  'USER ACCESS TEST' as check_type,
  t.title,
  t.module_code,
  t.auth_object
FROM tiles t
JOIN authorization_objects ao ON t.auth_object = ao.object_name
JOIN role_authorization_objects rao ON ao.id = rao.auth_object_id
JOIN roles r ON rao.role_id = r.id
JOIN user_roles ur ON r.id = ur.role_id
JOIN users u ON ur.user_id = u.id
WHERE u.email = 'admin@nttdemo.com'
AND u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND t.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND t.is_active = true
AND t.title IN ('Find Document', 'Create Document', 'Change Document')
ORDER BY t.sequence_order;