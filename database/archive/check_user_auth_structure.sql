-- Check user_authorizations table structure
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'user_authorizations' 
ORDER BY ordinal_position;

-- Check a sample record to see the structure
SELECT * FROM user_authorizations LIMIT 1;