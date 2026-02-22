-- Create authorization objects for workflow admin
INSERT INTO authorization_objects (object_name, description, module, is_active, tenant_id)
VALUES 
  ('ADMIN_WORKFLOW', 'Workflow Administration', 'admin', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'),
  ('ADMIN_ROLES', 'Role Assignments', 'admin', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'),
  ('ADMIN_ORG', 'Org Hierarchy', 'admin', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15')
ON CONFLICT (object_name) DO NOTHING;

-- Grant permissions to your user (replace email with your actual login)
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
AND ao.object_name IN ('ADMIN_WORKFLOW', 'ADMIN_ROLES', 'ADMIN_ORG')
ON CONFLICT DO NOTHING;

-- Verify authorizations
SELECT 
  u.email,
  ao.object_name,
  ao.description,
  ua.field_values
FROM user_authorizations ua
JOIN users u ON ua.user_id = u.id
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE ao.object_name IN ('ADMIN_WORKFLOW', 'ADMIN_ROLES', 'ADMIN_ORG')
AND u.email = 'john.engineer@example.com';
