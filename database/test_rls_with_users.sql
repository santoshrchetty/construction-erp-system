-- =====================================================
-- CREATE SAMPLE USERS AND TEST RLS
-- =====================================================

-- Create sample users for testing
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

  -- Create internal user
  INSERT INTO users (id, tenant_id, email, is_active)
  VALUES (gen_random_uuid(), v_tenant_id, 'internal@abc.com', true)
  ON CONFLICT (email) DO UPDATE SET is_active = true
  RETURNING id INTO v_internal_user_id;

  -- Create customer user
  INSERT INTO users (id, tenant_id, email, is_active)
  VALUES (gen_random_uuid(), v_tenant_id, 'customer@acme.com', true)
  ON CONFLICT (email) DO UPDATE SET is_active = true
  RETURNING id INTO v_customer_user_id;

  -- Create vendor user
  INSERT INTO users (id, tenant_id, email, is_active)
  VALUES (gen_random_uuid(), v_tenant_id, 'vendor@steel.com', true)
  ON CONFLICT (email) DO UPDATE SET is_active = true
  RETURNING id INTO v_vendor_user_id;

  -- Create contractor user
  INSERT INTO users (id, tenant_id, email, is_active)
  VALUES (gen_random_uuid(), v_tenant_id, 'contractor@elite.com', true)
  ON CONFLICT (email) DO UPDATE SET is_active = true
  RETURNING id INTO v_contractor_user_id;

  -- Link users to organizations
  INSERT INTO external_org_users (tenant_id, external_org_id, user_id, role, is_active)
  VALUES 
    (v_tenant_id, v_internal_org_id, v_internal_user_id, 'ADMIN', true),
    (v_tenant_id, v_customer_org_id, v_customer_user_id, 'VIEWER', true),
    (v_tenant_id, v_vendor_org_id, v_vendor_user_id, 'CONTRIBUTOR', true),
    (v_tenant_id, v_contractor_org_id, v_contractor_user_id, 'CONTRIBUTOR', true)
  ON CONFLICT (external_org_id, user_id) DO NOTHING;

  RAISE NOTICE 'Sample users created:';
  RAISE NOTICE '  Internal: % (%)', v_internal_user_id, 'internal@abc.com';
  RAISE NOTICE '  Customer: % (%)', v_customer_user_id, 'customer@acme.com';
  RAISE NOTICE '  Vendor: % (%)', v_vendor_user_id, 'vendor@steel.com';
  RAISE NOTICE '  Contractor: % (%)', v_contractor_user_id, 'contractor@elite.com';
END $$;

-- =====================================================
-- TEST 1: Customer User - Should see only their org
-- =====================================================
DO $$
DECLARE
  v_customer_user_id UUID;
  v_org_count INT;
  v_access_count INT;
BEGIN
  SELECT id INTO v_customer_user_id FROM users WHERE email = 'customer@acme.com';
  
  -- Set user context
  PERFORM set_config('app.current_user_id', v_customer_user_id::text, false);
  
  -- Test organization access
  SELECT COUNT(*) INTO v_org_count FROM external_organizations;
  
  -- Test resource access
  SELECT COUNT(*) INTO v_access_count FROM resource_access;
  
  RAISE NOTICE '';
  RAISE NOTICE '=== TEST 1: Customer User ===';
  RAISE NOTICE 'User: customer@acme.com';
  RAISE NOTICE 'Organizations visible: %', v_org_count;
  RAISE NOTICE 'Resource access grants visible: %', v_access_count;
  RAISE NOTICE 'Expected: 1 organization (Acme Manufacturing Corp)';
END $$;

-- =====================================================
-- TEST 2: Vendor User - Should see only their org
-- =====================================================
DO $$
DECLARE
  v_vendor_user_id UUID;
  v_org_count INT;
  v_access_count INT;
BEGIN
  SELECT id INTO v_vendor_user_id FROM users WHERE email = 'vendor@steel.com';
  
  PERFORM set_config('app.current_user_id', v_vendor_user_id::text, false);
  
  SELECT COUNT(*) INTO v_org_count FROM external_organizations;
  SELECT COUNT(*) INTO v_access_count FROM resource_access;
  
  RAISE NOTICE '';
  RAISE NOTICE '=== TEST 2: Vendor User ===';
  RAISE NOTICE 'User: vendor@steel.com';
  RAISE NOTICE 'Organizations visible: %', v_org_count;
  RAISE NOTICE 'Resource access grants visible: %', v_access_count;
  RAISE NOTICE 'Expected: 1 organization (Steel Supply Inc)';
