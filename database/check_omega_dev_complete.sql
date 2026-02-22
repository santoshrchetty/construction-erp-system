-- Comprehensive check for OMEGA-DEV user setup

-- 1. User and Role Info
SELECT 
  'User & Role Info' as check_type,
  u.email,
  t.tenant_code,
  r.name as role_name,
  u.tenant_id as user_tenant_id,
  r.tenant_id as role_tenant_id,
  CASE WHEN u.tenant_id = r.tenant_id THEN '✅ MATCH' ELSE '❌ MISMATCH' END as tenant_match
FROM users u
JOIN tenants t ON u.tenant_id = t.id
JOIN roles r ON u.role_id = r.id
WHERE u.email = 'internaluser@abc.com'
AND t.tenant_code = 'OMEGA-DEV';

-- 2. DG Authorization Count
SELECT 
  'DG Authorizations' as check_type,
  r.name as role_name,
  COUNT(rao.auth_object_id) as dg_auth_count
FROM users u
JOIN roles r ON u.role_id = r.id
LEFT JOIN role_authorization_objects rao ON r.id = rao.role_id
LEFT JOIN authorization_objects ao ON rao.auth_object_id = ao.id AND ao.module = 'DG'
WHERE u.email = 'internaluser@abc.com'
AND u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
GROUP BY r.name;

-- 3. Sample DG Authorizations (first 5)
SELECT 
  'Sample Authorizations' as check_type,
  ao.object_name,
  ao.description,
  rao.field_values
FROM users u
JOIN roles r ON u.role_id = r.id
JOIN role_authorization_objects rao ON r.id = rao.role_id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE u.email = 'internaluser@abc.com'
AND u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND ao.module = 'DG'
ORDER BY ao.object_name
LIMIT 5;

-- 4. Tile Access Check
SELECT 
  'Tile Access' as check_type,
  t.title,
  t.auth_object,
  CASE 
    WHEN rao.id IS NOT NULL THEN '✅ HAS ACCESS'
    ELSE '❌ NO ACCESS'
  END as access_status
FROM tiles t
LEFT JOIN authorization_objects ao ON t.auth_object = ao.object_name
LEFT JOIN role_authorization_objects rao ON ao.id = rao.auth_object_id 
  AND rao.role_id = (
    SELECT role_id FROM users 
    WHERE email = 'internaluser@abc.com' 
    AND tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  )
WHERE t.tile_category = 'Document Governance'
ORDER BY t.sequence_order
LIMIT 5;
