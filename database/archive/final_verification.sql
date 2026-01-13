-- Final verification of all tile authorizations
-- ==============================================

-- Check final authorization status by category
SELECT 
    'FINAL AUTHORIZATION STATUS' as status,
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

-- Show any remaining unauthorized tiles
SELECT 
    'REMAINING UNAUTHORIZED' as status,
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