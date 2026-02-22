-- Add test users to users table (separate from auth.users)
-- This is needed for the app to work properly

DO $$
DECLARE
  v_tenant_id UUID;
  v_user1_id UUID;
  v_user2_id UUID;
  v_user3_id UUID;
  v_role_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM tenants ORDER BY created_at LIMIT 1;
  
  SELECT id INTO v_user1_id FROM auth.users WHERE email = 'john.engineer@example.com';
  SELECT id INTO v_user2_id FROM auth.users WHERE email = 'jane.manager@example.com';
  SELECT id INTO v_user3_id FROM auth.users WHERE email = 'bob.director@example.com';
  
  -- Get a default role (use first available role)
  SELECT id INTO v_role_id FROM roles WHERE tenant_id = v_tenant_id LIMIT 1;
  
  -- Insert into users table
  INSERT INTO users (id, email, first_name, last_name, employee_code, department, role_id, tenant_id, is_active, created_at, updated_at)
  VALUES
    (v_user1_id, 'john.engineer@example.com', 'John', 'Engineer', 'EMP001', 'ENG', v_role_id, v_tenant_id, true, NOW(), NOW()),
    (v_user2_id, 'jane.manager@example.com', 'Jane', 'Manager', 'EMP002', 'ENG', v_role_id, v_tenant_id, true, NOW(), NOW()),
    (v_user3_id, 'bob.director@example.com', 'Bob', 'Director', 'EMP003', 'ENG', v_role_id, v_tenant_id, true, NOW(), NOW())
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    employee_code = EXCLUDED.employee_code,
    department = EXCLUDED.department,
    tenant_id = EXCLUDED.tenant_id;
  
  RAISE NOTICE 'Users added to users table successfully';
END $$;

-- Verify
SELECT id, email, first_name, last_name, employee_code, department, tenant_id
FROM users
WHERE email IN ('john.engineer@example.com', 'jane.manager@example.com', 'bob.director@example.com');
