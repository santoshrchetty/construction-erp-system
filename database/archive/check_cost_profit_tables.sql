-- Check cost_centers table structure
SELECT 
  column_name,
  data_type,
  character_maximum_length,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'cost_centers'
ORDER BY ordinal_position;

-- Check profit_centers table structure  
SELECT 
  column_name,
  data_type,
  character_maximum_length,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'profit_centers'
ORDER BY ordinal_position;

-- Show sample data from cost_centers
SELECT * FROM cost_centers LIMIT 3;

-- Show sample data from profit_centers
SELECT * FROM profit_centers LIMIT 3;