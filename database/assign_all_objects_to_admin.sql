-- ============================================================================
-- Assign ALL Objects to Admin Role (Super User)
-- ============================================================================
-- This assigns every authorization object to Admin role with full access
-- ============================================================================

-- Assign all authorization objects to Admin role
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
WHERE r.name = 'Admin'
  AND ao.is_active = true
  AND r.tenant_id = ao.tenant_id
ON CONFLICT (role_id, auth_object_id) DO NOTHING;

-- Verify Admin has access to all modules
SELECT 
  ao.module,
  COUNT(*) as object_count
FROM roles r
INNER JOIN role_authorization_objects rao ON r.id = rao.role_id
INNER JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE r.name = 'Admin'
GROUP BY ao.module
ORDER BY ao.module;

-- Show total assignments
SELECT 
  r.name as role_name,
  COUNT(*) as total_objects_assigned
FROM roles r
INNER JOIN role_authorization_objects rao ON r.id = rao.role_id
WHERE r.name = 'Admin'
GROUP BY r.name;
