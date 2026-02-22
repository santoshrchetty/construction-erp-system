-- Assign DataGov Admin role to all remaining users

-- 1. Show all users who don't have DataGov Admin role yet
SELECT 'USERS WITHOUT DATAGOV ADMIN' as check_type, u.email, 
       STRING_AGG(r.name, ', ') as current_roles
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND u.id NOT IN (
  SELECT DISTINCT ur2.user_id 
  FROM user_roles ur2 
  JOIN roles r2 ON ur2.role_id = r2.id 
  WHERE r2.name = 'DataGov Admin' 
  AND r2.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
)
GROUP BY u.email, u.id
ORDER BY u.email;

-- 2. Assign DataGov Admin role to ALL remaining users
INSERT INTO user_roles (user_id, role_id, tenant_id)
SELECT 
  u.id as user_id,
  r.id as role_id,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' as tenant_id
FROM users u
CROSS JOIN roles r
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.name = 'DataGov Admin'
AND NOT EXISTS (
  SELECT 1 FROM user_roles ur2 
  WHERE ur2.user_id = u.id 
  AND ur2.role_id = r.id
);

-- 3. Verify ALL users now have DataGov Admin role
SELECT 'ALL USERS WITH DATAGOV ADMIN' as check_type, 
       u.email,
       r.name as role_name
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
WHERE r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.name = 'DataGov Admin'
ORDER BY u.email;

-- 4. Show total count
SELECT 'TOTAL COUNT' as check_type, 
       COUNT(DISTINCT u.id) as users_with_datagov_admin
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
WHERE r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.name = 'DataGov Admin';