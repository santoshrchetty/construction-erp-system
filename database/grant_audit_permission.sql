-- Grant ADMIN_AUDIT_VIEW permission
INSERT INTO user_authorizations (
  user_id,
  auth_object_id,
  field_values,
  valid_from,
  tenant_id
)
SELECT 
  u.id,
  ao.id,
  '{"ACTION": ["*"]}'::jsonb,
  CURRENT_DATE,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
FROM users u
CROSS JOIN authorization_objects ao
WHERE u.email = 'john.engineer@example.com'
AND ao.object_name = 'ADMIN_AUDIT_VIEW'
ON CONFLICT DO NOTHING;

-- Verify
SELECT COUNT(*) as total_admin_permissions
FROM user_authorizations ua
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE ua.user_id = (SELECT id FROM users WHERE email = 'john.engineer@example.com')
AND ao.object_name LIKE 'ADMIN_%';
