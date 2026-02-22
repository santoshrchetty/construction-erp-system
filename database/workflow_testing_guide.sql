-- Flexible Workflow Testing Guide
-- ================================

-- TEST USERS CREATED:
-- 1. john.engineer@example.com / password123 (John Engineer - Project Engineer)
-- 2. jane.manager@example.com / password123 (Jane Manager - Engineering Manager, DEPT_HEAD, PLANT_MGR)
-- 3. bob.director@example.com / password123 (Bob Director - Engineering Director)

-- WORKFLOW SETUP:
-- Step 1: Manager Approval (uses DIRECT_MANAGER rule - resolves to Jane Manager)
-- Step 2: Department Head Approval (uses DEPT_HEAD rule - resolves to Jane Manager)

-- TESTING STEPS:
-- ===============

-- 1. LOGIN AS JOHN ENGINEER
--    - Navigate to Material Requests
--    - Create new MR with plant P001
--    - Add line items
--    - Click Submit button

-- 2. VERIFY WORKFLOW CREATED
SELECT 
  wi.id as workflow_id,
  wi.object_id as mr_id,
  wi.status as workflow_status,
  wi.current_step_sequence,
  mr.request_number,
  mr.status as mr_status
FROM workflow_instances wi
JOIN material_requests mr ON mr.id::text = wi.object_id
WHERE wi.object_type = 'MATERIAL_REQUEST'
ORDER BY wi.created_at DESC
LIMIT 5;

-- 3. CHECK STEP INSTANCES (PENDING APPROVALS)
SELECT 
  si.id,
  wi.object_id as mr_id,
  mr.request_number,
  si.step_sequence,
  si.assigned_agent_name,
  si.status,
  si.created_at
FROM step_instances si
JOIN workflow_instances wi ON wi.id = si.workflow_instance_id
JOIN material_requests mr ON mr.id::text = wi.object_id
WHERE si.status = 'PENDING'
ORDER BY si.created_at DESC;

-- 4. LOGIN AS JANE MANAGER
--    - Navigate to /approvals/inbox
--    - Should see pending approval for Step 1
--    - Click Approve button

-- 5. VERIFY STEP 1 APPROVED
SELECT 
  si.step_sequence,
  si.assigned_agent_name,
  si.status,
  si.comments,
  si.actioned_at
FROM step_instances si
JOIN workflow_instances wi ON wi.id = si.workflow_instance_id
WHERE wi.object_type = 'MATERIAL_REQUEST'
ORDER BY si.created_at DESC;

-- 6. JANE APPROVES STEP 2
--    - Refresh /approvals/inbox
--    - Should see pending approval for Step 2
--    - Click Approve button

-- 7. VERIFY WORKFLOW COMPLETED
SELECT 
  wi.id,
  wi.status as workflow_status,
  wi.completed_at,
  mr.request_number,
  mr.status as mr_status
FROM workflow_instances wi
JOIN material_requests mr ON mr.id::text = wi.object_id
WHERE wi.object_type = 'MATERIAL_REQUEST'
ORDER BY wi.created_at DESC;

-- EXPECTED RESULTS:
-- - MR status should be 'APPROVED'
-- - Workflow status should be 'COMPLETED'
-- - Both step instances should have status 'APPROVED'
-- - All actioned_at timestamps should be populated

-- TROUBLESHOOTING QUERIES:
-- ========================

-- Check if org hierarchy is set up correctly
SELECT 
  oh.employee_name,
  oh.position_title,
  m.employee_name as manager_name,
  oh.department_code,
  oh.plant_code
FROM org_hierarchy oh
LEFT JOIN org_hierarchy m ON oh.manager_id = m.employee_id
ORDER BY oh.employee_name;

-- Check role assignments
SELECT 
  ra.role_code,
  oh.employee_name,
  ra.scope_type,
  ra.scope_value
FROM role_assignments ra
JOIN org_hierarchy oh ON ra.employee_id = oh.employee_id
ORDER BY oh.employee_name, ra.role_code;

-- Check workflow definition and steps
SELECT 
  wd.workflow_code,
  ws.step_sequence,
  ws.step_name,
  sa.agent_rule_code,
  ar.rule_type
FROM workflow_definitions wd
JOIN workflow_steps ws ON ws.workflow_id = wd.id
JOIN step_agents sa ON sa.workflow_step_id = ws.id
JOIN agent_rules ar ON ar.rule_code = sa.agent_rule_code
WHERE wd.workflow_code = 'MR_STANDARD'
ORDER BY ws.step_sequence;
