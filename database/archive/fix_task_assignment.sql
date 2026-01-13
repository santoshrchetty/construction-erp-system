-- Fix Task Assignment tile in Planning category
-- =============================================

-- Add INITIATE action to PP_TSK_ASSIGN for admin user
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

-- Verify the Task Assignment tile is now authorized
SELECT 
    'TASK ASSIGNMENT FIXED' as status,
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
WHERE t.title = 'Task Assignment' AND t.tile_category = 'Planning';

-- Final check - should show no unauthorized tiles
SELECT COUNT(*) as remaining_unauthorized_tiles
FROM tiles t
WHERE check_construction_authorization(
    '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
    t.auth_object,
    t.construction_action,
    '{}'::jsonb
) = false;