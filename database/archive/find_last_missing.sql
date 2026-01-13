-- Find and fix the last 2 missing authorizations
-- ===============================================

-- Find the specific tiles that are not authorized
SELECT 
    'REMAINING MISSING TILES' as status,
    t.title,
    t.tile_category,
    t.auth_object,
    t.construction_action
FROM tiles t
WHERE check_construction_authorization(
    '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
    t.auth_object,
    t.construction_action,
    '{}'::jsonb
) = false
ORDER BY t.tile_category, t.title;

-- Check if these auth objects exist
SELECT 
    'AUTH OBJECTS STATUS' as status,
    ao.object_name,
    ao.description,
    CASE WHEN ua.id IS NOT NULL THEN 'HAS_AUTH' ELSE 'MISSING_AUTH' END as auth_status
FROM authorization_objects ao
LEFT JOIN user_authorizations ua ON ao.id = ua.auth_object_id 
    AND ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
WHERE ao.object_name IN (
    SELECT DISTINCT t.auth_object
    FROM tiles t
    WHERE check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
        t.auth_object,
        t.construction_action,
        '{}'::jsonb
    ) = false
);