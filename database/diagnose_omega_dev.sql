-- Check what exists for OMEGA-DEV
SELECT 'DG Auth Objects in OMEGA-DEV' as check_type, COUNT(*) as count
FROM authorization_objects 
WHERE module = 'DG' AND tenant_id = (SELECT id FROM tenants WHERE tenant_code = 'OMEGA-DEV')

UNION ALL

SELECT 'User Tenant Link', COUNT(*)
FROM user_tenants ut
WHERE ut.user_id = (SELECT id FROM users WHERE email = 'internaluser@abc.com')
AND ut.tenant_id = (SELECT id FROM tenants WHERE tenant_code = 'OMEGA-DEV')

UNION ALL

SELECT 'Role Auth for OMEGA-DEV', COUNT(*)
FROM role_authorization_objects rao
WHERE rao.role_id = (SELECT role_id FROM users WHERE email = 'internaluser@abc.com')
AND rao.tenant_id = (SELECT id FROM tenants WHERE tenant_code = 'OMEGA-DEV')
AND rao.auth_object_id IN (SELECT id FROM authorization_objects WHERE module = 'DG');
