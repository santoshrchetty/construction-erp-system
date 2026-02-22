-- Check existing submitted MRs that don't have workflow instances
SELECT DISTINCT
  mr.id,
  mr.request_number,
  mr.status,
  mr.created_by,
  mr.created_at,
  wi.id as workflow_instance_id,
  STRING_AGG(DISTINCT mri.plant_code, ', ') as plant_codes
FROM material_requests mr
LEFT JOIN material_request_items mri ON mri.request_id = mr.id
LEFT JOIN workflow_instances wi ON wi.object_id = mr.id::text AND wi.object_type = 'MATERIAL_REQUEST'
WHERE mr.status IN ('PENDING_APPROVAL', 'SUBMITTED')
GROUP BY mr.id, mr.request_number, mr.status, mr.created_by, mr.created_at, wi.id
ORDER BY mr.created_at DESC;
