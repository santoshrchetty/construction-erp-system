-- Check universal_journal table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'universal_journal'
ORDER BY ordinal_position;
