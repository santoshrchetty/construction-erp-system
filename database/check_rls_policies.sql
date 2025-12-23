-- Check if RLS is enabled on users table
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('users', 'roles');

-- Check RLS policies on users table
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('users', 'roles');

-- Test the exact query that AuthContext uses with RLS context
SET row_security = off;
SELECT 
    u.id, 
    u.email, 
    u.first_name, 
    u.last_name, 
    u.role_id, 
    u.employee_code, 
    u.department, 
    u.is_active,
    json_build_object(
        'id', r.id,
        'name', r.name,
        'description', r.description,
        'permissions', r.permissions
    ) as roles
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
WHERE u.id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f';