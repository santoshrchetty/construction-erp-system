-- Check company_codes table structure
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'company_codes' 
ORDER BY ordinal_position;