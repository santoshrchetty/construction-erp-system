-- =====================================================
-- MANUAL RLS TEST
-- =====================================================

-- Test 1: Customer User
DO $$
DECLARE
  v_user_id UUID;
  v_org_count INT;
BEGIN
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'customeruser@acme.com';
  PERFORM set_config('app.current_user_id', v_user_id::text, false);
  SELECT COUNT(*) INTO v_org_count FROM external_organizations;
  
  RAISE NOTICE '=== Customer User Test ===';
  RAISE NOTICE 'User ID: %', v_user_id;
  RAISE NOTICE 'Organizations visible: %', v_org_count;
  RAISE NOTICE 'Status: %', CASE WHEN v_org_count = 1 THEN 'RLS WORKING ✓' ELSE 'RLS NOT WORKING ✗' END;
END $$;

-- Test 2: Vendor User
DO $$
DECLARE
  v_user_id UUID;
  v_org_count INT;
BEGIN
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'vendoruser@steel.com';
  PERFORM set_config('app.current_user_id', v_user_id::text, false);
  SELECT COUNT(*) INTO v_org_count FROM external_organizations;
  
  RAISE NOTICE '=== Vendor User Test ===';
  RAISE NOTICE 'User ID: %', v_user_id;
  RAISE NOTICE 'Organizations visible: %', v_org_count;
  RAISE NOTICE 'Status: %', CASE WHEN v_org_count = 1 THEN 'RLS WORKING ✓' ELSE 'RLS NOT WORKING ✗' END;
END $$;

-- Test 3: Contractor User
DO $$
DECLARE
  v_user_id UUID;
  v_org_count INT;
BEGIN
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'contractoruser@elite.com';
  PERFORM set_config('app.current_user_id', v_user_id::text, false);
  SELECT COUNT(*) INTO v_org_count FROM external_organizations;
  
  RAISE NOTICE '=== Contractor User Test ===';
  RAISE NOTICE 'User ID: %', v_user_id;
  RAISE NOTICE 'Organizations visible: %', v_org_count;
  RAISE NOTICE 'Status: %', CASE WHEN v_org_count = 1 THEN 'RLS WORKING ✓' ELSE 'RLS NOT WORKING ✗' END;
END $$;

-- Summary
SELECT 
  'RLS Testing Complete' AS message,
  'Check NOTICE output above for results' AS instruction;
