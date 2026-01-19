-- Add MATERIAL_MASTER_READ to authorization_objects table
-- This is the actual permission system being used by withAuth middleware

-- First, create the authorization object if it doesn't exist
INSERT INTO authorization_objects (object_name, description, module, is_active)
VALUES ('MATERIAL_MASTER_READ', 'Material Master Read Access', 'MM', true)
ON CONFLICT (object_name) DO NOTHING;

-- Grant to all roles via role_authorization_objects table
INSERT INTO role_authorization_objects (role_id, auth_object_id, field_values, is_active)
SELECT 
  r.id,
  ao.id,
  '{"ACTVT": ["03"]}'::jsonb,
  true
FROM roles r
CROSS JOIN authorization_objects ao
WHERE ao.object_name = 'MATERIAL_MASTER_READ'
  AND r.is_active = true
ON CONFLICT (role_id, auth_object_id) DO NOTHING;

-- Verify
SELECT 
  r.name as role_name,
  ao.object_name,
  ao.description,
  rao.field_values
FROM role_authorization_objects rao
JOIN roles r ON r.id = rao.role_id
JOIN authorization_objects ao ON ao.id = rao.auth_object_id
WHERE ao.object_name = 'MATERIAL_MASTER_READ'
ORDER BY r.name;
