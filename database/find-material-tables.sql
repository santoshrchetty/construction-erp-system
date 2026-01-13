-- FIND ALL MATERIAL-RELATED TABLES

-- List all tables with 'material' in the name
SELECT 'MATERIAL TABLES' as section;
SELECT table_name
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
  AND table_name ILIKE '%material%'
ORDER BY table_name;

-- List all tables that might contain materials data
SELECT 'POSSIBLE MATERIAL TABLES' as section;
SELECT table_name
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
  AND (table_name ILIKE '%material%' 
       OR table_name ILIKE '%item%' 
       OR table_name ILIKE '%product%'
       OR table_name ILIKE '%stock%')
ORDER BY table_name;

SELECT 'MATERIAL TABLES SEARCH COMPLETE' as status;