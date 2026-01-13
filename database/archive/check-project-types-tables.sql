-- Check if project_categories table exists and has data
SELECT * FROM project_categories LIMIT 5;

-- Check if project_types table exists and has data  
SELECT * FROM project_types LIMIT 5;

-- Check table structures
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'project_categories' ORDER BY ordinal_position;

SELECT column_name FROM information_schema.columns 
WHERE table_name = 'project_types' ORDER BY ordinal_position;