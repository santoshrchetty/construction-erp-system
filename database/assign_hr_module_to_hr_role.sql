-- ============================================================================
-- Assign HR Module Objects to HR Role
-- ============================================================================
-- This assigns all authorization objects in the 'hr' module to the HR role
-- ============================================================================

-- Get HR role ID and assign all hr module objects
INSERT INTO role_authorization_objects (
  role_id,
  auth_object_id,
  field_values,
  module_full_access,
  object_full_access,
  tenant_id,
  is_active
)
SELECT 
  r.id as role_id,
  ao.id as auth_object_id,
  '{"ACTVT": ["*"], "COMP_CODE": ["*"], "PLANT": ["*"], "DEPT": ["*"]}'::jsonb as field_values,
  false as module_full_access,
  true as object_full_access,
  r.tenant_id,
  true as is_active
FROM roles r
CROSS JOIN authorization_objects ao
WHERE r.name = 'HR'
  AND ao.module = 'hr'
  AND ao.is_active = true
  AND r.tenant_id = ao.tenant_id
ON CONFLICT (role_id, auth_object_id) DO NOTHING;

-- Verify assignments
SELECT 
  r.name as role_name,
  ao.object_name,
  ao.description,
  rao.object_full_access
FROM roles r
INNER JOIN role_authorization_objects rao ON r.id = rao.role_id
INNER JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE r.name = 'HR'
  AND ao.module = 'hr'
ORDER BY ao.object_name;
