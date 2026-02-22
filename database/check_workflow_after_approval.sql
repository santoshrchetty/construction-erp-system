-- Check workflow instance status
SELECT 
  id,
  status,
  current_step_sequence,
  updated_at
FROM workflow_instances
WHERE id = '6afaa9c1-c85c-4252-91c1-85729f32d7da';

-- Check all step instances
SELECT 
  si.step_sequence,
  si.status,
  si.assigned_agent_name,
  ws.step_name
FROM step_instances si
JOIN workflow_steps ws ON si.workflow_step_id = ws.id
WHERE si.workflow_instance_id = '6afaa9c1-c85c-4252-91c1-85729f32d7da'
ORDER BY si.step_sequence;

-- Check material request status
SELECT request_number, status
FROM material_requests
WHERE request_number = 'MR-01-2026-000009';
