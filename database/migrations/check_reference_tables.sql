-- Check schema of reference tables to find correct code column names
SELECT 'projects' as table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'projects' 
ORDER BY ordinal_position;

SELECT 'cost_centers' as table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'cost_centers' 
ORDER BY ordinal_position;

SELECT 'wbs_elements' as table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'wbs_elements' 
ORDER BY ordinal_position;
