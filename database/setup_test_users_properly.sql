-- INSTRUCTIONS: Create Test Users via Supabase Dashboard
-- =========================================================

-- Since direct SQL insert into auth.users doesn't work with Supabase Auth,
-- you need to create users through the Supabase Dashboard:

-- 1. Go to Supabase Dashboard → Authentication → Users
-- 2. Click "Add User" button
-- 3. Create these 3 users:
--    - Email: john.engineer@example.com, Password: password123
--    - Email: jane.manager@example.com, Password: password123  
--    - Email: bob.director@example.com, Password: password123

-- 4. After creating users, run this script to add them to org_hierarchy:

DO $$
DECLARE
  v_tenant_id UUID;
  v_user1_id UUID;
  v_user2_id UUID;
  v_user3_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM tenants ORDER BY created_at LIMIT 1;
  
  SELECT id INTO v_user1_id FROM auth.users WHERE email = 'john.engineer@example.com';
  SELECT id INTO v_user2_id FROM auth.users WHERE email = 'jane.manager@example.com';
  SELECT id INTO v_user3_id FROM auth.users WHERE email = 'bob.director@example.com';
  
  DELETE FROM org_hierarchy WHERE employee_id IN (v_user1_id, v_user2_id, v_user3_id);
  DELETE FROM role_assignments WHERE employee_id IN (v_user1_id, v_user2_id, v_user3_id);
  
  INSERT INTO org_hierarchy (employee_id, employee_name, position_title, manager_id, department_code, plant_code, approval_limit, tenant_id)
  VALUES
    (v_user1_id, 'John Engineer', 'Project Engineer', v_user2_id, 'ENG', 'P001', 5000.00, v_tenant_id),
    (v_user2_id, 'Jane Manager', 'Engineering Manager', v_user3_id, 'ENG', 'P001', 25000.00, v_tenant_id),
    (v_user3_id, 'Bob Director', 'Engineering Director', NULL, 'ENG', NULL, 100000.00, v_tenant_id);
  
  INSERT INTO role_assignments (role_code, employee_id, scope_type, scope_value, tenant_id)
  VALUES
    ('DEPT_HEAD', v_user2_id, 'DEPARTMENT', 'ENG', v_tenant_id),
    ('PLANT_MGR', v_user2_id, 'PLANT', 'P001', v_tenant_id);
  
  RAISE NOTICE 'Org hierarchy set up successfully';
END $$;

-- ALTERNATIVE: Use your existing logged-in user
-- ==============================================
-- Replace 'YOUR_EMAIL@example.com' with your actual email below:

/*
DO $$
DECLARE
  v_tenant_id UUID;
  v_user_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM tenants ORDER BY created_at LIMIT 1;
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'YOUR_EMAIL@example.com';
  
  INSERT INTO org_hierarchy (employee_id, employee_name, position_title, manager_id, department_code, plant_code, approval_limit, tenant_id)
  VALUES (v_user_id, 'Test User', 'Project Engineer', NULL, 'ENG', 'P001', 5000.00, v_tenant_id)
  ON CONFLICT (employee_id) DO UPDATE SET
    employee_name = EXCLUDED.employee_name,
    department_code = EXCLUDED.department_code,
    plant_code = EXCLUDED.plant_code;
  
  RAISE NOTICE 'Your user added to org hierarchy: %', v_user_id;
END $$;
*/
