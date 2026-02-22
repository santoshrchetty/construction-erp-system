-- Check the specific material request status
SELECT id, request_number, status, created_at
FROM material_requests
WHERE request_number = 'MR-01-2026-000007';

-- Check the workflow instance status
SELECT 
  wi.id,
  wi.status,
  wi.current_step_sequence,
  wd.workflow_name
FROM workflow_instances wi
JOIN workflow_definitions wd ON wi.workflow_id = wd.id
JOIN material_requests mr ON wi.object_id::uuid = mr.id
WHERE mr.request_number = 'MR-01-2026-000007';

-- Check all step instances for this workflow
SELECT 
  si.step_sequence,
  si.status,
  si.assigned_agent_name,
  ws.step_name,
  ws.completion_rule
FROM step_instances si
JOIN workflow_instances wi ON si.workflow_instance_id = wi.id
JOIN workflow_steps ws ON si.workflow_step_id = ws.id
JOIN material_requests mr ON wi.object_id::uuid = mr.id
WHERE mr.request_number = 'MR-01-2026-000007'
ORDER BY si.step_sequence;

-- Check how many steps are in this workflow
SELECT 
  ws.step_sequence,
  ws.step_name,
  ws.completion_rule
FROM workflow_steps ws
JOIN workflow_instances wi ON ws.workflow_id = wi.workflow_id
JOIN material_requests mr ON wi.object_id::uuid = mr.id
WHERE mr.request_number = 'MR-01-2026-000007'
ORDER BY ws.step_sequence;
