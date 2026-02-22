-- Manually create step 2 instance for Department Head approval
INSERT INTO step_instances (
  workflow_instance_id,
  workflow_step_id,
  step_sequence,
  assigned_agent_id,
  assigned_agent_name,
  assigned_agent_role,
  status,
  timeout_at,
  created_at
)
VALUES (
  '6afaa9c1-c85c-4252-91c1-85729f32d7da',
  '61206887-364a-4f78-9a8e-5f23555a4660',
  2,
  'a0a7c27e-f333-4206-8d6e-2038cba2f487',
  'Jane Manager',
  'Engineering Manager',
  'PENDING',
  NOW() + INTERVAL '48 hours',
  NOW()
);

-- Verify it was created
SELECT 
  si.step_sequence,
  si.status,
  si.assigned_agent_name,
  ws.step_name
FROM step_instances si
JOIN workflow_steps ws ON si.workflow_step_id = ws.id
WHERE si.workflow_instance_id = '6afaa9c1-c85c-4252-91c1-85729f32d7da'
ORDER BY si.step_sequence;
