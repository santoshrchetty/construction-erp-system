-- Show all Project Management tiles and their authorization status
-- ===============================================================

-- Show all Project Management tiles with detailed auth info
SELECT 
    'PROJECT TILES DETAIL' as status,
    t.title,
    t.auth_object,
    t.construction_action,
    CASE WHEN t.auth_object LIKE 'PS_%' THEN 'PS_OBJECT' 
         WHEN t.auth_object LIKE 'PP_%' THEN 'PP_OBJECT'
         ELSE 'OTHER_OBJECT' END as object_type,
    check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
        t.auth_object,
        t.construction_action,
        '{}'::jsonb
    ) as has_access
FROM tiles t
WHERE t.tile_category = 'Project Management'
ORDER BY has_access, t.title;

-- Show which specific Project Management tile is not authorized
SELECT 
    'UNAUTHORIZED PROJECT TILE' as status,
    t.title,
    t.auth_object,
    t.construction_action
FROM tiles t
WHERE t.tile_category = 'Project Management'
AND check_construction_authorization(
    '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
    t.auth_object,
    t.construction_action,
    '{}'::jsonb
) = false;