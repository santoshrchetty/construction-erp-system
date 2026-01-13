-- Check table structure and fix authorization function
-- ===================================================

-- Check user_authorizations table structure
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'user_authorizations'
ORDER BY ordinal_position;

-- Check what's in user_authorizations for admin
SELECT * FROM user_authorizations 
WHERE user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
LIMIT 5;

-- Simple test - just show admin tiles without authorization check
SELECT title, tile_category, auth_object, construction_action
FROM tiles 
WHERE tile_category = 'Administration'
ORDER BY title;