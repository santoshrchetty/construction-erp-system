-- Debug: Test the exact RPC function call for admin@nttdemo.com

-- 1. Get the user ID for admin@nttdemo.com
SELECT 'USER ID' as check_type, id, email, tenant_id
FROM users 
WHERE email = 'admin@nttdemo.com'
AND tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

-- 2. Test the RPC function directly (replace USER_ID with actual ID from step 1)
-- SELECT * FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f');

-- 3. Check if RPC function exists and its definition
SELECT routine_name, routine_definition 
FROM information_schema.routines 
WHERE routine_name = 'get_user_authorized_tiles';

-- 4. Manual check - what tiles should be returned for this user
SELECT 
  'MANUAL CHECK' as check_type,
  t.id as tile_id,
  t.title,
  t.module_code,
  t.auth_object,
  t.is_active
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
AND t.module_code = 'DG'
ORDER BY t.sequence_order;

-- 5. Check all tiles for this user (not just DG)
SELECT 
  'ALL AUTHORIZED TILES' as check_type,
  t.title,
  t.module_code,
  t.tile_category,
  COUNT(*) as permission_count
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
GROUP BY t.title, t.module_code, t.tile_category
ORDER BY t.tile_category, t.title;