-- Verify OMEGA-DEV user authorizations
SELECT 
  COUNT(*) as total_dg_auths,
  STRING_AGG(ao.object_name, ', ' ORDER BY ao.object_name) as auth_objects
FROM role_authorization_objects rao
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE rao.role_id = 'b42f33bb-fe01-4ed4-a3c7-e006c8fc624d'
AND ao.module = 'DG';
