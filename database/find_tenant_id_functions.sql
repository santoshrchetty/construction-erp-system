-- Find functions with 'tenant' in name
SELECT 
  n.nspname as schema_name,
  p.proname as function_name,
  p.oid
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname LIKE '%tenant%'
ORDER BY n.nspname, p.proname;

-- Check for any extensions
SELECT extname, extversion FROM pg_extension;
