-- Check which tiles are authorized vs unauthorized
-- ===============================================

-- Show authorized tiles for admin
SELECT 
    'AUTHORIZED TILES' as status,
    t.title,
    t.tile_category,
    t.auth_object,
    t.construction_action
FROM tiles t
WHERE check_construction_authorization(
    '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
    t.auth_object,
    t.construction_action,
    '{}'::jsonb
) = true
ORDER BY t.tile_category, t.title;

-- Show unauthorized tiles for admin
SELECT 
    'UNAUTHORIZED TILES' as status,
    t.title,
    t.tile_category,
    t.auth_object,
    t.construction_action
FROM tiles t
WHERE check_construction_authorization(
    '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
    t.auth_object,
    t.construction_action,
    '{}'::jsonb
) = false
ORDER BY t.tile_category, t.title;

-- Count by category
SELECT 
    'TILES BY CATEGORY' as status,
    t.tile_category,
    COUNT(*) as total_tiles,
    COUNT(CASE WHEN check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
        t.auth_object,
        t.construction_action,
        '{}'::jsonb
    ) = true THEN 1 END) as authorized_tiles
FROM tiles t
GROUP BY t.tile_category
ORDER BY t.tile_category;