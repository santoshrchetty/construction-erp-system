-- Test what get_user_authorized_tiles actually returns
-- ===================================================

-- Test the function output
SELECT 
    'FUNCTION OUTPUT' as status,
    title,
    tile_category,
    has_authorization
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f')
ORDER BY tile_category, title;

-- Count authorized vs unauthorized from function
SELECT 
    'FUNCTION SUMMARY' as status,
    tile_category,
    COUNT(*) as total_tiles,
    COUNT(CASE WHEN has_authorization = true THEN 1 END) as authorized_from_function
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f')
GROUP BY tile_category
ORDER BY tile_category;