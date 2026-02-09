-- Check what's in the modules table
SELECT * FROM modules WHERE is_active = true ORDER BY module_code;

-- Check if materials module exists in modules table
SELECT * FROM modules WHERE module_code = 'MM' OR module_name LIKE '%material%';

-- If MM module exists, assign it to Engineer role
INSERT INTO role_modules (role_id, module_id, is_active, tenant_id)
SELECT r.id, m.id, true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid
FROM roles r, modules m 
WHERE r.name = 'Engineer' 
  AND m.module_code = 'MM'
  AND NOT EXISTS (
    SELECT 1 FROM role_modules rm 
    WHERE rm.role_id = r.id AND rm.module_id = m.id
  );