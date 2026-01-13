-- Check User Role Assignments
-- ============================

-- Check current users and their roles
SELECT 'Current Users' as check_type;
SELECT u.id, u.email, u.full_name, ur.role_id, r.name as role_name
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id  
LEFT JOIN roles r ON ur.role_id = r.id
ORDER BY u.created_at DESC;

-- Check if user_roles table exists
SELECT 'User Roles Table' as check_type;
SELECT * FROM user_roles LIMIT 5;

-- Get Admin role ID
SELECT 'Admin Role' as check_type;
SELECT id, name, permissions FROM roles WHERE name = 'Admin';

-- Assign Admin role to all users (temporary for testing)
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u
CROSS JOIN roles r
WHERE r.name = 'Admin'
AND NOT EXISTS (
    SELECT 1 FROM user_roles ur 
    WHERE ur.user_id = u.id AND ur.role_id = r.id
);

-- Verify assignments
SELECT 'Final Verification' as check_type;
SELECT u.email, r.name as role_name, r.permissions
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
ORDER BY u.email;