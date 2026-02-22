-- Get the auth_object_id for ADMIN_WORKFLOW
SELECT id, object_code, object_name 
FROM authorization_objects 
WHERE object_code = 'ADMIN_WORKFLOW';

-- If it doesn't exist, create it
INSERT INTO authorization_objects (object_code, object_name, description, is_active)
VALUES ('ADMIN_WORKFLOW', 'Workflow Administration', 'Access to workflow configuration', true)
ON CONFLICT (object_code) DO NOTHING;

-- Grant authorization to your user
INSERT INTO user_authorizations (
  user_id,
  auth_object_id,
  field_values,
  valid_from,
  tenant_id
)
VALUES (
  (SELECT id FROM users WHERE email = 'john.engineer@example.com'),
  (SELECT id FROM authorization_objects WHERE object_code = 'ADMIN_WORKFLOW'),
  '{"ACTION": ["*"]}'::jsonb,
  CURRENT_DATE,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
);

-- Verify
SELECT 
  ua.*,
  u.email,
  ao.object_code
FROM user_authorizations ua
JOIN users u ON ua.user_id = u.id
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE ao.object_code = 'ADMIN_WORKFLOW';
