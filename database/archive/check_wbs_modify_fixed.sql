-- Check if PS_WBS_MODIFY auth object exists and admin has access
-- ==============================================================

-- Check if PS_WBS_MODIFY authorization object exists
SELECT 'AUTH OBJECT CHECK' as check_type, object_name, description, module
FROM authorization_objects 
WHERE object_name = 'PS_WBS_MODIFY';

-- Check role_authorization_mapping table structure
SELECT 'TABLE STRUCTURE' as check_type, column_name, data_type
FROM information_schema.columns 
WHERE table_name = 'role_authorization_mapping'
ORDER BY ordinal_position;

-- Check if admin role has PS_WBS_MODIFY permission (using correct column names)
SELECT 'ROLE PERMISSION CHECK' as check_type, r.name as role_name, ram.auth_object_name
FROM roles r
JOIN role_authorization_mapping ram ON r.name = ram.role_name
WHERE ram.auth_object_name = 'PS_WBS_MODIFY'
AND r.name = 'Admin';