-- Find all tables with 'profile' or 'user' in name
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND (table_name LIKE '%profile%' OR table_name LIKE '%user%')
ORDER BY table_name;

-- Check users table columns
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;
