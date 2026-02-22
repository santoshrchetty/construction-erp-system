-- Check complete authorization chain for DataGov Admin

-- 1. Get DataGov Admin role ID
SELECT 'DATAGOV ADMIN ROLE' as check_type, id, name
FROM roles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND name = 'DataGov Admin';

-- 2. Check DG authorization objects
SELECT 'DG AUTH OBJECTS' as check_type, id, object_name, description
FROM authorization_objects 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND object_name IN ('Z_DG_RECORDS_DISPLAY', 'Z_DG_RECORDS_CREATE', 'Z_DG_RECORDS_CHANGE');

-- 3. Check role-auth object assignments for DataGov Admin
SELECT 'ROLE AUTH ASSIGNMENTS' as check_type, 
       r.name as role_name,
       ao.object_name,
       rao.field_values
FROM roles r
JOIN role_authorization_objects rao ON r.id = rao.role_id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.name = 'DataGov Admin'
AND ao.object_name LIKE 'Z_DG_%';

-- 4. Check users assigned to DataGov Admin role
SELECT 'USERS WITH DATAGOV ADMIN' as check_type, 
       u.email,
       r.name as role_name
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
WHERE r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.name = 'DataGov Admin';

-- 5. Check DG tiles and their auth objects
SELECT 'DG TILES STATUS' as check_type, 
       title, 
       auth_object, 
       is_active,
       route
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module_code = 'DG'
ORDER BY sequence_order;