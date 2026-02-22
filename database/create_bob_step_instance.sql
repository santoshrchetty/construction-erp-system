-- Manually create step 2 instance for Bob Director
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
  'ef6ba83d-a16d-4c87-853e-953aafba2dd8',
  '61206887-364a-4f78-9a8e-5f23555a4660',
  2,
  '92d13ccc-8ba5-4cc1-88c6-14bb39d4e92a',
  'Bob Director',
  'DEPT_HEAD',
  'PENDING',
  NOW() + INTERVAL '48 hours',
  NOW()
);

-- Verify it was created
SELECT 
  si.*,
  ws.step_name
FROM step_instances si
JOIN workflow_steps ws ON si.workflow_step_id = ws.id
WHERE si.workflow_instance_id = 'ef6ba83d-a16d-4c87-853e-953aafba2dd8'
ORDER BY si.step_sequence;
