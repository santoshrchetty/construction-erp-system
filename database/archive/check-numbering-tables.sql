-- Check if required tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_name IN (
    'project_numbering_rules',
    'project_number_reservations'
)
ORDER BY table_name;

-- Check project_numbering_rules structure if it exists
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'project_numbering_rules'
ORDER BY ordinal_position;