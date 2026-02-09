-- Create step instances for active Material Request workflows

-- For each active workflow instance, create step instance for current step
INSERT INTO step_instances (
  workflow_instance_id,
  workflow_step_id,
  step_sequence,
  assigned_agent_id,
  assigned_agent_name,
  assigned_agent_role,
  status,
  timeout_at
)
SELECT 
  wi.id as workflow_instance_id,
  ws.id as workflow_step_id,
  ws.step_sequence,
  wi.requester_id as assigned_agent_id,  -- Temporarily assign to requester for testing
  'Test Approver' as assigned_agent_name,
  ws.agent_rule as assigned_agent_role,
  'PENDING' as status,
  NOW() + INTERVAL '48 hours' as timeout_at
FROM workflow_instances wi
JOIN workflow_steps ws ON ws.workflow_id = wi.workflow_id
WHERE wi.object_type = 'MATERIAL_REQUEST'
AND wi.status = 'ACTIVE'
AND ws.step_sequence = wi.current_step_sequence
AND NOT EXISTS (
  SELECT 1 FROM step_instances si 
  WHERE si.workflow_instance_id = wi.id 
  AND si.step_sequence = wi.current_step_sequence
);

-- Verify step instances created
SELECT 
  si.id,
  si.workflow_instance_id,
  si.step_sequence,
  si.assigned_agent_id,
  si.assigned_agent_name,
  si.assigned_agent_role,
  si.status,
  ws.step_name,
  mr.request_number
FROM step_instances si
JOIN workflow_instances wi ON wi.id = si.workflow_instance_id
JOIN workflow_steps ws ON ws.id = si.workflow_step_id
JOIN material_requests mr ON mr.id::text = wi.object_id
WHERE wi.object_type = 'MATERIAL_REQUEST'
AND wi.status = 'ACTIVE'
ORDER BY si.created_at DESC;
