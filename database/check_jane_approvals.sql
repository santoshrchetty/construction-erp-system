-- Check Jane Manager's user ID and pending approvals
SELECT 
  u.id as jane_user_id,
  u.email,
  u.first_name,
  u.last_name
FROM users u
WHERE email = 'jane.manager@example.com';

-- Check pending approvals for Jane
SELECT 
  si.id,
  si.assigned_agent_id,
  mr.request_number,
  si.step_sequence,
  si.assigned_agent_name,
  si.status,
  wi.object_type,
  wi.object_id
FROM step_instances si
JOIN workflow_instances wi ON wi.id = si.workflow_instance_id
LEFT JOIN material_requests mr ON mr.id::text = wi.object_id
WHERE si.assigned_agent_id::text IN (
  SELECT id::text FROM users WHERE email = 'jane.manager@example.com'
)
AND si.status = 'PENDING';
