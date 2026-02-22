-- Sample Test Data for Workflow Testing
-- Prerequisites:
--   1. create_flexible_workflow_schema.sql
--   2. add_master_data_tables.sql
--   3. create_roles_master_table.sql (defines valid role codes)
--   4. create_test_users.sql (creates 3 test users) - OPTIONAL if you already have users

-- NOTE: This script requires at least 3 users in auth.users table
-- If you don't have users, run create_test_users.sql first

-- Sample: Insert org hierarchy (replace UUIDs with actual user IDs)
-- Assuming you have users in auth.users table
DO $$
DECLARE
  v_tenant_id UUID;
  v_user1_id UUID; -- Engineer
  v_user2_id UUID; -- Manager
  v_user3_id UUID; -- Dept Head
BEGIN
  -- Get actual tenant_id from tenants table
  SELECT id INTO v_tenant_id FROM tenants ORDER BY created_at LIMIT 1;
  
  -- Get first 3 users from auth.users (adjust as needed)
  SELECT id INTO v_user1_id FROM auth.users ORDER BY created_at LIMIT 1 OFFSET 0;
  SELECT id INTO v_user2_id FROM auth.users ORDER BY created_at LIMIT 1 OFFSET 1;
  SELECT id INTO v_user3_id FROM auth.users ORDER BY created_at LIMIT 1 OFFSET 2;

  -- Insert org hierarchy
  INSERT INTO org_hierarchy (employee_id, employee_name, position_title, manager_id, department_code, plant_code, approval_limit, tenant_id)
  VALUES
    (v_user1_id, 'John Engineer', 'Project Engineer', v_user2_id, 'ENG', 'P001', 5000.00, v_tenant_id),
    (v_user2_id, 'Jane Manager', 'Engineering Manager', v_user3_id, 'ENG', 'P001', 25000.00, v_tenant_id),
    (v_user3_id, 'Bob Director', 'Engineering Director', NULL, 'ENG', NULL, 100000.00, v_tenant_id)
  ON CONFLICT (employee_id) DO NOTHING;

  -- Insert role assignments
  INSERT INTO role_assignments (role_code, employee_id, scope_type, scope_value, tenant_id)
  VALUES
    ('DEPT_HEAD', v_user2_id, 'DEPARTMENT', 'ENG', v_tenant_id),
    ('PLANT_MGR', v_user2_id, 'PLANT', 'P001', v_tenant_id)
  ON CONFLICT DO NOTHING;

  RAISE NOTICE 'Sample data inserted successfully';
  RAISE NOTICE 'User 1 (Engineer): %', v_user1_id;
  RAISE NOTICE 'User 2 (Manager): %', v_user2_id;
  RAISE NOTICE 'User 3 (Dept Head): %', v_user3_id;
END $$;

-- Verify data
SELECT 
  oh.employee_name,
  oh.position_title,
  m.employee_name as manager_name,
  oh.department_code,
  oh.approval_limit
FROM org_hierarchy oh
LEFT JOIN org_hierarchy m ON oh.manager_id = m.employee_id
ORDER BY oh.approval_limit;

SELECT 
  ra.role_code,
  oh.employee_name,
  ra.scope_type,
  ra.scope_value
FROM role_assignments ra
JOIN org_hierarchy oh ON ra.employee_id = oh.employee_id
ORDER BY ra.role_code;
