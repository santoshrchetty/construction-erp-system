-- Debug Admin User Tile Access
-- =============================

-- Check admin user's current authorizations
SELECT 'ADMIN USER AUTHS' as test_type, 
       ao.object_name, 
       ua.field_values
FROM user_authorizations ua
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
AND ao.object_name IN ('MM_MAT_MASTER', 'MM_VEN_MANAGE', 'WM_STK_REVIEW')
ORDER BY ao.object_name;

-- Test specific tile authorization
SELECT 'MATERIAL MASTER TEST' as test_type,
       check_construction_authorization(
           '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
           'MM_MAT_MASTER',
           'MODIFY',
           '{}'::jsonb
       ) as has_permission;

-- Check Material Master tile specifically
SELECT 'MATERIAL TILE CHECK' as test_type,
       t.title,
       t.has_authorization
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f') t
WHERE t.title = 'Material Master';

-- Force assign specific authorization directly
INSERT INTO user_authorizations (user_id, auth_object_id, field_values)
SELECT '70f8baa8-27b8-4061-84c4-6dd027d6b89f', ao.id, '{"ACTION": ["MODIFY"]}'::jsonb
FROM authorization_objects ao
WHERE ao.object_name = 'MM_MAT_MASTER'
AND NOT EXISTS (
    SELECT 1 FROM user_authorizations ua 
    WHERE ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f' 
    AND ua.auth_object_id = ao.id
);

-- Test again after direct assignment
SELECT 'AFTER DIRECT ASSIGNMENT' as test_type,
       check_construction_authorization(
           '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
           'MM_MAT_MASTER',
           'MODIFY',
           '{}'::jsonb
       ) as has_permission;