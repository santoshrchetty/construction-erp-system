-- Delete duplicate Task Assignment tile
-- ===================================

-- Delete the duplicate Task Assignment tile from Planning category
DELETE FROM tiles 
WHERE title = 'Task Assignment' 
AND tile_category = 'Planning'
AND auth_object = 'PP_TSK_ASSIGN';

-- Verify deletion and show final tile counts
SELECT 
    'FINAL TILE COUNTS' as status,
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

-- Confirm no unauthorized tiles remain
SELECT COUNT(*) as remaining_unauthorized_tiles
FROM tiles t
WHERE check_construction_authorization(
    '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
    t.auth_object,
    t.construction_action,
    '{}'::jsonb
) = false;