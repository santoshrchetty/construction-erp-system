-- Create user profile for OMEGA-DEV user
DO $$
DECLARE
  v_omega_dev_tenant UUID := '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';
  v_user_id UUID;
BEGIN
  -- Get user ID
  SELECT id INTO v_user_id 
  FROM users 
  WHERE email = 'internaluser@abc.com'
  AND tenant_id = v_omega_dev_tenant;
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not found for OMEGA-DEV';
  END IF;
  
  -- Insert user profile if not exists
  INSERT INTO user_profiles (user_id, tenant_id, phone, address, city, state, zip_code)
  VALUES (
    v_user_id,
    v_omega_dev_tenant,
    '555-0100',
    '123 Main St',
    'Seattle',
    'WA',
    '98101'
  )
  ON CONFLICT (user_id) DO NOTHING;
  
  RAISE NOTICE 'User profile created for user_id: %', v_user_id;
END $$;

-- Verify
SELECT 
  u.email,
  up.phone,
  up.city,
  up.state
FROM user_profiles up
JOIN users u ON up.user_id = u.id
WHERE u.email = 'internaluser@abc.com'
AND u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';
