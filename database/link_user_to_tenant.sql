-- =====================================================
-- LINK INTERNALUSER TO TENANT VIA USER_TENANTS TABLE
-- =====================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_user_id UUID;
BEGIN
  -- Get tenant and user
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  SELECT id INTO v_user_id FROM users WHERE email = 'internaluser@abc.com';
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User internaluser@abc.com not found';
  END IF;
  
  -- Create user_tenants link
  INSERT INTO user_tenants (user_id, tenant_id, is_active)
  VALUES (v_user_id, v_tenant_id, true)
  ON CONFLICT (user_id, tenant_id) DO UPDATE SET is_active = true;
  
  RAISE NOTICE 'User linked to tenant successfully!';
  RAISE NOTICE 'User: internaluser@abc.com';
  RAISE NOTICE 'Tenant: %', v_tenant_id;
END $$;

-- Verify
SELECT 
  u.email,
  t.tenant_name,
  t.tenant_code,
  ut.is_active
FROM user_tenants ut
JOIN users u ON ut.user_id = u.id
JOIN tenants t ON ut.tenant_id = t.id
WHERE u.email = 'internaluser@abc.com';
