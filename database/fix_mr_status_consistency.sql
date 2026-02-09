-- Fix MR status consistency - SUBMITTED should trigger workflow, IN_APPROVAL means workflow active

-- Option 1: If you want SUBMITTED MRs to start approval workflow
-- Update SUBMITTED to IN_APPROVAL and ensure workflow instances exist
UPDATE material_requests
SET status = 'IN_APPROVAL'
WHERE status = 'SUBMITTED'
AND id::text IN (
  SELECT object_id FROM workflow_instances WHERE object_type = 'MATERIAL_REQUEST' AND status = 'ACTIVE'
);

-- Option 2: If you want to reset IN_APPROVAL back to SUBMITTED (to re-trigger)
-- UPDATE material_requests
-- SET status = 'SUBMITTED'
-- WHERE status = 'IN_APPROVAL';

-- Verify current status
SELECT 
  mr.request_number,
  mr.status as mr_status,
  wi.status as workflow_status,
  si.status as step_status,
  ws.step_name
FROM material_requests mr
LEFT JOIN workflow_instances wi ON wi.object_id = mr.id::text AND wi.object_type = 'MATERIAL_REQUEST'
LEFT JOIN step_instances si ON si.workflow_instance_id = wi.id AND si.status = 'PENDING'
LEFT JOIN workflow_steps ws ON ws.id = si.workflow_step_id
WHERE mr.status IN ('SUBMITTED', 'IN_APPROVAL')
ORDER BY mr.created_at DESC;
