-- Debug Project Management Tiles
-- ===============================

-- Check Project Management tiles
SELECT 'PROJECT TILES' as status;
SELECT 
    title, 
    icon, 
    auth_object, 
    construction_action, 
    module_code, 
    tile_category,
    route,
    is_active
FROM tiles 
WHERE tile_category = 'Project Management'
ORDER BY sequence_order;

-- Test authorization for admin user on project tiles
SELECT 'PROJECT AUTHORIZATION TEST' as status;
SELECT 
    t.title,
    t.auth_object,
    t.construction_action,
    check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
        t.auth_object,
        t.construction_action,
        '{}'::jsonb
    ) as has_permission
FROM tiles t
WHERE t.tile_category = 'Project Management'
ORDER BY t.sequence_order;

-- Check if user has the required authorizations
SELECT 'USER AUTHORIZATIONS' as status;
SELECT 
    ua.auth_object_id,
    ao.object_name,
    ua.field_values
FROM user_authorizations ua
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
AND ao.object_name LIKE 'PS_%';