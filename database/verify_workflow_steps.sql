-- Verify workflow steps exist for MR approval workflow

SELECT 
  wd.workflow_code,
  wd.workflow_name,
  ws.step_sequence,
  ws.step_code,
  ws.step_name,
  ws.agent_rule,
  ws.completion_rule,
  ws.min_approvals,
  ws.is_active
FROM workflow_definitions wd
JOIN workflow_steps ws ON ws.workflow_id = wd.id
WHERE wd.workflow_code = 'MR_STD_APPROVAL'
ORDER BY ws.step_sequence;

-- Expected result: 2 steps
-- Step 1: Manager Approval (MGR_APPROVAL)
-- Step 2: Department Head Approval (DEPT_HEAD_APPROVAL)
