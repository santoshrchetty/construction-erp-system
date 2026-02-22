-- =====================================================
-- VERIFY OMEGA-DEV DOCUMENT GOVERNANCE SETUP
-- =====================================================

-- 1. Check user and role
SELECT 
  u.id as user_id,
  u.email,
  u.first_name,
  u.last_name,
  r.name as role_name,
  r.id as role_id,
  t.tenant_code,
  t.tenant_name
FROM users u
JOIN roles r ON u.role_id = r.id
JOIN tenants t ON u.tenant_id = t.id
WHERE u.email = 'internaluser@abc.com'
AND u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

-- 2. Check DG authorization objects for OMEGA-DEV
SELECT 
  object_name,
  description,
  module
FROM authorization_objects
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module = 'DG'
ORDER BY object_name;

-- 3. Check role authorizations
SELECT 
  r.name as role_name,
  ao.object_name,
  ao.description,
  rao.field_values
FROM role_authorization_objects rao
JOIN roles r ON rao.role_id = r.id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.name = 'DataGov Admin'
AND ao.module = 'DG'
ORDER BY ao.object_name;

-- 4. Count authorizations by module
SELECT 
  ao.module,
  COUNT(*) as auth_count
FROM role_authorization_objects rao
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE rao.role_id = (
  SELECT id FROM roles 
  WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' 
  AND name = 'DataGov Admin'
)
GROUP BY ao.module
ORDER BY auth_count DESC;

-- 5. Check DG tiles for OMEGA-DEV
SELECT 
  tile_code,
  tile_name,
  module,
  auth_object_name,
  is_active
FROM tiles
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module = 'DG'
ORDER BY tile_code;

-- 6. Summary
SELECT 
  'Users' as item,
  COUNT(*)::text as count
FROM users 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
UNION ALL
SELECT 
  'Roles',
  COUNT(*)::text
FROM roles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
UNION ALL
SELECT 
  'DG Auth Objects',
  COUNT(*)::text
FROM authorization_objects 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module = 'DG'
UNION ALL
SELECT 
  'DG Tiles',
  COUNT(*)::text
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module = 'DG'
UNION ALL
SELECT 
  'Role Authorizations',
  COUNT(*)::text
FROM role_authorization_objects 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';
