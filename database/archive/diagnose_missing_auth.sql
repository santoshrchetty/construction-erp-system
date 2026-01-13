-- Diagnose and fix missing admin authorizations
-- ==============================================

-- Check which tiles are not authorized for admin
SELECT 
    'MISSING AUTHORIZATIONS' as status,
    t.title,
    t.tile_category,
    t.auth_object,
    t.construction_action,
    check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
        t.auth_object,
        t.construction_action,
        '{}'::jsonb
    ) as has_access
FROM tiles t
WHERE check_construction_authorization(
    '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
    t.auth_object,
    t.construction_action,
    '{}'::jsonb
) = false
ORDER BY t.tile_category, t.title;

-- Check what authorization objects exist but admin doesn't have
SELECT 
    'MISSING AUTH OBJECTS' as status,
    ao.object_name,
    ao.description,
    ao.module
FROM authorization_objects ao
WHERE ao.object_name NOT IN (
    SELECT ao2.object_name
    FROM user_authorizations ua
    JOIN authorization_objects ao2 ON ua.auth_object_id = ao2.id
    WHERE ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
)
ORDER BY ao.module, ao.object_name;