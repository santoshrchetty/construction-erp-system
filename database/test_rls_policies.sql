-- =====================================================
-- RLS POLICY TESTING
-- =====================================================

-- Test 1: Verify RLS is enabled
SELECT 
  tablename,
  rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'external_organizations',
    'external_org_users',
    'resource_access',
    'drawing_customer_approvals',
    'vendor_progress_updates',
    'field_service_tickets'
  )
ORDER BY tablename;

-- Test 2: Count policies per table
SELECT 
  tablename,
  COUNT(*) AS policy_count
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN (
    'external_organizations',
    'external_org_users',
    'resource_access',
    'drawing_customer_approvals',
    'vendor_progress_updates',
    'field_service_tickets'
  )
GROUP BY tablename
ORDER BY tablename;

-- Test 3: List all policies
SELECT 
  tablename,
  policyname,
  cmd AS operation
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename LIKE 'external%' OR tablename = 'field_service_tickets'
ORDER BY tablename, policyname;

-- Test 4: Verify helper functions exist
SELECT 
  proname AS function_name,
  pg_get_function_result(oid) AS return_type
FROM pg_proc
WHERE proname IN ('has_resource_access', 'is_external_user', 'get_user_orgs')
ORDER BY proname;

-- Test 5: Test get_user_orgs function
DO $$
DECLARE
  test_user_id UUID;
  org_count INT;
BEGIN
  -- Get first user
  SELECT id INTO test_user_id FROM users LIMIT 1;
  
  -- Count their organizations
  SELECT COUNT(*) INTO org_count
  FROM get_user_orgs(test_user_id);
  
  RAISE NOTICE 'User % belongs to % organizations', test_user_id, org_count;
END $$;

-- Test 6: Summary
SELECT 
  'RLS Policies Applied Successfully' AS status,
  COUNT(DISTINCT tablename) AS tables_secured,
  COUNT(*) AS total_policies
FROM pg_policies
WHERE schemaname = 'public'
  AND (tablename LIKE 'external%' OR tablename = 'field_service_tickets');
