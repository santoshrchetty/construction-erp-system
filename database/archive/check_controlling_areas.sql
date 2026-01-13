-- Query to check controlling_areas table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'controlling_areas' 
ORDER BY ordinal_position;

-- Also check if the table exists and get sample data
SELECT COUNT(*) as record_count FROM controlling_areas;
SELECT * FROM controlling_areas LIMIT 5;