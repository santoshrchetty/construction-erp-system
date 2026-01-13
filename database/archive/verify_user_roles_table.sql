-- Verify user_roles table exists and check structure
-- ==================================================

-- Check if user_roles table exists
SELECT table_name, table_type
FROM information_schema.tables 
WHERE table_name = 'user_roles';

-- If it exists, show its structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'user_roles'
ORDER BY ordinal_position;

-- Check sample data
SELECT ur.user_id, ur.role_id, u.email, r.name as role_name
FROM user_roles ur
JOIN users u ON ur.user_id = u.id
JOIN roles r ON ur.role_id = r.id
WHERE u.email = 'admin@nttdemo.com'
LIMIT 5;