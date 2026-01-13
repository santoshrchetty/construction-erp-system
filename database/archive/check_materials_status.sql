-- Check Materials category tiles specifically
-- ===========================================

-- Show all Materials tiles and their authorization status
SELECT 
    'MATERIALS TILES STATUS' as status,
    t.title,
    t.auth_object,
    t.construction_action,
    check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
        t.auth_object,
        t.construction_action,
        '{}'::jsonb
    ) as has_access
FROM tiles t
WHERE t.tile_category = 'Materials'
ORDER BY t.title;

-- Check what MM_ authorization objects admin has
SELECT 
    'ADMIN MM AUTHORIZATIONS' as status,
    ao.object_name,
    ao.description,
    ua.field_values->'ACTION' as actions
FROM authorization_objects ao
JOIN user_authorizations ua ON ao.id = ua.auth_object_id
WHERE ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
AND ao.object_name LIKE 'MM_%'
ORDER BY ao.object_name;