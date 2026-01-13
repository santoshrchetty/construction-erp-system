-- Check the structure of wbs_nodes table
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'wbs_nodes' 
ORDER BY ordinal_position;