-- Replace with your tenant_id
-- Get tenant_id: SELECT id FROM tenants LIMIT 1;

-- Check role_authorization_objects table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'role_authorization_objects'
ORDER BY ordinal_position;

-- Check if field_values is JSONB and what format it uses
SELECT 
    r.name as role_name,
    ao.object_name,
    jsonb_pretty(rao.field_values) as field_values_formatted
FROM role_authorization_objects rao
JOIN roles r ON rao.role_id = r.id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE rao.field_values IS NOT NULL 
  AND rao.field_values::text != '{}'
  AND rao.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND ao.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
LIMIT 5;

-- Expected format should be:
-- {
--   "COMP_CODE": ["1000", "2000", "*"],
--   "PLANT": ["P001", "P002", "*"],
--   "DEPT": ["ADMIN", "FIELD", "*"],
--   "ACTVT": ["01", "02", "03", "*"]
-- }
