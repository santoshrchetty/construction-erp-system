-- Final authorization summary after cleanup
-- =========================================

-- Delete the duplicate Task Assignment tile from Planning
DELETE FROM tiles 
WHERE title = 'Task Assignment' 
AND tile_category = 'Planning'
AND auth_object = 'PP_TSK_ASSIGN';

-- Show final complete authorization status
SELECT 
    'COMPLETE AUTHORIZATION STATUS' as status,
    t.tile_category,
    COUNT(*) as total_tiles,
    COUNT(CASE WHEN check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
        t.auth_object,
        t.construction_action,
        '{}'::jsonb
    ) = true THEN 1 END) as authorized_tiles,
    CASE WHEN COUNT(*) = COUNT(CASE WHEN check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
        t.auth_object,
        t.construction_action,
        '{}'::jsonb
    ) = true THEN 1 END) THEN '✓ COMPLETE' ELSE '✗ INCOMPLETE' END as status_check
FROM tiles t
GROUP BY t.tile_category
ORDER BY t.tile_category;

-- Final verification - should be 0
SELECT COUNT(*) as total_unauthorized_tiles
FROM tiles t
WHERE check_construction_authorization(
    '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
    t.auth_object,
    t.construction_action,
    '{}'::jsonb
) = false;