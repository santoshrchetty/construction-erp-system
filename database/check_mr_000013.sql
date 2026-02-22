-- Check workflow for MR-01-2026-000013
SELECT 
  wi.id,
  wi.current_step_sequence,
  wi.status,
  wi.created_at,
  wi.updated_at,
  mr.request_number
FROM workflow_instances wi
JOIN material_requests mr ON wi.object_id::uuid = mr.id
WHERE mr.request_number = 'MR-01-2026-000013';

-- Check step instances for MR-01-2026-000013
SELECT 
  si.id,
  si.step_sequence,
  si.assigned_agent_name,
  si.status,
  ws.step_name
FROM step_instances si
JOIN workflow_steps ws ON si.workflow_step_id = ws.id
WHERE si.workflow_instance_id IN (
  SELECT wi.id FROM workflow_instances wi
  JOIN material_requests mr ON wi.object_id::uuid = mr.id
  WHERE mr.request_number = 'MR-01-2026-000013'
)
ORDER BY si.step_sequence;
