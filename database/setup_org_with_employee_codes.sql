-- Add properly created Supabase users to org_hierarchy with employee codes
-- Run this AFTER creating users through Supabase Dashboard

DO $$
DECLARE
  v_tenant_id UUID;
  v_user1_id TEXT;
  v_user2_id TEXT;
  v_user3_id TEXT;
BEGIN
  SELECT id INTO v_tenant_id FROM tenants ORDER BY created_at LIMIT 1;
  
  SELECT id::text INTO v_user1_id FROM auth.users WHERE email = 'john.engineer@example.com';
  SELECT id::text INTO v_user2_id FROM auth.users WHERE email = 'jane.manager@example.com';
  SELECT id::text INTO v_user3_id FROM auth.users WHERE email = 'bob.director@example.com';
  
  IF v_user1_id IS NULL OR v_user2_id IS NULL OR v_user3_id IS NULL THEN
    RAISE EXCEPTION 'One or more test users not found. Create them in Supabase Dashboard first.';
  END IF;
  
  -- Insert org hierarchy with employee codes
  INSERT INTO org_hierarchy (employee_id, employee_code, employee_name, position_title, manager_id, department_code, plant_code, approval_limit, tenant_id)
  VALUES
    (v_user1_id, 'EMP001', 'John Engineer', 'Project Engineer', v_user2_id, 'ENG', 'P001', 5000.00, v_tenant_id),
    (v_user2_id, 'EMP002', 'Jane Manager', 'Engineering Manager', v_user3_id, 'ENG', 'P001', 25000.00, v_tenant_id),
    (v_user3_id, 'EMP003', 'Bob Director', 'Engineering Director', NULL, 'ENG', NULL, 100000.00, v_tenant_id);
  
  -- Insert role assignments
  INSERT INTO role_assignments (role_code, employee_id, scope_type, scope_value, tenant_id)
  VALUES
    ('DEPT_HEAD', v_user2_id, 'DEPARTMENT', 'ENG', v_tenant_id),
    ('PLANT_MGR', v_user2_id, 'PLANT', 'P001', v_tenant_id);
  
  RAISE NOTICE 'Org hierarchy set up successfully';
  RAISE NOTICE 'EMP001 - John Engineer: %', v_user1_id;
  RAISE NOTICE 'EMP002 - Jane Manager: %', v_user2_id;
  RAISE NOTICE 'EMP003 - Bob Director: %', v_user3_id;
END $$;
