-- =====================================================
-- LINK EXISTING AUTH USERS TO ORGANIZATIONS
-- =====================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_internal_org_id UUID;
  v_customer_org_id UUID;
  v_vendor_org_id UUID;
  v_contractor_org_id UUID;
  v_internal_user_id UUID;
  v_customer_user_id UUID;
  v_vendor_user_id UUID;
  v_contractor_user_id UUID;
BEGIN
  -- Get tenant and organizations
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  SELECT external_org_id INTO v_internal_org_id FROM external_organizations WHERE is_internal = true LIMIT 1;
  SELECT external_org_id INTO v_customer_org_id FROM external_organizations WHERE org_code = 'CUST001';
  SELECT external_org_id INTO v_vendor_org_id FROM external_organizations WHERE org_code = 'VEND001';
  SELECT external_org_id INTO v_contractor_org_id FROM external_organizations WHERE org_code = 'CONT001';

  -- Get user IDs from auth.users
  SELECT id INTO v_internal_user_id FROM auth.users WHERE email = 'internaluser@abc.com';
  SELECT id INTO v_customer_user_id FROM auth.users WHERE email = 'customeruser@acme.com';
  SELECT id INTO v_vendor_user_id FROM auth.users WHERE email = 'vendoruser@steel.com';
  SELECT id INTO v_contractor_user_id FROM auth.users WHERE email = 'contractoruser@elite.com';

  -- Create in public.users if not exists
  IF NOT EXISTS (SELECT 1 FROM users WHERE id = v_internal_user_id) THEN
    INSERT INTO users (id, tenant_id, email, is_active)
    VALUES (v_internal_user_id, v_tenant_id, 'internaluser@abc.com', true);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM users WHERE id = v_customer_user_id) THEN
    INSERT INTO users (id, tenant_id, email, is_active)
    VALUES (v_customer_user_id, v_tenant_id, 'customeruser@acme.com', true);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM users WHERE id = v_vendor_user_id) THEN
    INSERT INTO users (id, tenant_id, email, is_active)
    VALUES (v_vendor_user_id, v_tenant_id, 'vendoruser@steel.com', true);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM users WHERE id = v_contractor_user_id) THEN
    INSERT INTO users (id, tenant_id, email, is_active)
    VALUES (v_contractor_user_id, v_tenant_id, 'contractoruser@elite.com', true);
  END IF;

  -- Link to organizations
  INSERT INTO external_org_users (tenant_id, external_org_id, user_id, role, is_active)
  VALUES 
    (v_tenant_id, v_internal_org_id, v_internal_user_id, 'ADMIN', true),
    (v_tenant_id, v_customer_org_id, v_customer_user_id, 'VIEWER', true),
    (v_tenant_id, v_vendor_org_id, v_vendor_user_id, 'CONTRIBUTOR', true),
    (v_tenant_id, v_contractor_org_id, v_contractor_user_id, 'CONTRIBUTOR', true)
  ON CONFLICT (external_org_id, user_id) DO NOTHING;

  RAISE NOTICE 'Users linked to organizations:';
  RAISE NOTICE '  Internal: %', v_internal_user_id;
  RAISE NOTICE '  Customer: %', v_customer_user_id;
  RAISE NOTICE '  Vendor: %', v_vendor_user_id;
  RAISE NOTICE '  Contractor: %', v_contractor_user_id;
  
  -- Test RLS with customer user
  PERFORM set_config('app.current_user_id', v_customer_user_id::text, false);
  
  RAISE NOTICE '';
  RAISE NOTICE '=== RLS TEST (Customer User) ===';
  RAISE NOTICE 'User: customeruser@acme.com';
  RAISE NOTICE 'Organizations visible: %', (SELECT COUNT(*) FROM external_organizations);
  RAISE NOTICE 'Expected: 1 (Acme Manufacturing Corp)';
  RAISE NOTICE 'RLS Status: %', CASE WHEN (SELECT COUNT(*) FROM external_organizations) = 1 THEN 'WORKING ✓' ELSE 'NEEDS FIX ✗' END;
  
  -- Test with vendor user
  PERFORM set_config('app.current_user_id', v_vendor_user_id::text, false);
  
  RAISE NOTICE '';
  RAISE NOTICE '=== RLS TEST (Vendor User) ===';
  RAISE NOTICE 'User: vendoruser@steel.com';
  RAISE NOTICE 'Organizations visible: %', (SELECT COUNT(*) FROM external_organizations);
  RAISE NOTICE 'Expected: 1 (Steel Supply Inc)';
  RAISE NOTICE 'RLS Status: %', CASE WHEN (SELECT COUNT(*) FROM external_organizations) = 1 THEN 'WORKING ✓' ELSE 'NEEDS FIX ✗' END;
END $$;

-- Verify
SELECT 
  'Setup Complete' AS status,
  (SELECT COUNT(*) FROM users WHERE email LIKE '%user@%') AS users_created,
  (SELECT COUNT(*) FROM external_org_users) AS org_memberships;
