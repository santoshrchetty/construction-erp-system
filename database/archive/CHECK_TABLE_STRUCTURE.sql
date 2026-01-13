-- Check actual document_number_ranges table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'document_number_ranges'
ORDER BY ordinal_position;