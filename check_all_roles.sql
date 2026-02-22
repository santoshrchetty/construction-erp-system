-- Check all roles across all tenants to understand the role structure

-- 1. Check all roles in your tenant
SELECT 'YOUR TENANT ROLES' as check_type, name, tenant_id, id
FROM roles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY name;

-- 2. Check if DataGov Admin exists in other tenants
SELECT 'DATAGOV ADMIN IN OTHER TENANTS' as check_type, name, tenant_id, id
FROM roles 
WHERE name = 'DataGov Admin'
ORDER BY tenant_id;

-- 3. Check all roles with 'DataGov' or 'DG' in name
SELECT 'DG RELATED ROLES' as check_type, name, tenant_id, id
FROM roles 
WHERE name ILIKE '%datagov%' OR name ILIKE '%dg%'
ORDER BY tenant_id, name;

-- 4. Check if there are any existing DG authorization objects
SELECT 'EXISTING DG AUTH OBJECTS' as check_type, object_name, tenant_id, id
FROM authorization_objects 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND object_name LIKE 'Z_DG_%'
ORDER BY object_name;

-- 5. Check tenants table structure first
SELECT 'TENANTS STRUCTURE' as check_type, column_name
FROM information_schema.columns 
WHERE table_name = 'tenants';

-- 6. Check all tenants (using correct column name)
SELECT 'ALL TENANTS' as check_type, id, tenant_name
FROM tenants
ORDER BY tenant_name;