-- Check the actual structure of the tiles table
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'tiles' 
ORDER BY ordinal_position;