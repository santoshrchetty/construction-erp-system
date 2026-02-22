-- Add your existing user to org_hierarchy for testing
-- Replace with your actual user email

DO $$
DECLARE
  v_tenant_id UUID;
  v_user_id UUID;
  v_manager_id UUID;
BEGIN
  -- Get tenant
  SELECT id INTO v_tenant_id FROM tenants ORDER BY created_at LIMIT 1;
  
  -- Get your actual user (replace email)
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'YOUR_EMAIL@example.com' LIMIT 1;
  
  -- Get a manager (use second user as manager)
  SELECT id INTO v_manager_id FROM auth.users WHERE email != 'YOUR_EMAIL@example.com' ORDER BY created_at LIMIT 1;
  
  -- Insert into org_hierarchy
  INSERT INTO org_hierarchy (employee_id, employee_name, position_title, manager_id, department_code, plant_code, approval_limit, tenant_id)
  VALUES
    (v_user_id, 'Test Engineer', 'Project Engineer', v_manager_id, 'ENG', 'P001', 5000.00, v_tenant_id)
  ON CONFLICT (employee_id) DO UPDATE SET
    employee_name = EXCLUDED.employee_name,
    position_title = EXCLUDED.position_title,
    manager_id = EXCLUDED.manager_id,
    department_code = EXCLUDED.department_code,
    plant_code = EXCLUDED.plant_code;
    
  -- Add manager to org_hierarchy if not exists
  INSERT INTO org_hierarchy (employee_id, employee_name, position_title, manager_id, department_code, plant_code, approval_limit, tenant_id)
  VALUES
    (v_manager_id, 'Test Manager', 'Engineering Manager', NULL, 'ENG', 'P001', 25000.00, v_tenant_id)
  ON CONFLICT (employee_id) DO NOTHING;
  
  -- Add manager roles
  INSERT INTO role_assignments (role_code, employee_id, scope_type, scope_value, tenant_id)
  VALUES
    ('DEPT_HEAD', v_manager_id, 'DEPARTMENT', 'ENG', v_tenant_id),
    ('PLANT_MGR', v_manager_id, 'PLANT', 'P001', v_tenant_id)
  ON CONFLICT DO NOTHING;
  
  RAISE NOTICE 'User added to org hierarchy: %', v_user_id;
  RAISE NOTICE 'Manager: %', v_manager_id;
END $$;
