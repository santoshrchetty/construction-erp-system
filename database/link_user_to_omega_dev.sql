-- =====================================================
-- LINK INTERNALUSER TO OMEGA-DEV TENANT
-- =====================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_user_id UUID;
BEGIN
  -- Get OMEGA-DEV tenant
  SELECT id INTO v_tenant_id FROM tenants WHERE tenant_code = 'OMEGA-DEV';
  
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Tenant OMEGA-DEV not found';
  END IF;
  
  -- Get user
  SELECT id INTO v_user_id FROM users WHERE email = 'internaluser@abc.com';
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User internaluser@abc.com not found';
  END IF;
  
  -- Link user to OMEGA-DEV tenant
  INSERT INTO user_tenants (user_id, tenant_id, is_active)
  VALUES (v_user_id, v_tenant_id, true)
  ON CONFLICT (user_id, tenant_id) DO UPDATE SET is_active = true;
  
  RAISE NOTICE 'User linked to OMEGA-DEV tenant!';
END $$;

-- Verify all tenant access
SELECT 
  u.email,
  t.tenant_name,
  t.tenant_code,
  ut.is_active
FROM user_tenants ut
JOIN users u ON ut.user_id = u.id
JOIN tenants t ON ut.tenant_id = t.id
WHERE u.email = 'internaluser@abc.com'
ORDER BY t.tenant_code;
