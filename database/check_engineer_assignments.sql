-- Check table structure to find correct column name
SELECT column_name FROM information_schema.columns WHERE table_name = 'role_authorization_objects';

-- Check if MAT_REQ permissions exist and their module
SELECT object_name, module, description, is_active
FROM authorization_objects 
WHERE object_name IN ('MAT_REQ_READ', 'MAT_REQ_WRITE');

-- Check Engineer role ID
SELECT id, name FROM roles WHERE name = 'Engineer';