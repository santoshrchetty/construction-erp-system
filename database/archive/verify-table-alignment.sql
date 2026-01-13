-- Check existing tables first
SELECT table_name 
FROM information_schema.tables 
WHERE table_name LIKE '%project%' 
AND table_schema = 'public';

-- 1. Check project_categories (should exist)
SELECT 
    'project_categories' as table_name,
    COUNT(*) as record_count,
    COUNT(DISTINCT company_code) as companies,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_records
FROM project_categories;

-- 2. Check if project_gl_determination exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_gl_determination') THEN
        RAISE NOTICE 'project_gl_determination table exists';
    ELSE
        RAISE NOTICE 'project_gl_determination table does NOT exist - needs to be created';
    END IF;
END $$;