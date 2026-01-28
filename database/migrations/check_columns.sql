-- Check actual columns in document_number_ranges table
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'document_number_ranges'
ORDER BY ordinal_position;
