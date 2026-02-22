-- =====================================================
-- LINK EXISTING USERS TO ORGANIZATIONS FOR RLS TESTING
-- =====================================================

-- Use existing users and link them to external organizations
DO $$
DECLARE
  v_tenant_id UUID;
  v_internal_org_id UUID;
  v_customer_org_id UUID;
  v_vendor_org_id UUID;
  v_contractor_org_id UUID;
  v_user1_id UUID;
  v_user2_id UUID;
  v_user3_id UUID;
  v_user4_id UUID;
BEGIN
  -- Get tenant and organizations
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  SELECT external_org_id INTO v_internal_org_id FROM external_organizations WHERE is_internal = true LIMIT 1;
  SELECT external_org_id INTO v_customer_org_id FROM external_organizations WHERE org_code = 'CUST001';
  SELECT external_org_id INTO v_vendor_org_id FROM external_organizations WHERE org_code = 'VEND001';
  SELECT external_org_id INTO v_contractor_org_id FROM external_organizations WHERE org_code = 'CONT001';

  -- Get 4 existing users
  SELECT id INTO v_user1_id FROM users WHERE tenant_id = v_tenant_id ORDER BY created_at LIMIT 1 OFFSET 0;
  SELECT id INTO v_user2_id FROM users WHERE tenant_id = v_tenant_id ORDER BY created_at LIMIT 1 OFFSET 1;
  SELECT id INTO v_user3_id FROM users WHERE tenant_id = v_tenant_id ORDER BY created_at LIMIT 1 OFFSET 2;
  SELECT id INTO v_user4_id FROM users WHERE tenant_id = v_tenant_id ORDER BY created_at LIMIT 1 OFFSET 3;

  -- If we don't have 4 users, use the same user multiple times for testing
  IF v_user2_id IS NULL THEN v_user2_id := v_user1_id; END IF;
  IF v_user3_id IS NULL THEN v_user3_id := v_user1_id; END IF;
  IF v_user4_id IS NULL THEN v_user4_id := v_user1_id; END IF;

  -- Link users to organizations
  INSERT INTO external_org_users (tenant_id, external_org_id, user_id, role, is_active)
  VALUES 
    (v_tenant_id, v_internal_org_id, v_user1_id, 'ADMIN', true),
    (v_tenant_id, v_customer_org_id, v_user2_id, 'VIEWER', true),
    (v_tenant_id, v_vendor_org_id, v_user3_id, 'CONTRIBUTOR', true),
    (v_tenant_id, v_contractor_org_id, v_user4_id, 'CONTRIBUTOR', true)
  ON CONFLICT (external_org_id, user_id) DO NOTHING;

  RAISE NOTICE 'Users linked to organizations:';
  RAISE NOTICE '  Internal org: User %', v_user1_id;
  RAISE NOTICE '  Customer org: User %', v_user2_id;
  RAISE NOTICE '  Vendor org: User %', v_user3_id;
  RAISE NOTICE '  Contractor org: User %', v_user4_id;
  
  -- Test RLS with first user
  PERFORM set_config('app.current_user_id', v_user2_id::text, false);
  
  RAISE NOTICE '';
  RAISE NOTICE '=== RLS TEST (Customer User) ===';
  RAISE NOTICE 'User ID: %', v_user2_id;
  RAISE NOTICE 'Organizations visible: %', (SELECT COUNT(*) FROM external_organizations);
  RAISE NOTICE 'Expected: 1 (Acme Manufacturing Corp)';
  RAISE NOTICE '';
  RAISE NOTICE 'If you see 1 organization, RLS is working! ✓';
  RAISE NOTICE 'If you see more than 1, RLS needs adjustment.';
END $$;

-- Summary
SELECT 
  'RLS Test Complete' AS status,
  (SELECT COUNT(*) FROM external_org_users) AS org_memberships,
  (SELECT COUNT(*) FROM external_organizations) AS total_orgs;
