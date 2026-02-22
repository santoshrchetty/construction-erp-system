-- Fix invalid plant codes in role_assignments
-- Replace PLT_MUM and PLT_DEL with valid plant codes

-- Update PLT_MUM to P001 (Test Project - Site)
UPDATE role_assignments
SET scope_value = 'P001'
WHERE scope_type = 'PLANT' 
  AND scope_value = 'PLT_MUM';

-- Update PLT_DEL to P002 (GMH Mall - Site)
UPDATE role_assignments
SET scope_value = 'P002'
WHERE scope_type = 'PLANT' 
  AND scope_value = 'PLT_DEL';

-- Verify updated role assignments
SELECT 
  ra.role_code,
  oh.employee_name,
  ra.scope_type,
  ra.scope_value
FROM role_assignments ra
JOIN org_hierarchy oh ON ra.employee_id = oh.employee_id
WHERE ra.scope_type = 'PLANT'
ORDER BY ra.scope_value, ra.role_code;
