-- Check for equipment master table
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name LIKE '%equipment%'
  AND table_name NOT LIKE '%activity%'
ORDER BY table_name;

-- If equipment table exists, check its structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'equipment'
ORDER BY ordinal_position;
