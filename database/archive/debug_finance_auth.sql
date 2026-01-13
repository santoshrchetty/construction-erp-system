-- Debug Finance Tiles Authorization
-- ==================================

-- Check which Finance tiles have user authorizations
SELECT 'Finance Tiles with Authorization' as check_type;
SELECT t.title, t.auth_object, 
       COUNT(ua.id) as users_with_access,
       t.is_active
FROM tiles t
LEFT JOIN authorization_objects ao ON t.auth_object = ao.object_name
LEFT JOIN user_authorizations ua ON ao.id = ua.auth_object_id
WHERE t.tile_category = 'Finance'
GROUP BY t.id, t.title, t.auth_object, t.is_active
ORDER BY users_with_access DESC, t.title;

-- Check which auth objects are missing user authorizations
SELECT 'Missing User Authorizations' as check_type;
SELECT ao.object_name, ao.module, ao.is_active,
       COUNT(ua.id) as user_count
FROM authorization_objects ao
LEFT JOIN user_authorizations ua ON ao.id = ua.auth_object_id
WHERE ao.module IN ('FI', 'CO')
GROUP BY ao.id, ao.object_name, ao.module, ao.is_active
HAVING COUNT(ua.id) = 0
ORDER BY ao.object_name;

-- Add missing user authorizations for new Finance tiles
INSERT INTO user_authorizations (user_id, auth_object_id, field_values, valid_from)
SELECT u.id, ao.id, '{"ACTION": ["DISPLAY", "CREATE", "CHANGE", "EXECUTE"]}'::jsonb, CURRENT_DATE
FROM users u
CROSS JOIN authorization_objects ao
WHERE ao.module IN ('FI', 'CO')
  AND ao.is_active = true
  AND NOT EXISTS (
    SELECT 1 FROM user_authorizations ua 
    WHERE ua.user_id = u.id AND ua.auth_object_id = ao.id
  );

-- Test authorization for specific tiles
SELECT 'Authorization Test' as check_type;
SELECT t.title, t.auth_object,
       check_construction_authorization(
           (SELECT id FROM users WHERE email LIKE '%@nttdemo.com' LIMIT 1),
           t.auth_object,
           t.construction_action
       ) as has_access
FROM tiles t
WHERE t.tile_category = 'Finance'
  AND t.auth_object IN ('FI_GL_DISP', 'FI_GL_POST', 'CO_PRJ_DIS')
ORDER BY t.title;