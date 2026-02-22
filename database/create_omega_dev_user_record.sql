-- Create OMEGA-DEV user record
DO $$
DECLARE
  v_omega_dev_tenant UUID := '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';
  v_auth_user_id UUID;
  v_role_id UUID;
BEGIN
  -- Get auth user ID
  SELECT id INTO v_auth_user_id 
  FROM auth.users 
  WHERE email = 'internaluser@abc.com';
  
  IF v_auth_user_id IS NULL THEN
    RAISE EXCEPTION 'Auth user not found';
  END IF;
  
  -- Get DataGov Admin role for OMEGA-DEV
  SELECT id INTO v_role_id 
  FROM roles 
  WHERE tenant_id = v_omega_dev_tenant 
  AND name = 'DataGov Admin';
  
  IF v_role_id IS NULL THEN
    RAISE EXCEPTION 'DataGov Admin role not found for OMEGA-DEV';
  END IF;
  
  -- Insert user record
  INSERT INTO users (id, email, first_name, last_name, tenant_id, role_id, is_active)
  VALUES (
    gen_random_uuid(),
    'internaluser@abc.com',
    'Internal',
    'User',
    v_omega_dev_tenant,
    v_role_id,
    true
  )
  ON CONFLICT (email, tenant_id) DO UPDATE
  SET role_id = EXCLUDED.role_id;
  
  RAISE NOTICE 'User created for OMEGA-DEV';
END $$;

-- Verify
SELECT 
  u.id,
  u.email,
  u.tenant_id,
  r.name as role_name,
  u.is_active
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.email = 'internaluser@abc.com'
AND u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';
