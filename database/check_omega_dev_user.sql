-- Check OMEGA-DEV user profile
SELECT 
  u.id as user_id,
  u.email,
  u.tenant_id,
  u.role_id,
  r.name as role_name,
  r.tenant_id as role_tenant_id,
  u.first_name,
  u.last_name,
  u.is_active
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
WHERE u.email = 'internaluser@abc.com'
AND u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

-- Check if user profile exists
SELECT 
  up.*
FROM user_profiles up
JOIN users u ON up.user_id = u.id
WHERE u.email = 'internaluser@abc.com'
AND u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';
