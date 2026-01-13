-- Show all Project Management authorization objects
-- ================================================

-- Show all tiles in Project Management category with their auth objects
SELECT 
    'PROJECT MANAGEMENT TILES' as status,
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
WHERE t.tile_category = 'Project Management'
ORDER BY t.title;

-- Show what auth objects admin has for Project Management related objects
SELECT 
    'ADMIN PROJECT AUTH' as status,
    ao.object_name,
    ao.description,
    ua.field_values->'ACTION' as actions
FROM authorization_objects ao
JOIN user_authorizations ua ON ao.id = ua.auth_object_id
WHERE ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
AND ao.object_name LIKE 'PS_%'
ORDER BY ao.object_name;