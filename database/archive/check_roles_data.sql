-- Check if roles table exists and has data
SELECT 'roles' as table_name, COUNT(*) as count FROM roles
UNION ALL
SELECT 'role_authorization_objects' as table_name, COUNT(*) as count FROM role_authorization_objects
UNION ALL
SELECT 'authorization_objects' as table_name, COUNT(*) as count FROM authorization_objects
UNION ALL
SELECT 'authorization_fields' as table_name, COUNT(*) as count FROM authorization_fields;

-- Check roles table structure and data
SELECT * FROM roles LIMIT 10;

-- Check role authorization assignments
SELECT rao.*, r.name as role_name 
FROM role_authorization_objects rao
LEFT JOIN roles r ON rao.role_id = r.id
LIMIT 10;