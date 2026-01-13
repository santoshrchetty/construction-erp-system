-- Direct Fix for Admin Material/Warehouse Access
-- ==============================================

-- Directly insert missing authorizations for admin user
INSERT INTO user_authorizations (user_id, auth_object_id, field_values)
SELECT '70f8baa8-27b8-4061-84c4-6dd027d6b89f', ao.id, '{"ACTION": ["MODIFY"]}'::jsonb
FROM authorization_objects ao
WHERE ao.object_name IN ('MM_MAT_MASTER', 'MM_VEN_MANAGE')
AND NOT EXISTS (
    SELECT 1 FROM user_authorizations ua 
    WHERE ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f' 
    AND ua.auth_object_id = ao.id
);

INSERT INTO user_authorizations (user_id, auth_object_id, field_values)
SELECT '70f8baa8-27b8-4061-84c4-6dd027d6b89f', ao.id, '{"ACTION": ["REVIEW"]}'::jsonb
FROM authorization_objects ao
WHERE ao.object_name IN ('WM_STK_REVIEW')
AND NOT EXISTS (
    SELECT 1 FROM user_authorizations ua 
    WHERE ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f' 
    AND ua.auth_object_id = ao.id
);

INSERT INTO user_authorizations (user_id, auth_object_id, field_values)
SELECT '70f8baa8-27b8-4061-84c4-6dd027d6b89f', ao.id, '{"ACTION": ["EXECUTE", "MODIFY"]}'::jsonb
FROM authorization_objects ao
WHERE ao.object_name IN ('WM_STK_TRANSFER', 'WM_STR_MANAGE')
AND NOT EXISTS (
    SELECT 1 FROM user_authorizations ua 
    WHERE ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f' 
    AND ua.auth_object_id = ao.id
);

-- Verify the assignments
SELECT 'VERIFICATION' as status, 
       ao.object_name,
       ua.field_values
FROM user_authorizations ua
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
AND ao.object_name IN ('MM_MAT_MASTER', 'MM_VEN_MANAGE', 'WM_STK_REVIEW', 'WM_STK_TRANSFER', 'WM_STR_MANAGE')
ORDER BY ao.object_name;