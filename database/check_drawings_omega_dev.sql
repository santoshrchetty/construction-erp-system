-- Check drawings for OMEGA-DEV
SELECT * FROM drawings 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
LIMIT 5;

-- Check drawings table schema
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'drawings'
ORDER BY ordinal_position;
