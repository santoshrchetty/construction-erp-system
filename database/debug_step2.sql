-- Get Bob's employee_id
SELECT employee_id, employee_name, position_title, department_code
FROM org_hierarchy
WHERE employee_name = 'Bob Director';

-- Get Bob's DEPT_HEAD role for ENG
SELECT ra.id, ra.employee_id, ra.role_code, ra.scope_value, ra.is_active
FROM role_assignments ra
WHERE ra.employee_id = (
  SELECT employee_id FROM org_hierarchy WHERE employee_name = 'Bob Director'
)
AND ra.role_code = 'DEPT_HEAD';

-- Check step 2 definition and agents
SELECT 
  ws.id as step_id,
  ws.step_sequence,
  ws.step_name,
  sa.id as step_agent_id,
  sa.agent_rule_code,
  ar.rule_type,
  ar.resolution_logic
FROM workflow_steps ws
LEFT JOIN step_agents sa ON ws.id = sa.workflow_step_id
LEFT JOIN agent_rules ar ON sa.agent_rule_code = ar.rule_code
WHERE ws.workflow_id = (
  SELECT workflow_id FROM workflow_instances WHERE id = 'ef6ba83d-a16d-4c87-853e-953aafba2dd8'
)
AND ws.step_sequence = 2;

-- Check if step 2 instance exists
SELECT * FROM step_instances
WHERE workflow_instance_id = 'ef6ba83d-a16d-4c87-853e-953aafba2dd8'
AND step_sequence = 2;
