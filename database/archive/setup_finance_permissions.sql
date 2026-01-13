-- Proper Finance Authorization Setup
-- ==================================

-- Check if authorization function exists
SELECT 'Authorization Function Check' as check_type;
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name = 'check_construction_authorization';

-- Check existing roles
SELECT 'Existing Roles' as check_type;
SELECT id, role_name, description FROM roles ORDER BY role_name;

-- Check if Finance role exists, create if not
INSERT INTO roles (role_name, description, is_active)
VALUES ('Finance Manager', 'Full access to Finance and Controlling modules', true)
ON CONFLICT (role_name) DO NOTHING;

-- Get Finance role ID
SELECT 'Finance Role ID' as check_type;
SELECT id, role_name FROM roles WHERE role_name = 'Finance Manager';

-- Add Finance permissions to Finance Manager role
INSERT INTO role_permissions (role_id, auth_object_id)
SELECT r.id, ao.id
FROM roles r
CROSS JOIN authorization_objects ao
WHERE r.role_name = 'Finance Manager'
AND ao.module IN ('FI', 'CO')
ON CONFLICT (role_id, auth_object_id) DO NOTHING;

-- Assign Finance Manager role to current user
-- First, get current user (assuming you're logged in)
SELECT 'Current User Assignment' as check_type;
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u
CROSS JOIN roles r
WHERE u.email LIKE '%@%'  -- Adjust this to your email pattern
AND r.role_name = 'Finance Manager'
ON CONFLICT (user_id, role_id) DO NOTHING;

-- Verify setup
SELECT 'Verification' as check_type;
SELECT u.email, r.role_name, ao.object_name
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
JOIN role_permissions rp ON r.id = rp.role_id
JOIN authorization_objects ao ON rp.auth_object_id = ao.id
WHERE ao.module IN ('FI', 'CO')
ORDER BY u.email, ao.object_name;