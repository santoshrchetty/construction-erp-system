-- Fix the Tasks tile authorization
-- =================================

-- Show current PP_TSK_ASSIGN actions for admin
SELECT 
    'CURRENT PP_TSK_ASSIGN ACTIONS' as status,
    ua.field_values->'ACTION' as current_actions
FROM user_authorizations ua
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
AND ao.object_name = 'PP_TSK_ASSIGN';

-- Add INITIATE action to PP_TSK_ASSIGN
UPDATE user_authorizations 
SET field_values = jsonb_set(
    field_values,
    '{ACTION}',
    (field_values->'ACTION') || '["INITIATE"]'::jsonb
)
WHERE user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
AND auth_object_id IN (
    SELECT id FROM authorization_objects WHERE object_name = 'PP_TSK_ASSIGN'
);

-- Verify the Tasks tile is now authorized
SELECT 
    'TASKS TILE VERIFICATION' as status,
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
WHERE t.title = 'Tasks' AND t.tile_category = 'Project Management';

-- Final count - should show 10/10 for Project Management
SELECT 
    'FINAL PROJECT MANAGEMENT COUNT' as status,
    COUNT(*) as total_tiles,
    COUNT(CASE WHEN check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
        t.auth_object,
        t.construction_action,
        '{}'::jsonb
    ) = true THEN 1 END) as authorized_tiles
FROM tiles t
WHERE t.tile_category = 'Project Management';