-- Check if MAT module exists
SELECT id, module_code, module_name FROM modules WHERE module_code = 'MAT';

-- Check if Engineer role has MAT module assigned
SELECT rm.*, m.module_code, m.module_name 
FROM role_modules rm
JOIN modules m ON m.id = rm.module_id
WHERE rm.role_id = '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid
  AND m.module_code = 'MAT';

-- Assign MAT module to Engineer role if not exists
INSERT INTO role_modules (role_id, module_id, is_active, tenant_id)
SELECT 
  '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid,
  m.id,
  true,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid
FROM modules m 
WHERE m.module_code = 'MAT'
  AND NOT EXISTS (
    SELECT 1 FROM role_modules rm 
    WHERE rm.role_id = '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid 
      AND rm.module_id = m.id
  );

-- Verify assignment
SELECT rm.*, m.module_code, m.module_name 
FROM role_modules rm
JOIN modules m ON m.id = rm.module_id
WHERE rm.role_id = '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid
  AND m.module_code = 'MAT';