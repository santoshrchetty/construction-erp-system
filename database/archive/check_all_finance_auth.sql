-- Check All Finance Tiles Authorization
-- ======================================

-- Check all Finance tiles and their auth objects
SELECT 'All Finance Tiles' as check_type;
SELECT title, auth_object, is_active, construction_action
FROM tiles 
WHERE tile_category = 'Finance'
ORDER BY title;

-- Check which Finance auth objects exist
SELECT 'Finance Auth Objects' as check_type;
SELECT object_name, description, module, is_active
FROM authorization_objects 
WHERE module IN ('FI', 'CO')
ORDER BY object_name;

-- Test authorization for ALL Finance tiles for admin user
SELECT 'Complete Finance Authorization Test' as check_type;
SELECT t.title, t.auth_object, t.construction_action,
       check_construction_authorization(
           (SELECT id FROM users WHERE email = 'admin@nttdemo.com'),
           t.auth_object,
           t.construction_action
       ) as has_access
FROM tiles t
WHERE t.tile_category = 'Finance'
  AND t.is_active = true
ORDER BY t.title;

-- Check user authorizations for admin user
SELECT 'Admin User Authorizations' as check_type;
SELECT ao.object_name, ao.module, ua.field_values
FROM user_authorizations ua
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE ua.user_id = (SELECT id FROM users WHERE email = 'admin@nttdemo.com')
  AND ao.module IN ('FI', 'CO')
ORDER BY ao.object_name;

-- Check if any Finance tiles have NULL auth_object
SELECT 'Finance Tiles with NULL auth_object' as check_type;
SELECT title, auth_object, is_active
FROM tiles 
WHERE tile_category = 'Finance'
  AND auth_object IS NULL;