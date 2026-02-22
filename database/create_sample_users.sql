-- =====================================================
-- CREATE SAMPLE USERS (RLS BYPASSED)
-- =====================================================

-- Temporarily disable RLS for user creation
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE external_org_users DISABLE ROW LEVEL SECURITY;

-- Create sample users
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
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  SELECT external_org_id INTO v_internal_org_id FROM external_organizations WHERE is_internal = true LIMIT 1;
  SELECT external_org_id INTO v_customer_org_id FROM external_organizations WHERE org_code = 'CUST001';
  SELECT external_org_id INTO v_vendor_org_id FROM external_organizations WHERE org_code = 'VEND001';
  SELECT external_org_id INTO v_contractor_org_id FROM external_organizations WHERE org_code = 'CONT001';

  -- Get or create users
  SELECT id INTO v_internal_user_id FROM users WHERE email = 'internal@abc.com';
  IF v_internal_user_id IS NULL THEN
    INSERT INTO users (id, tenant_id, email, is_active)
    VALUES (gen_random_uuid(), v_tenant_id, 'internal@abc.com', true)
    RETURNING id INTO v_internal_user_id;
  END IF;

  SELECT id INTO v_customer_user_id FROM users WHERE email = 'customer@acme.com';
  IF v_customer_user_id IS NULL THEN
    INSERT INTO users (id, tenant_id, email, is_active)
    VALUES (gen_random_uuid(), v_tenant_id, 'customer@acme.com', true)
    RETURNING id INTO v_customer_user_id;
  END IF;

  SELECT id INTO v_vendor_user_id FROM users WHERE email = 'vendor@steel.com';
  IF v_vendor_user_id IS NULL THEN
    INSERT INTO users (id, tenant_id, email, is_active)
    VALUES (gen_random_uuid(), v_tenant_id, 'vendor@steel.com', true)
    RETURNING id INTO v_vendor_user_id;
  END IF;

  SELECT id INTO v_contractor_user_id FROM users WHERE email = 'contractor@elite.com';
  IF v_contractor_user_id IS NULL THEN
    INSERT INTO users (id, tenant_id, email, is_active)
    VALUES (gen_random_uuid(), v_tenant_id, 'contractor@elite.com', true)
    RETURNING id INTO v_contractor_user_id;
  END IF;

  -- Link users to organizations
  INSERT INTO external_org_users (tenant_id, external_org_id, user_id, role, is_active)
  VALUES 
    (v_tenant_id, v_internal_org_id, v_internal_user_id, 'ADMIN', true),
    (v_tenant_id, v_customer_org_id, v_customer_user_id, 'VIEWER', true),
    (v_tenant_id, v_vendor_org_id, v_vendor_user_id, 'CONTRIBUTOR', true),
    (v_tenant_id, v_contractor_org_id, v_contractor_user_id, 'CONTRIBUTOR', true)
  ON CONFLICT (external_org_id, user_id) DO NOTHING;

  RAISE NOTICE 'Sample users created:';
  RAISE NOTICE '  Internal: %', v_internal_user_id;
  RAISE NOTICE '  Customer: %', v_customer_user_id;
  RAISE NOTICE '  Vendor: %', v_vendor_user_id;
  RAISE NOTICE '  Contractor: %', v_contractor_user_id;
END $$;

-- Re-enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE external_org_users ENABLE ROW LEVEL SECURITY;

-- Verify
SELECT 
  'Users Created' AS status,
  COUNT(*) AS user_count
FROM users 
WHERE email IN ('internal@abc.com', 'customer@acme.com', 'vendor@steel.com', 'contractor@elite.com');

SELECT 
  'Org Memberships' AS status,
  COUNT(*) AS membership_count
FROM external_org_users;
