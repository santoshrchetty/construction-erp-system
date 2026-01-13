-- Check all existing tables to find material-related tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND (table_name LIKE '%material%' OR table_name LIKE '%item%' OR table_name LIKE '%product%')
ORDER BY table_name;

-- Check all tables to see the full list
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;