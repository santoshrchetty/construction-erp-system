-- Check Bob's pending approvals (what getPendingApprovals returns)
SELECT 
  si.*,
  wi.object_type,
  wi.object_id,
  wi.context_data,
  wd.workflow_name,
  ws.step_name,
  mr.request_number
FROM step_instances si
JOIN workflow_instances wi ON si.workflow_instance_id = wi.id
JOIN workflow_definitions wd ON wi.workflow_id = wd.id
JOIN workflow_steps ws ON si.workflow_step_id = ws.id
LEFT JOIN material_requests mr ON wi.object_id::uuid = mr.id
WHERE si.assigned_agent_id = '92d13ccc-8ba5-4cc1-88c6-14bb39d4e92a'
AND si.status = 'PENDING'
ORDER BY si.created_at;
