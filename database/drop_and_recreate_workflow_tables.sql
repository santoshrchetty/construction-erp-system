-- Complete cleanup and setup of flexible workflow system
-- WARNING: This will delete all existing workflow data

-- Drop all workflow tables in correct order (respecting foreign keys)
DROP TABLE IF EXISTS step_instances CASCADE;
DROP TABLE IF EXISTS workflow_instances CASCADE;
DROP TABLE IF EXISTS step_agents CASCADE;
DROP TABLE IF EXISTS workflow_steps CASCADE;
DROP TABLE IF EXISTS workflow_definitions CASCADE;
DROP TABLE IF EXISTS agent_rules CASCADE;

-- Note: Keep org_hierarchy and role_assignments as they have data

SELECT 'Old workflow tables dropped. Now run create_flexible_workflow_schema.sql' as message;
