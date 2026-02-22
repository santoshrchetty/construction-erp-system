-- Check authorization_objects table columns
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'authorization_objects' 
ORDER BY ordinal_position;

-- Check a sample row
SELECT * FROM authorization_objects LIMIT 1;
