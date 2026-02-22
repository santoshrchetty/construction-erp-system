-- Simple fix: Remove auth objects to get tiles working
UPDATE tiles 
SET auth_object = NULL
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module_code = 'DG'
AND title IN ('Find Document', 'Create Document', 'Change Document');

-- Verify tiles are active
SELECT title, route, auth_object, is_active 
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module_code = 'DG'
ORDER BY sequence_order;