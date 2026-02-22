-- Check if step_agents are properly configured for step 1
SELECT 
  ws.id as step_id,
  ws.step_name,
  sa.id as step_agent_id,
  sa.agent_rule_code,
  ar.rule_type,
  ar.resolution_logic
FROM workflow_steps ws
LEFT JOIN step_agents sa ON ws.id = sa.workflow_step_id
LEFT JOIN agent_rules ar ON sa.agent_rule_code = ar.rule_code
WHERE ws.step_sequence = 1
AND ws.workflow_id = (
  SELECT workflow_id FROM workflow_instances WHERE id = '6afaa9c1-c85c-4252-91c1-85729f32d7da'
);
