-- Check step instances for active workflows

SELECT 
  si.id,
  si.workflow_instance_id,
  si.step_sequence,
  si.assigned_agent_id,
  si.assigned_agent_name,
  si.status,
  ws.step_name,
  ws.agent_rule,
  mr.request_number
FROM step_instances si
JOIN workflow_instances wi ON wi.id = si.workflow_instance_id
JOIN workflow_steps ws ON ws.id = si.workflow_step_id
JOIN material_requests mr ON mr.id::text = wi.object_id
WHERE wi.object_type = 'MATERIAL_REQUEST'
AND wi.status = 'ACTIVE'
ORDER BY si.created_at DESC;
