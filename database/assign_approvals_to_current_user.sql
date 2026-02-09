-- Update step instances to assign to current user

-- First, get your current user ID by running this:
SELECT id, email FROM auth.users WHERE email = '<YOUR_EMAIL>';

-- Then update the step instances (replace <YOUR_USER_ID> with the ID from above)
UPDATE step_instances
SET assigned_agent_id = '<YOUR_USER_ID>'
WHERE workflow_instance_id IN (
  SELECT id FROM workflow_instances 
  WHERE object_type = 'MATERIAL_REQUEST' 
  AND status = 'ACTIVE'
);

-- Verify
SELECT 
  si.id,
  si.assigned_agent_id,
  si.assigned_agent_name,
  si.status,
  ws.step_name,
  mr.request_number
FROM step_instances si
JOIN workflow_instances wi ON wi.id = si.workflow_instance_id
JOIN workflow_steps ws ON ws.id = si.workflow_step_id
JOIN material_requests mr ON mr.id::text = wi.object_id
WHERE wi.object_type = 'MATERIAL_REQUEST'
AND wi.status = 'ACTIVE';
