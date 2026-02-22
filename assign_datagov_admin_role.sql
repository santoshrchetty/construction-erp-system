-- Assign users to DataGov Admin role to see DG tiles

-- 1. Show current user roles for reference
SELECT 'CURRENT USER ROLES' as check_type, u.email, r.name as role_name
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY u.email;

-- 2. Get DataGov Admin role ID
SELECT 'DATAGOV ADMIN ROLE ID' as check_type, id, name
FROM roles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND name = 'DataGov Admin';

-- 3. Assign Admin users to DataGov Admin role (they should have access to everything)
INSERT INTO user_roles (user_id, role_id, tenant_id)
SELECT 
  u.id as user_id,
  r.id as role_id,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' as tenant_id
FROM users u
CROSS JOIN roles r
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND u.email IN ('admin@demo.com', 'admin@nttdemo.com')  -- Admin users
AND r.name = 'DataGov Admin'
AND NOT EXISTS (
  SELECT 1 FROM user_roles ur2 
  WHERE ur2.user_id = u.id 
  AND ur2.role_id = r.id
);

-- 4. Assign Manager users to DataGov Admin role
INSERT INTO user_roles (user_id, role_id, tenant_id)
SELECT 
  u.id as user_id,
  r.id as role_id,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' as tenant_id
FROM users u
CROSS JOIN roles r
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND u.email IN ('demo@nttdemo.com', 'manager@nttdemo.com')  -- Manager users
AND r.name = 'DataGov Admin'
AND NOT EXISTS (
  SELECT 1 FROM user_roles ur2 
  WHERE ur2.user_id = u.id 
  AND ur2.role_id = r.id
);

-- 5. Verify the assignments
SELECT 'VERIFICATION' as check_type, 
       u.email,
       r.name as role_name
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
WHERE r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.name = 'DataGov Admin'
ORDER BY u.email;