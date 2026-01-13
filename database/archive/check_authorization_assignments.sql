-- Check Authorization Objects and Role Assignments
-- ================================================

-- 1. Check if authorization objects exist
SELECT 'Authorization Objects' as table_name, COUNT(*) as count 
FROM authorization_objects;

-- 2. Check if role_authorization_objects table exists
SELECT 'Role Authorization Objects' as table_name, COUNT(*) as count 
FROM role_authorization_objects;

-- 3. List all roles
SELECT 'Roles:' as info, id, name, description 
FROM roles 
ORDER BY name;

-- 4. List all authorization objects
SELECT 'Authorization Objects:' as info, id, object_name, description, module 
FROM authorization_objects 
WHERE is_active = true
ORDER BY module, object_name;

-- 5. Check role-authorization assignments
SELECT 
    'Role Assignments:' as info,
    r.name as role_name,
    ao.object_name,
    ao.description,
    rao.field_values,
    rao.is_active
FROM role_authorization_objects rao
JOIN roles r ON rao.role_id = r.id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
ORDER BY r.name, ao.object_name;

-- 6. Check admin user role assignment
SELECT 
    'Admin User Check:' as info,
    u.email,
    r.name as role_name,
    u.role_id,
    r.id as role_table_id
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
WHERE u.email = 'admin@nttdemo.com';

-- 7. Count assignments per role
SELECT 
    'Assignments per Role:' as info,
    r.name as role_name,
    COUNT(rao.id) as auth_object_count
FROM roles r
LEFT JOIN role_authorization_objects rao ON r.id = rao.role_id
GROUP BY r.id, r.name
ORDER BY r.name;