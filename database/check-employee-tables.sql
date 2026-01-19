-- Check for employee-related tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND (table_name LIKE '%employee%' OR table_name LIKE '%staff%' OR table_name LIKE '%hr%')
ORDER BY table_name;

-- Check if employees table exists and its structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'employees'
ORDER BY ordinal_position;
