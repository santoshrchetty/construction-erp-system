-- Add Finance Authorizations to Users
-- ====================================

-- Add Finance authorizations for all users
INSERT INTO user_authorizations (user_id, auth_object_id, field_values, valid_from)
SELECT u.id, ao.id, '{"ACTION": ["DISPLAY", "CREATE", "CHANGE", "EXECUTE"]}'::jsonb, CURRENT_DATE
FROM users u
CROSS JOIN authorization_objects ao
WHERE ao.module IN ('FI', 'CO')
  AND ao.is_active = true
ON CONFLICT (user_id, auth_object_id) 
DO UPDATE SET 
    field_values = '{"ACTION": ["DISPLAY", "CREATE", "CHANGE", "EXECUTE"]}'::jsonb,
    valid_from = CURRENT_DATE,
    valid_to = NULL;

-- Verify the authorizations were added
SELECT 'Added Authorizations' as check_type;
SELECT u.email, ao.object_name, ua.field_values
FROM user_authorizations ua
JOIN users u ON ua.user_id = u.id
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE ao.module IN ('FI', 'CO')
ORDER BY u.email, ao.object_name;

-- Test authorization again
SELECT 'Final Test' as check_type;
SELECT u.email,
       check_construction_authorization(u.id, 'FI_GL_DISP', 'DISPLAY') as finance_access,
       check_construction_authorization(u.id, 'CO_PRJ_DIS', 'DISPLAY') as controlling_access
FROM users u
ORDER BY u.created_at DESC LIMIT 3;