-- Debug: Check if tiles exist and user has access

-- 1. Check if tiles were created
SELECT 'TILES CHECK' as check_type, title, is_active, module_code, tile_category
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module_code = 'DG'
ORDER BY sequence_order;

-- 2. Check authorization objects
SELECT 'AUTH OBJECTS' as check_type, object_name, description, module
FROM authorization_objects 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND object_name LIKE 'Z_DG_%';

-- 3. Check roles table structure first
SELECT 'ROLES STRUCTURE' as check_type, column_name
FROM information_schema.columns 
WHERE table_name = 'roles';

-- 4. Check role permissions (using correct column name)
SELECT 'ROLE PERMISSIONS' as check_type, r.name, ao.object_name
FROM roles r
JOIN role_authorization_objects rao ON r.id = rao.role_id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND ao.object_name LIKE 'Z_DG_%';