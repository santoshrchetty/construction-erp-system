-- Replace with your tenant_id
-- Get tenant_id: SELECT id FROM tenants LIMIT 1;

-- Check what field values are actually stored for ProjMgr role
SELECT 
    r.name as role_name,
    ao.object_name,
    ao.module,
    rao.field_values,
    rao.module_full_access,
    rao.object_full_access
FROM role_authorization_objects rao
JOIN roles r ON rao.role_id = r.id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE r.name = 'ProjMgr'
  AND rao.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND ao.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY ao.module, ao.object_name;

-- Check authorization fields for MATERIAL_MASTER_READ
SELECT 
    ao.object_name,
    af.field_name,
    af.field_description,
    af.field_values,
    af.is_required
FROM authorization_objects ao
JOIN authorization_fields af ON ao.id = af.auth_object_id
WHERE ao.object_name = 'MATERIAL_MASTER_READ'
  AND ao.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND af.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY af.field_name;

-- Check if field_values column has data
SELECT 
    r.name as role_name,
    ao.object_name,
    CASE 
        WHEN rao.field_values IS NULL THEN 'NULL'
        WHEN rao.field_values::text = '{}' THEN 'EMPTY OBJECT'
        ELSE 'HAS DATA: ' || rao.field_values::text
    END as field_values_status
FROM role_authorization_objects rao
JOIN roles r ON rao.role_id = r.id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE r.name = 'ProjMgr'
  AND rao.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND ao.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';
