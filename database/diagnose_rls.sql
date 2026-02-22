-- =====================================================
-- DIAGNOSE RLS ISSUE
-- =====================================================

-- Check if customer user is linked to organization
SELECT 
  'Customer User Org Membership' AS check_type,
  ou.org_user_id,
  ou.user_id,
  ou.external_org_id,
  o.org_name,
  ou.is_active
FROM external_org_users ou
JOIN external_organizations o ON ou.external_org_id = o.external_org_id
WHERE ou.user_id = '377afc58-2385-4157-8bbc-9ce4eb1d7b5d';

-- Test get_user_orgs function
SELECT 
  'get_user_orgs Function Test' AS check_type,
  external_org_id
FROM get_user_orgs('377afc58-2385-4157-8bbc-9ce4eb1d7b5d');

-- Check if RLS is enabled
SELECT 
  'RLS Status' AS check_type,
  tablename,
  rowsecurity AS rls_enabled
FROM pg_tables
WHERE tablename = 'external_organizations';

-- Check policies on external_organizations
SELECT 
  'RLS Policies' AS check_type,
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'external_organizations';

-- Test the policy condition manually
SELECT 
  'Manual Policy Test' AS check_type,
  external_org_id IN (SELECT get_user_orgs('377afc58-2385-4157-8bbc-9ce4eb1d7b5d')) AS should_see
FROM external_organizations;
