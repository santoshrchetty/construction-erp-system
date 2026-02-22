-- Check workflow instance for MR-01-2026-000011
SELECT 
  wi.id,
  wi.status,
  wi.current_step_sequence,
  wd.workflow_name
FROM workflow_instances wi
JOIN workflow_definitions wd ON wi.workflow_id = wd.id
JOIN material_requests mr ON wi.object_id::uuid = mr.id
WHERE mr.request_number = 'MR-01-2026-000011';

-- Check step instances
SELECT 
  si.step_sequence,
  si.status,
  si.assigned_agent_name,
  ws.step_name
FROM step_instances si
JOIN workflow_instances wi ON si.workflow_instance_id = wi.id
JOIN workflow_steps ws ON si.workflow_step_id = ws.id
JOIN material_requests mr ON wi.object_id::uuid = mr.id
WHERE mr.request_number = 'MR-01-2026-000011'
ORDER BY si.step_sequence;
