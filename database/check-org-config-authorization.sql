-- Check if Organisation Configuration tile is authorized for Admin user
SELECT 'Checking Organisation Configuration authorization for Admin:' as info;

-- Check current authorization
SELECT 
    u.username,
    r.role_name,
    ao.object_name,
    ao.description
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
JOIN role_authorizations ra ON r.id = ra.role_id
JOIN authorization_objects ao ON ra.auth_object_id = ao.id
WHERE u.username = 'admin' 
  AND ao.object_name = 'CG_ORG_CONFIG';

-- If not authorized, add the authorization object and assign to admin role
INSERT INTO authorization_objects (object_name, description, module, is_active)
VALUES ('CG_ORG_CONFIG', 'Organisation Configuration Access', 'configuration', true)
ON CONFLICT (object_name) DO NOTHING;

-- Ensure admin role has access to the new auth object
INSERT INTO role_authorizations (role_id, auth_object_id, activity, granted)
SELECT 
    r.id,
    ao.id,
    'EXECUTE',
    true
FROM roles r, authorization_objects ao
WHERE r.role_name = 'Admin' 
  AND ao.object_name = 'CG_ORG_CONFIG'
  AND NOT EXISTS (
    SELECT 1 FROM role_authorizations ra2 
    WHERE ra2.role_id = r.id AND ra2.auth_object_id = ao.id
  );

-- Verify final authorization
SELECT 'Final authorization check:' as verification;
SELECT 
    u.username,
    r.role_name,
    ao.object_name,
    ra.activity,
    ra.granted
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
JOIN role_authorizations ra ON r.id = ra.role_id
JOIN authorization_objects ao ON ra.auth_object_id = ao.id
WHERE u.username = 'admin' 
  AND ao.object_name = 'CG_ORG_CONFIG';