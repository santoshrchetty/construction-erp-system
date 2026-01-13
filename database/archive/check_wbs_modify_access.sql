-- Check if PS_WBS_MODIFY auth object exists and admin has access
-- ==============================================================

-- Check if PS_WBS_MODIFY authorization object exists
SELECT 'AUTH OBJECT CHECK' as check_type, object_name, description, module
FROM authorization_objects 
WHERE object_name = 'PS_WBS_MODIFY';

-- Check if admin role has PS_WBS_MODIFY permission
SELECT 'ROLE PERMISSION CHECK' as check_type, r.name as role_name, ram.auth_object_name
FROM roles r
JOIN role_authorization_mapping ram ON r.id = ram.role_id
WHERE ram.auth_object_name = 'PS_WBS_MODIFY'
AND r.name = 'Admin';

-- Check admin user's role assignment
SELECT 'USER ROLE CHECK' as check_type, u.email, r.name as role_name
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
WHERE u.email = 'admin@nttdemo.com';