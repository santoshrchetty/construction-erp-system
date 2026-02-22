-- Check roles and auth objects in your Development tenant

-- 1. Check all roles in Development tenant
SELECT 'DEVELOPMENT TENANT ROLES' as check_type, name, id
FROM roles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY name;

-- 2. Check existing DG authorization objects in Development tenant
SELECT 'EXISTING DG AUTH OBJECTS' as check_type, object_name, id
FROM authorization_objects 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND object_name LIKE 'Z_DG_%'
ORDER BY object_name;

-- 3. Check if DataGov Admin role exists in any tenant
SELECT 'DATAGOV ADMIN SEARCH' as check_type, name, tenant_id, 
       (SELECT tenant_name FROM tenants WHERE id = roles.tenant_id) as tenant_name
FROM roles 
WHERE name = 'DataGov Admin';

-- 4. Check current DG tiles
SELECT 'CURRENT DG TILES' as check_type, title, auth_object, is_active
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module_code = 'DG'
ORDER BY sequence_order;