END $$;

-- =====================================================
-- TEST 3: Contractor User - Should see only their org
-- =====================================================
DO $$
DECLARE
  v_contractor_user_id UUID;
  v_org_count INT;
  v_access_count INT;
BEGIN
  SELECT id INTO v_contractor_user_id FROM users WHERE email = 'contractor@elite.com';
  
  PERFORM set_config('app.current_user_id', v_contractor_user_id::text, false);
  
  SELECT COUNT(*) INTO v_org_count FROM external_organizations;
  SELECT COUNT(*) INTO v_access_count FROM resource_access;
  
  RAISE NOTICE '';
  RAISE NOTICE '=== TEST 3: Contractor User ===';
  RAISE NOTICE 'User: contractor@elite.com';
  RAISE NOTICE 'Organizations visible: %', v_org_count;
  RAISE NOTICE 'Resource access grants visible: %', v_access_count;
  RAISE NOTICE 'Expected: 1 organization (Elite Electrical Services)';
END $$;

-- =====================================================
-- TEST 4: Internal User - Should see their org
-- =====================================================
DO $$
DECLARE
  v_internal_user_id UUID;
  v_org_count INT;
  v_access_count INT;
BEGIN
  SELECT id INTO v_internal_user_id FROM users WHERE email = 'internal@abc.com';
  
  PERFORM set_config('app.current_user_id', v_internal_user_id::text, false);
  
  SELECT COUNT(*) INTO v_org_count FROM external_organizations;
  SELECT COUNT(*) INTO v_access_count FROM resource_access;
  
  RAISE NOTICE '';
  RAISE NOTICE '=== TEST 4: Internal User ===';
  RAISE NOTICE 'User: internal@abc.com';
  RAISE NOTICE 'Organizations visible: %', v_org_count;
  RAISE NOTICE 'Resource access grants visible: %', v_access_count;
  RAISE NOTICE 'Expected: 1 organization (ABC Construction Company)';
END $$;

-- =====================================================
-- TEST 5: Cross-Organization Access Test
-- =====================================================
DO $$
DECLARE
  v_customer_user_id UUID;
  v_vendor_org_name TEXT;
BEGIN
  SELECT id INTO v_customer_user_id FROM users WHERE email = 'customer@acme.com';
  
  PERFORM set_config('app.current_user_id', v_customer_user_id::text, false);
  
  -- Try to access vendor organization
  SELECT org_name INTO v_vendor_org_name 
  FROM external_organizations 
  WHERE org_code = 'VEND001';
  
  RAISE NOTICE '';
  RAISE NOTICE '=== TEST 5: Cross-Organization Access ===';
  RAISE NOTICE 'Customer trying to access vendor org: %', 
    CASE WHEN v_vendor_org_name IS NULL THEN 'BLOCKED ✓' ELSE 'ALLOWED ✗' END;
  RAISE NOTICE 'Expected: BLOCKED (RLS working correctly)';
END $$;

-- =====================================================
-- TEST 6: Helper Function Tests
-- =====================================================
DO $$
DECLARE
  v_customer_user_id UUID;
  v_user_orgs TEXT;
  v_is_external BOOLEAN;
BEGIN
  SELECT id INTO v_customer_user_id FROM users WHERE email = 'customer@acme.com';
  
  -- Test get_user_orgs
  SELECT string_agg(o.org_name, ', ') INTO v_user_orgs
  FROM get_user_orgs(v_customer_user_id) uo
  JOIN external_organizations o ON o.external_org_id = uo.external_org_id;
  
  -- Test is_external_user
  SELECT is_external_user(v_customer_user_id) INTO v_is_external;
  
  RAISE NOTICE '';
  RAISE NOTICE '=== TEST 6: Helper Functions ===';
  RAISE NOTICE 'User organizations: %', v_user_orgs;
  RAISE NOTICE 'Is external user: %', v_is_external;
  RAISE NOTICE 'Expected: Acme Manufacturing Corp, true';
END $$;

-- =====================================================
-- SUMMARY
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '=== ALL TESTS COMPLETE ===';
  RAISE NOTICE 'Review the output above to verify RLS is working correctly.';
  RAISE NOTICE 'Each user should only see their own organization data.';
END $$;

SELECT 
  '=== RLS TEST SUMMARY ===' AS summary,
  (SELECT COUNT(*) FROM users WHERE email LIKE '%@%') AS total_test_users,
  (SELECT COUNT(*) FROM external_org_users) AS total_org_memberships,
  (SELECT COUNT(*) FROM external_organizations) AS total_organizations;
