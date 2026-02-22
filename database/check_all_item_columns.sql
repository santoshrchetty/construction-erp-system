-- Check all columns in material_request_items table
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns 
WHERE table_name = 'material_request_items'
ORDER BY ordinal_position;
