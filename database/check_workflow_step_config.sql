-- Check workflow steps configuration
SELECT 
  ws.id,
  ws.step_sequence,
  ws.step_name,
  ws.completion_rule,
  wd.workflow_name
FROM workflow_steps ws
JOIN workflow_definitions wd ON ws.workflow_id = wd.id
WHERE wd.workflow_name = 'Standard Material Request Approval'
ORDER BY ws.step_sequence;

-- Check step agents configuration
SELECT 
  sa.id,
  ws.step_sequence,
  ws.step_name,
  sa.agent_rule_code,
  ar.rule_name,
  ar.rule_type
FROM step_agents sa
JOIN workflow_steps ws ON sa.workflow_step_id = ws.id
JOIN agent_rules ar ON sa.agent_rule_code = ar.rule_code
JOIN workflow_definitions wd ON ws.workflow_id = wd.id
WHERE wd.workflow_name = 'Standard Material Request Approval'
ORDER BY ws.step_sequence;

-- Check if there are any role assignments
SELECT COUNT(*) as role_assignment_count
FROM role_assignments
WHERE is_active = true;

-- Check org hierarchy
SELECT COUNT(*) as org_hierarchy_count
FROM org_hierarchy
WHERE is_active = true;
