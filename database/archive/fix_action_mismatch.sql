-- Check action mismatch and fix
-- ==============================

-- Check what actions the admin has vs what tiles need
SELECT 
    'ACTION MISMATCH CHECK' as status,
    t.title,
    t.auth_object,
    t.construction_action as tile_needs,
    ua.field_values->'ACTION' as admin_has
FROM tiles t
JOIN authorization_objects ao ON t.auth_object = ao.object_name
JOIN user_authorizations ua ON ao.id = ua.auth_object_id
WHERE ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
AND t.auth_object = 'PP_TSK_ASSIGN';

-- Update the PP_TSK_ASSIGN authorization to include all needed actions
UPDATE user_authorizations 
SET field_values = '{"ACTION": ["ASSIGN", "INITIATE", "MODIFY", "UPDATE"]}'::jsonb
WHERE user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
AND auth_object_id IN (
    SELECT id FROM authorization_objects WHERE object_name = 'PP_TSK_ASSIGN'
);

-- Final verification - should show all tiles authorized
SELECT 
    'FINAL VERIFICATION' as status,
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