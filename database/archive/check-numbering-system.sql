-- Check existing projects with HW pattern
SELECT code, name, created_at FROM projects WHERE code LIKE 'HW-%' ORDER BY code;

-- Check if there are any existing projects at all
SELECT COUNT(*) as total_projects FROM projects;

-- Check what numbering tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_name LIKE '%number%' OR table_name LIKE '%pattern%';