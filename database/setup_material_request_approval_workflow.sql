-- Material Request Approval Workflow Setup

-- 1. Insert workflow definition for Material Requests
INSERT INTO workflow_definitions (
  workflow_code,
  workflow_name,
  object_type,
  description,
  is_active
) VALUES (
  'MR_STD_APPROVAL',
  'Standard Material Request Approval',
  'MATERIAL_REQUEST',
  'Standard approval workflow for material requests',
  true
) ON CONFLICT (workflow_code) DO NOTHING;

-- 2. Get the workflow ID
DO $$
DECLARE
  v_workflow_id UUID;
BEGIN
  SELECT id INTO v_workflow_id 
  FROM workflow_definitions 
  WHERE object_type = 'MATERIAL_REQUEST' 
  AND workflow_code = 'MR_STD_APPROVAL'
  LIMIT 1;

  -- 3. Insert workflow start condition
  INSERT INTO workflow_start_conditions (
    workflow_id,
    condition_type,
    condition_operator,
    condition_value,
    priority,
    is_active
  ) VALUES (
    v_workflow_id,
    'request_type',
    'EQUALS',
    '"MATERIAL_REQ"',
    100,
    true
  ) ON CONFLICT DO NOTHING;

  -- 4. Insert workflow steps
  -- Step 1: Manager Approval
  INSERT INTO workflow_steps (
    workflow_id,
    step_sequence,
    step_code,
    step_name,
    step_type,
    agent_rule,
    completion_rule,
    min_approvals,
    is_active
  ) VALUES (
    v_workflow_id,
    1,
    'MGR_APPROVAL',
    'Manager Approval',
    'APPROVAL',
    'MANAGER',
    'ANY',
    1,
    true
  ) ON CONFLICT (workflow_id, step_sequence) DO NOTHING;

  -- Step 2: Department Head Approval
  INSERT INTO workflow_steps (
    workflow_id,
    step_sequence,
    step_code,
    step_name,
    step_type,
    agent_rule,
    completion_rule,
    min_approvals,
    is_active
  ) VALUES (
    v_workflow_id,
    2,
    'DEPT_HEAD_APPROVAL',
    'Department Head Approval',
    'APPROVAL',
    'DEPT_HEAD',
    'ANY',
    1,
    true
  ) ON CONFLICT (workflow_id, step_sequence) DO NOTHING;

END $$;

-- 4. Verify setup
SELECT 
  wd.workflow_name,
  ws.step_sequence,
  ws.step_name,
  ws.completion_rule
FROM workflow_definitions wd
JOIN workflow_steps ws ON ws.workflow_id = wd.id
WHERE wd.object_type = 'MATERIAL_REQUEST'
ORDER BY ws.step_sequence;
