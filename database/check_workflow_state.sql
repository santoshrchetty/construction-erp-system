-- Check workflow instance current_step_sequence
SELECT 
  wi.id,
  wi.current_step_sequence,
  wi.status,
  wi.created_at,
  wi.updated_at,
  mr.request_number
FROM workflow_instances wi
JOIN material_requests mr ON wi.object_id::uuid = mr.id
WHERE mr.request_number = 'MR-01-2026-000012';

-- Check workflow definition steps
SELECT ws.step_sequence, ws.step_name, ws.completion_rule
FROM workflow_steps ws
WHERE ws.workflow_id = (
  SELECT wi.workflow_id 
  FROM workflow_instances wi
  JOIN material_requests mr ON wi.object_id::uuid = mr.id
  WHERE mr.request_number = 'MR-01-2026-000012'
  LIMIT 1
)
ORDER BY ws.step_sequence;
