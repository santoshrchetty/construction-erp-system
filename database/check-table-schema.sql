-- Check the actual columns in role_authorization_objects table
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'role_authorization_objects'
ORDER BY ordinal_position;
