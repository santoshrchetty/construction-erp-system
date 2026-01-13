-- Check wbs_elements table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'wbs_elements' 
ORDER BY ordinal_position;