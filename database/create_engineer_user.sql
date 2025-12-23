-- Create engineer@nttdemo.com user - SIMPLE VERSION
-- Run this after creating the user through Supabase Dashboard or CLI

-- Step 1: Create user through Supabase Dashboard:
-- Go to Authentication > Users > Add User
-- Email: engineer@nttdemo.com
-- Password: demo123
-- Or use CLI: supabase auth users create engineer@nttdemo.com --password demo123

-- Step 2: Run this SQL to assign Engineer role:
UPDATE users 
SET 
    role_id = (SELECT id FROM roles WHERE name = 'Engineer' LIMIT 1),
    first_name = 'Site',
    last_name = 'Engineer',
    employee_code = 'ENG-001',
    department = 'Engineering'
WHERE email = 'engineer@nttdemo.com';

-- Verify user creation
SELECT 
    u.email,
    u.first_name,
    u.last_name,
    r.name as role_name,
    u.employee_code,
    u.department
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.email = 'engineer@nttdemo.com';