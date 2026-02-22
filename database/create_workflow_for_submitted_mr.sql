-- Manually create workflow instance for submitted MR
-- MR ID: 17e9210c-86b1-4886-af61-c1cd1368483e

DO $$
DECLARE
  v_mr_id TEXT := '17e9210c-86b1-4886-af61-c1cd1368483e';
  v_workflow_def_id UUID;
  v_workflow_instance_id UUID;
  v_step1_id UUID;
  v_requester_id TEXT := 'ebe3615e-673e-4f7c-a247-69ce91e6653d';
  v_manager_id TEXT;
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM tenants ORDER BY created_at LIMIT 1;
  
  -- Get manager ID from org_hierarchy
  SELECT manager_id INTO v_manager_id 
  FROM org_hierarchy 
  WHERE employee_id = v_requester_id;
  
  -- Get workflow definition for Material Request
  SELECT id INTO v_workflow_def_id 
  FROM workflow_definitions 
  WHERE workflow_code = 'MR_STANDARD';
  
  IF v_workflow_def_id IS NULL THEN
    RAISE EXCEPTION 'Workflow definition MR_STANDARD not found';
  END IF;
  
  -- Get first step
  SELECT id INTO v_step1_id 
  FROM workflow_steps 
  WHERE workflow_id = v_workflow_def_id 
  ORDER BY step_sequence 
  LIMIT 1;
  
  -- Create workflow instance
  INSERT INTO workflow_instances (
    workflow_id,
    object_type,
    object_id,
    requester_id,
    context_data,
    status,
    current_step_sequence,
    tenant_id
  ) VALUES (
    v_workflow_def_id,
    'MATERIAL_REQUEST',
    v_mr_id,
    v_requester_id::uuid,
    '{"request_number": "MR-01-2026-000007", "plant_code": "P001", "department_code": "ENG"}'::jsonb,
    'ACTIVE',
    1,
    v_tenant_id
  ) RETURNING id INTO v_workflow_instance_id;
  
  -- Create step instance for Step 1 (Manager Approval)
  INSERT INTO step_instances (
    workflow_instance_id,
    workflow_step_id,
    step_sequence,
    assigned_agent_id,
    assigned_agent_name,
    assigned_agent_role,
    status
  ) VALUES (
    v_workflow_instance_id,
    v_step1_id,
    1,
    v_manager_id::uuid,
    'Jane Manager',
    'Manager',
    'PENDING'
  );
  
  RAISE NOTICE 'Workflow created successfully for MR: %', v_mr_id;
  RAISE NOTICE 'Workflow instance ID: %', v_workflow_instance_id;
  RAISE NOTICE 'Assigned to: %', v_manager_id;
END $$;
