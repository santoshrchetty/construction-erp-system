-- =====================================================
-- CREATE SAMPLE USERS IN AUTH.USERS THEN PUBLIC.USERS
-- =====================================================

-- Create users in auth.users first, then public.users
DO $$
DECLARE
  v_tenant_id UUID;
  v_internal_org_id UUID;
  v_customer_org_id UUID;
  v_vendor_org_id UUID;
  v_contractor_org_id UUID;
  v_internal_user_id UUID := gen_random_uuid();
  v_customer_user_id UUID := gen_random_uuid();
  v_vendor_user_id UUID := gen_random_uuid();
  v_contractor_user_id UUID := gen_random_uuid();
BEGIN
  -- Get tenant and organizations
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  SELECT external_org_id INTO v_internal_org_id FROM external_organizations WHERE is_internal = true LIMIT 1;
  SELECT external_org_id INTO v_customer_org_id FROM external_organizations WHERE org_code = 'CUST001';
  SELECT external_org_id INTO v_vendor_org_id FROM external_organizations WHERE org_code = 'VEND001';
  SELECT external_org_id INTO v_contractor_org_id FROM external_organizations WHERE org_code = 'CONT001';

  -- Create in auth.users first
  INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at)
  VALUES 
    (v_internal_user_id, 'internal@abc.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW()),
    (v_customer_user_id, 'customer@acme.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW()),
    (v_vendor_user_id, 'vendor@steel.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW()),
    (v_contractor_user_id, 'contractor@elite.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW());

  -- Create in public.users
  INSERT INTO users (id, tenant_id, email, is_active)
  VALUES 
    (v_internal_user_id, v_tenant_id, 'internal@abc.com', true),
    (v_customer_user_id, v_tenant_id, 'customer@acme.com', true),
    (v_vendor_user_id, v_tenant_id, 'vendor@steel.com', true),
    (v_contractor_user_id, v_tenant_id, 'contractor@elite.com', true);

  -- Link to organizations
  INSERT INTO external_org_users (tenant_id, external_org_id, user_id, role, is_active)
  VALUES 
    (v_tenant_id, v_internal_org_id, v_internal_user_id, 'ADMIN', true),
    (v_tenant_id, v_customer_org_id, v_customer_user_id, 'VIEWER', true),
    (v_tenant_id, v_vendor_org_id, v_vendor_user_id, 'CONTRIBUTOR', true),
    (v_tenant_id, v_contractor_org_id, v_contractor_user_id, 'CONTRIBUTOR', true)
  ON CONFLICT (external_org_id, user_id) DO NOTHING;

  RAISE NOTICE 'Sample users created:';
  RAISE NOTICE '  Internal: % (internal@abc.com / password123)', v_internal_user_id;
  RAISE NOTICE '  Customer: % (customer@acme.com / password123)', v_customer_user_id;
  RAISE NOTICE '  Vendor: % (vendor@steel.com / password123)', v_vendor_user_id;
  RAISE NOTICE '  Contractor: % (contractor@elite.com / password123)', v_contractor_user_id;
  
  -- Test RLS
  PERFORM set_config('app.current_user_id', v_customer_user_id::text, false);
  
  RAISE NOTICE '';
  RAISE NOTICE '=== RLS TEST (Customer User) ===';
  RAISE NOTICE 'Organizations visible: %', (SELECT COUNT(*) FROM external_organizations);
  RAISE NOTICE 'Expected: 1 organization';
  RAISE NOTICE 'RLS Status: %', CASE WHEN (SELECT COUNT(*) FROM external_organizations) = 1 THEN 'WORKING ✓' ELSE 'NEEDS FIX ✗' END;
END $$;

-- Verify
SELECT 
  'Users Created' AS status,
  COUNT(*) AS count
FROM users 
WHERE email IN ('internal@abc.com', 'customer@acme.com', 'vendor@steel.com', 'contractor@elite.com');
