-- Check if user_roles table exists
-- =================================

SELECT table_name 
FROM information_schema.tables 
WHERE table_name IN ('user_roles', 'users', 'roles')
ORDER BY table_name;

-- Check users table structure
SELECT column_name, data_type
FROM information_schema.columns 
WHERE table_name = 'users'
ORDER BY ordinal_position;