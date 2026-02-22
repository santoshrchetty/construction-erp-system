-- Create missing authorization objects
INSERT INTO authorization_objects (object_name, description, module, is_active, tenant_id)
VALUES 
  ('ADMIN_DASHBOARD', 'Admin Dashboard', 'admin', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'),
  ('ADMIN_USER_MGMT', 'User Management', 'admin', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'),
  ('ADMIN_ROLE_MGMT', 'Role Management', 'admin', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'),
  ('ADMIN_SYS_CONFIG', 'System Configuration', 'admin', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'),
  ('ADMIN_ROLE_ASSIGN', 'User Role Assignment', 'admin', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'),
  ('ADMIN_AUTH_MGMT', 'Authorization Objects', 'admin', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15')
ON CONFLICT (object_name) DO NOTHING;

-- Grant all admin permissions to your user
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
AND ao.object_name IN (
  'ADMIN_DASHBOARD', 'ADMIN_USER_MGMT', 'ADMIN_ROLE_MGMT', 
  'ADMIN_SYS_CONFIG', 'ADMIN_ROLE_ASSIGN', 'ADMIN_AUTH_MGMT',
  'ADMIN_WORKFLOW', 'ADMIN_ROLES', 'ADMIN_ORG'
)
ON CONFLICT DO NOTHING;

-- Verify all authorizations
SELECT 
  ao.object_name,
  ao.description,
  COUNT(ua.id) as granted
FROM authorization_objects ao
LEFT JOIN user_authorizations ua ON ao.id = ua.auth_object_id 
  AND ua.user_id = (SELECT id FROM users WHERE email = 'john.engineer@example.com')
WHERE ao.object_name LIKE 'ADMIN_%'
GROUP BY ao.object_name, ao.description
ORDER BY ao.object_name;
