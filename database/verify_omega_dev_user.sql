-- Verify OMEGA-DEV user exists and has authorizations
SELECT 
  u.id,
  u.email,
  t.tenant_code,
  r.name as role_name,
  COUNT(rao.auth_object_id) as dg_auth_count
FROM users u
JOIN tenants t ON u.tenant_id = t.id
LEFT JOIN roles r ON u.role_id = r.id
LEFT JOIN role_authorization_objects rao ON r.id = rao.role_id
LEFT JOIN authorization_objects ao ON rao.auth_object_id = ao.id AND ao.module = 'DG'
WHERE u.email = 'internaluser@abc.com'
AND t.tenant_code = 'OMEGA-DEV'
GROUP BY u.id, u.email, t.tenant_code, r.name;
