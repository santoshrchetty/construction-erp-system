-- Check visible DG tiles with proper tenant isolation
WITH current_user_info AS (
  SELECT 
    u.id as user_id,
    u.tenant_id,
    u.role_id,
    u.email
  FROM users u
  WHERE u.email = 'admin@nttdemo.com'
    AND u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid
)
SELECT 
  t.id,
  t.title,
  t.subtitle,
  t.route,
  t.auth_object,
  t.sequence_order,
  CASE 
    WHEN rao.id IS NOT NULL THEN true
    ELSE false
  END as has_access
FROM tiles t
CROSS JOIN current_user_info cui
LEFT JOIN authorization_objects ao ON t.auth_object = ao.object_name 
  AND ao.tenant_id = cui.tenant_id
LEFT JOIN role_authorization_objects rao ON ao.id = rao.auth_object_id 
  AND rao.role_id = cui.role_id
  AND rao.tenant_id = cui.tenant_id
WHERE t.tenant_id = cui.tenant_id
  AND t.tile_category = 'Document Governance'
  AND t.is_active = true
ORDER BY t.sequence_order;