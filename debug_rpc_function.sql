-- Debug: Check RPC function and authorization flow

-- 1. Check if RPC function exists
SELECT routine_name, routine_definition 
FROM information_schema.routines 
WHERE routine_name = 'get_user_authorized_tiles';

-- 2. Test the RPC function directly (replace with your user ID)
-- SELECT * FROM get_user_authorized_tiles('your-user-id-here');

-- 3. Check what the function should return for DG tiles
SELECT 
  t.id as tile_id,
  t.title,
  t.auth_object,
  ao.object_name,
  rao.role_id,
  r.name as role_name
FROM tiles t
LEFT JOIN authorization_objects ao ON t.auth_object = ao.object_name
LEFT JOIN role_authorization_objects rao ON ao.id = rao.auth_object_id
LEFT JOIN roles r ON rao.role_id = r.id
WHERE t.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND t.module_code = 'DG'
AND t.title IN ('Find Document', 'Create Document', 'Change Document');

-- 4. Check user roles (replace with your user email)
SELECT u.id, u.email, r.name as role_name
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
-- AND u.email = 'your-email@example.com'  -- Uncomment and add your email
ORDER BY u.email;