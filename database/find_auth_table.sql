-- Find authorization-related tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND (table_name LIKE '%auth%' OR table_name LIKE '%permission%' OR table_name LIKE '%access%')
ORDER BY table_name;
