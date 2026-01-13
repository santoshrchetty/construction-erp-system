-- Check chart_of_accounts table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'chart_of_accounts'
ORDER BY ordinal_position;

-- Check existing data format
SELECT * FROM chart_of_accounts LIMIT 3;