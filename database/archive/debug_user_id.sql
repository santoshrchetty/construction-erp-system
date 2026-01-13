-- Debug: Check admin user ID
-- ==========================

-- Check if admin@nttdemo.com exists in auth.users (this won't work in SQL editor)
-- We need to check what user ID is actually being used

-- Check what user_authorizations exist
SELECT 'USER AUTHORIZATIONS' as status, user_id, COUNT(*) as auth_count
FROM user_authorizations 
GROUP BY user_id
ORDER BY auth_count DESC;

-- Check if the hardcoded admin ID has authorizations
SELECT 'HARDCODED ADMIN CHECK' as status, COUNT(*) as auth_count
FROM user_authorizations 
WHERE user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f';

-- Show all tiles to verify they exist
SELECT 'TOTAL TILES' as status, COUNT(*) as tile_count
FROM tiles WHERE is_active = true;