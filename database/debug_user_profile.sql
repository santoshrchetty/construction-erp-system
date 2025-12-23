-- Debug the specific user that's logged in
SELECT 
    u.id,
    u.email,
    u.role_id,
    u.is_active,
    r.id as role_table_id,
    r.name as role_name,
    r.permissions
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
WHERE u.id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f';

-- Also check the query that AuthContext uses
SELECT 
    u.id, 
    u.email, 
    u.first_name, 
    u.last_name, 
    u.role_id, 
    u.employee_code, 
    u.department, 
    u.is_active,
    r.id as roles_id,
    r.name as roles_name,
    r.description as roles_description,
    r.permissions as roles_permissions
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
WHERE u.id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f';