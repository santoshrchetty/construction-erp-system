-- Comprehensive Cleanup: Drop ALL old approval tables
-- Keep only the 6 flexible workflow tables

-- Drop old approval system tables (20 tables)
DROP TABLE IF EXISTS approval_actions CASCADE;
DROP TABLE IF EXISTS approval_delegations CASCADE;
DROP TABLE IF EXISTS approval_document_types CASCADE;
DROP TABLE IF EXISTS approval_executions CASCADE;
DROP TABLE IF EXISTS approval_field_definitions CASCADE;
DROP TABLE IF EXISTS approval_field_options CASCADE;
DROP TABLE IF EXISTS approval_instances CASCADE;
DROP TABLE IF EXISTS approval_level_templates CASCADE;
DROP TABLE IF EXISTS approval_object_registry CASCADE;
DROP TABLE IF EXISTS approval_object_types CASCADE;
DROP TABLE IF EXISTS approval_policies CASCADE;
DROP TABLE IF EXISTS approval_steps CASCADE;
DROP TABLE IF EXISTS customer_approval_configuration CASCADE;
DROP TABLE IF EXISTS flexible_approval_levels CASCADE;
DROP TABLE IF EXISTS po_approval_history CASCADE;
DROP TABLE IF EXISTS po_approval_policies CASCADE;
DROP TABLE IF EXISTS po_approval_routes CASCADE;
DROP TABLE IF EXISTS project_workflows CASCADE;
DROP TABLE IF EXISTS step_completion_status CASCADE;
DROP TABLE IF EXISTS tile_workflow_status CASCADE;

-- Verify remaining workflow tables (should be 6)
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size('public.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
  AND (tablename LIKE '%approval%' OR tablename LIKE '%workflow%' OR tablename LIKE '%step%' OR tablename LIKE '%agent%')
ORDER BY tablename;

-- Expected result: Only these 6 tables should remain:
-- 1. agent_rules
-- 2. step_agents
-- 3. step_instances
-- 4. workflow_definitions
-- 5. workflow_instances
-- 6. workflow_steps
