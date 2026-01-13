-- Check what tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check users table structure
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'users' AND table_schema = 'public';

-- Check if users data exists
SELECT id, email, role_id FROM users;

-- Check roles join
SELECT u.email, r.name as role_name 
FROM users u 
LEFT JOIN roles r ON u.role_id = r.id;