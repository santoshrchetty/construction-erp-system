-- Clean up old workflow data and set up new flexible workflow system

-- 1. Delete all workflow instances and step instances
DELETE FROM step_instances;
DELETE FROM workflow_instances;

-- 2. Delete old workflow configuration
DELETE FROM step_agents;
DELETE FROM workflow_steps;
DELETE FROM workflow_definitions;
DELETE FROM agent_rules;

-- Verify cleanup
SELECT 'workflow_definitions' as table_name, COUNT(*) as count FROM workflow_definitions
UNION ALL
SELECT 'workflow_steps', COUNT(*) FROM workflow_steps
UNION ALL
SELECT 'agent_rules', COUNT(*) FROM agent_rules
UNION ALL
SELECT 'step_agents', COUNT(*) FROM step_agents
UNION ALL
SELECT 'workflow_instances', COUNT(*) FROM workflow_instances
UNION ALL
SELECT 'step_instances', COUNT(*) FROM step_instances;
