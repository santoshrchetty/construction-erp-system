-- Show missing DG authorizations for admin@nttdemo.com role
WITH user_role AS (
  SELECT role_id, tenant_id 
  FROM users 
  WHERE email = 'admin@nttdemo.com'
),
missing_auths AS (
  SELECT DISTINCT
    t.auth_object,
    ao.object_name,
    ao.description,
    CASE WHEN rao.id IS NOT NULL THEN 'ASSIGNED' ELSE 'MISSING' END as status
  FROM tiles t
  LEFT JOIN authorization_objects ao ON t.auth_object = ao.object_name 
    AND ao.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  LEFT JOIN role_authorization_objects rao ON ao.id = rao.auth_object_id 
    AND rao.role_id = (SELECT role_id FROM user_role)
    AND rao.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  WHERE t.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
    AND t.tile_category = 'Document Governance'
    AND t.auth_object IS NOT NULL
)
SELECT 
  auth_object,
  object_name,
  description,
  status
FROM missing_auths
WHERE status = 'MISSING'
ORDER BY auth_object;