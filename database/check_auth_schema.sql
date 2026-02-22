-- Check authorization_objects table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'authorization_objects'
ORDER BY ordinal_position;

-- Check authorization_fields table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'authorization_fields'
ORDER BY ordinal_position;
