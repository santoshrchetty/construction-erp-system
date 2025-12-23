-- Check current user records and fix role relationships

-- First, let's see what users exist
SELECT 
    u.id,
    u.email,
    u.first_name,
    u.last_name,
    u.role_id,
    r.name as role_name
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
ORDER BY u.created_at DESC;

-- Check what roles exist
SELECT id, name FROM roles;

-- Fix any users without proper role relationships
UPDATE users 
SET role_id = (SELECT id FROM roles WHERE name = 'Employee' LIMIT 1)
WHERE role_id IS NULL OR role_id NOT IN (SELECT id FROM roles);

-- Verify the fix
SELECT 
    u.id,
    u.email,
    u.first_name,
    u.last_name,
    r.name as role_name,
    u.employee_code,
    u.department
FROM users u
JOIN roles r ON u.role_id = r.id
ORDER BY u.created_at DESC;