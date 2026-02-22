-- Check recent material requests
SELECT id, request_number, status, created_at, requested_by
FROM material_requests
ORDER BY created_at DESC
LIMIT 5;

-- Check workflow instances for material requests
SELECT 
  wi.id,
  wi.object_type,
  wi.object_id,
  wi.status,
  wi.current_step_sequence,
  wi.created_at,
  wd.workflow_name,
  mr.request_number
FROM workflow_instances wi
JOIN workflow_definitions wd ON wi.workflow_id = wd.id
LEFT JOIN material_requests mr ON wi.object_id::uuid = mr.id
WHERE wi.object_type = 'MATERIAL_REQUEST'
ORDER BY wi.created_at DESC;

-- Check step instances (pending approvals)
SELECT 
  si.id,
  si.status,
  si.assigned_agent_id,
  si.assigned_agent_name,
  si.step_sequence,
  si.created_at,
  ws.step_name,
  mr.request_number
FROM step_instances si
JOIN workflow_instances wi ON si.workflow_instance_id = wi.id
JOIN workflow_steps ws ON si.workflow_step_id = ws.id
LEFT JOIN material_requests mr ON wi.object_id::uuid = mr.id
WHERE wi.object_type = 'MATERIAL_REQUEST'
ORDER BY si.created_at DESC;
