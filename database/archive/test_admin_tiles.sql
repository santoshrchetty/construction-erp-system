-- Test admin tile access
-- ======================

-- Test the get_user_authorized_tiles function
SELECT 
    title,
    tile_category,
    construction_action,
    has_authorization
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f')
WHERE tile_category = 'Administration'
ORDER BY title;

-- Also check all tiles for admin
SELECT 
    COUNT(*) as total_tiles,
    COUNT(CASE WHEN has_authorization = true THEN 1 END) as authorized_tiles
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f');

-- Check tiles table directly
SELECT title, tile_category, auth_object, construction_action
FROM tiles 
WHERE tile_category = 'Administration'
ORDER BY title;