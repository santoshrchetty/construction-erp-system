-- Check the latest material request
SELECT id, request_number, status, created_at, tenant_id
FROM material_requests
ORDER BY created_at DESC
LIMIT 1;

-- Check if workflow was created for it
SELECT 
  wi.id,
  wi.object_id,
  wi.status,
  wi.tenant_id,
  wi.created_at
FROM workflow_instances wi
WHERE wi.object_type = 'MATERIAL_REQUEST'
ORDER BY wi.created_at DESC
LIMIT 1;
