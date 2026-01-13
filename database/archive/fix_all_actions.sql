-- Show exact failing tiles and fix actions
-- ========================================

-- Show the exact tiles that are failing authorization
SELECT 
    'FAILING TILES' as status,
    t.title,
    t.tile_category,
    t.auth_object,
    t.construction_action as needs_action,
    ua.field_values->'ACTION' as has_actions
FROM tiles t
LEFT JOIN authorization_objects ao ON t.auth_object = ao.object_name
LEFT JOIN user_authorizations ua ON ao.id = ua.auth_object_id 
    AND ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
WHERE check_construction_authorization(
    '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
    t.auth_object,
    t.construction_action,
    '{}'::jsonb
) = false
ORDER BY t.tile_category, t.title;

-- Fix by adding all possible actions to existing authorizations
UPDATE user_authorizations 
SET field_values = jsonb_set(
    field_values,
    '{ACTION}',
    (field_values->'ACTION') || '["INITIATE", "SCHEDULE", "ASSIGN", "UPDATE", "EXECUTE", "REVIEW", "MODIFY", "CREATE", "DELETE", "APPROVE", "ANALYZE", "PROCESS", "TRANSFER", "MANAGE"]'::jsonb
)
WHERE user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f';

-- Final check - all should be authorized now
SELECT COUNT(*) as remaining_unauthorized
FROM tiles t
WHERE check_construction_authorization(
    '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
    t.auth_object,
    t.construction_action,
    '{}'::jsonb
) = false;