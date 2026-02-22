-- Manually create step instance for MR-01-2026-000009
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
  '69f330c1-095a-4d81-9f3c-4894bace23ee',
  1,
  'a0a7c27e-f333-4206-8d6e-2038cba2f487',
  'Jane Manager',
  'Engineering Manager',
  'PENDING',
  NOW() + INTERVAL '48 hours',
  NOW()
);

-- Verify it was created
SELECT 
  si.id,
  si.status,
  si.assigned_agent_name,
  ws.step_name
FROM step_instances si
JOIN workflow_steps ws ON si.workflow_step_id = ws.id
WHERE si.workflow_instance_id = '6afaa9c1-c85c-4252-91c1-85729f32d7da';
