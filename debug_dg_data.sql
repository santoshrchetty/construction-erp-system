-- Diagnostic: Check DG data for admin@nttdemo.com
SELECT 'DG Tiles Count' as check_type, COUNT(*)::text as result
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' 
AND module_code = 'DG' 
AND is_active = true

UNION ALL

SELECT 'DG Auth Objects Count', COUNT(*)::text
FROM authorization_objects 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' 
AND module = 'DG'

UNION ALL

SELECT 'Role Authorizations Count', COUNT(*)::text
FROM role_authorization_objects 
WHERE role_id = '00e8b52d-e653-47c2-b679-7d9623973a44'
AND tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

-- Show actual DG tiles
SELECT id, title, auth_object, is_active
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' 
AND module_code = 'DG'
LIMIT 5;