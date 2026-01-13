-- Check Existing User Authorizations
-- ===================================

-- Check user_authorizations table structure
SELECT 'User Authorizations Structure' as check_type;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'user_authorizations' 
ORDER BY ordinal_position;

-- Check existing user authorizations
SELECT 'Existing User Authorizations' as check_type;
SELECT u.email, ao.object_name, ao.module, ua.field_values, ua.valid_from, ua.valid_to
FROM user_authorizations ua
JOIN users u ON ua.user_id = u.id
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
ORDER BY u.email, ao.object_name;

-- Check Finance authorization objects
SELECT 'Finance Auth Objects' as check_type;
SELECT id, object_name, description, module, is_active
FROM authorization_objects 
WHERE module IN ('FI', 'CO')
ORDER BY object_name;

-- Check if any user has Finance authorizations
SELECT 'Finance User Count' as check_type;
SELECT COUNT(*) as users_with_finance_access
FROM user_authorizations ua
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE ao.module IN ('FI', 'CO');

-- Test authorization with action parameter
SELECT 'Test with Action' as check_type;
SELECT check_construction_authorization(
    (SELECT id FROM users LIMIT 1)::uuid,
    'FI_GL_DISP',
    'DISPLAY'
) as has_finance_display_access;