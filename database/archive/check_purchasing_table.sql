-- Check purchasing_organizations table structure
SELECT 
  column_name,
  data_type,
  character_maximum_length,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'purchasing_organizations'
ORDER BY ordinal_position;

-- Check if table has data
SELECT COUNT(*) as row_count FROM purchasing_organizations;

-- Show sample data
SELECT * FROM purchasing_organizations LIMIT 5;