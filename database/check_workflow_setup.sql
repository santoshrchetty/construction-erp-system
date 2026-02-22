-- Check workflow definitions
SELECT * FROM workflow_definitions;

-- Check workflow steps
SELECT ws.*, wd.workflow_code
FROM workflow_steps ws
JOIN workflow_definitions wd ON wd.id = ws.workflow_id
ORDER BY wd.workflow_code, ws.step_sequence;

-- Check agent rules
SELECT * FROM agent_rules;

-- Check step agents
SELECT * FROM step_agents;
