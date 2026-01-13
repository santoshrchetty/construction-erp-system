-- SAP-Aligned Approval Engine - Complete Installation Script
-- Run this file to install the complete approval engine

-- This script will execute all the required SQL files in the correct order
-- Make sure to run this in a PostgreSQL environment with appropriate permissions

\echo 'Starting SAP-Aligned Approval Engine Installation...'
\echo ''

-- Step 1: Create Schema and Tables
\echo 'Step 1: Creating database schema and tables...'
\i 01-sap-approval-schema.sql
\echo 'Schema creation completed.'
\echo ''

-- Step 2: Insert Master Data
\echo 'Step 2: Inserting master data (agent rules, org hierarchy, roles)...'
\i 02-sap-approval-master-data.sql
\echo 'Master data insertion completed.'
\echo ''

-- Step 3: Create Workflow Definitions
\echo 'Step 3: Creating workflow definitions and steps...'
\i 03-sap-approval-workflows.sql
\echo 'Workflow definitions completed.'
\echo ''

-- Step 4: Insert Test Data and Verification
\echo 'Step 4: Inserting test data and running verification queries...'
\i 04-sap-approval-test-data.sql
\echo 'Test data and verification completed.'
\echo ''

-- Final verification
\echo 'Installation Summary:'
\echo '===================='

SELECT 'Workflow Definitions' as component, COUNT(*) as count FROM workflow_definitions WHERE is_active = true
UNION ALL
SELECT 'Workflow Steps', COUNT(*) FROM workflow_steps WHERE is_active = true
UNION ALL
SELECT 'Agent Rules', COUNT(*) FROM agent_rules WHERE is_active = true
UNION ALL
SELECT 'Employees', COUNT(*) FROM org_hierarchy WHERE is_active = true
UNION ALL
SELECT 'Role Assignments', COUNT(*) FROM role_assignments WHERE is_active = true
UNION ALL
SELECT 'Active Workflow Instances', COUNT(*) FROM workflow_instances WHERE status = 'ACTIVE';

\echo ''
\echo 'SAP-Aligned Approval Engine Installation Completed Successfully!'
\echo ''
\echo 'Next Steps:'
\echo '1. Test the approval engine using the SAPAlignedApprovalService'
\echo '2. Create additional workflows as needed'
\echo '3. Configure the approval configuration UI'
\echo '4. Set up notifications and escalations'
\echo ''