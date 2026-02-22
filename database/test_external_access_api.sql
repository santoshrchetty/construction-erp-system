-- =====================================================
-- EXTERNAL ACCESS API TEST SCRIPT
-- =====================================================
-- Purpose: Test all external access functionality
-- Run this after migration and sample data are loaded
-- =====================================================

-- Set session context (simulate logged-in user)
-- Replace with actual user_id from your database
DO $$
DECLARE
  test_user_id UUID;
  test_tenant_id UUID;
BEGIN
  -- Get first active user
  SELECT id INTO test_user_id FROM users WHERE is_active = true LIMIT 1;
  SELECT id INTO test_tenant_id FROM tenants LIMIT 1;
  
  RAISE NOTICE 'Test User ID: %', test_user_id;
  RAISE NOTICE 'Test Tenant ID: %', test_tenant_id;
  
  -- Set session variables
  PERFORM set_config('app.current_user_id', test_user_id::text, false);
  PERFORM set_config('app.current_tenant_id', test_tenant_id::text, false);
END $$;

-- =====================================================
-- TEST 1: ORGANIZATIONS
-- =====================================================

SELECT '=== TEST 1: List Organizations ===' AS test;
SELECT 
  external_org_id,
  name,
  org_type,
  is_internal,
  is_active
FROM external_organizations
ORDER BY name;

-- =====================================================
-- TEST 2: ORGANIZATION USERS
-- =====================================================

SELECT '=== TEST 2: List Organization Users ===' AS test;
SELECT 
  ou.org_user_id,
  o.name AS organization,
  u.email,
  ou.role,
  ou.is_active
FROM external_org_users ou
JOIN external_organizations o ON ou.external_org_id = o.external_org_id
JOIN users u ON ou.user_id = u.id
ORDER BY o.name, u.email;

-- =====================================================
-- TEST 3: RESOURCE ACCESS
-- =====================================================

SELECT '=== TEST 3: List Resource Access ===' AS test;
SELECT 
  ra.access_id,
  o.name AS organization,
  ra.resource_type,
  ra.access_level,
  ra.is_active,
  ra.access_end_date
FROM resource_access ra
JOIN external_organizations o ON ra.external_org_id = o.external_org_id
ORDER BY o.name, ra.resource_type;

-- =====================================================
-- TEST 4: DRAWINGS (RLS TEST)
-- =====================================================

SELECT '=== TEST 4: Drawings - All Status ===' AS test;
SELECT 
  id,
  drawing_number,
  title,
  status,
  is_released,
  drawing_category
FROM drawings
ORDER BY drawing_number;

-- Test: Only RELEASED drawings should be visible to external users
SELECT '=== TEST 4b: Released Drawings Only ===' AS test;
SELECT 
  id,
  drawing_number,
  title,
  is_released
FROM drawings
WHERE is_released = true
ORDER BY drawing_number;

-- =====================================================
-- TEST 5: FACILITIES
-- =====================================================

SELECT '=== TEST 5: List Facilities ===' AS test;
SELECT 
  facility_id,
  facility_code,
  name,
  facility_type,
  is_active
FROM facilities
ORDER BY facility_code;

-- =====================================================
-- TEST 6: EQUIPMENT
-- =====================================================

SELECT '=== TEST 6: List Equipment ===' AS test;
SELECT 
  e.equipment_id,
  e.tag_number,
  e.description,
  f.name AS facility_name,
  e.is_active
FROM equipment_register e
LEFT JOIN facilities f ON e.facility_id = f.facility_id
ORDER BY e.tag_number;

-- =====================================================
-- TEST 7: HELPER FUNCTIONS
-- =====================================================

SELECT '=== TEST 7: Helper Functions ===' AS test;

-- Test has_resource_access function
DO $$
DECLARE
  test_user_id UUID;
  test_drawing_id UUID;
  has_access BOOLEAN;
BEGIN
  SELECT id INTO test_user_id FROM users LIMIT 1;
  SELECT id INTO test_drawing_id FROM drawings LIMIT 1;
  
  SELECT has_resource_access(test_user_id, 'DRAWING', test_drawing_id) INTO has_access;
  RAISE NOTICE 'User % has access to drawing %: %', test_user_id, test_drawing_id, has_access;
END $$;

-- Test is_external_user function
DO $$
DECLARE
  test_user_id UUID;
  is_ext BOOLEAN;
BEGIN
  SELECT id INTO test_user_id FROM users LIMIT 1;
  
  SELECT is_external_user(test_user_id) INTO is_ext;
  RAISE NOTICE 'User % is external: %', test_user_id, is_ext;
END $$;

-- =====================================================
-- TEST 8: CUSTOMER APPROVALS
-- =====================================================

SELECT '=== TEST 8: Customer Approvals ===' AS test;
SELECT 
  ca.approval_id,
  d.drawing_number,
  o.name AS customer,
  ca.approval_status,
  ca.approved_at,
  ca.comments
FROM drawing_customer_approvals ca
JOIN drawings d ON ca.drawing_id = d.id
JOIN external_organizations o ON ca.external_org_id = o.external_org_id
ORDER BY ca.created_at DESC;

-- =====================================================
-- TEST 9: VENDOR PROGRESS
-- =====================================================

SELECT '=== TEST 9: Vendor Progress Updates ===' AS test;
SELECT 
  vp.update_id,
  d.drawing_number,
  o.name AS vendor,
  vp.progress_percentage,
  vp.status,
  vp.submitted_at
FROM vendor_progress_updates vp
JOIN drawings d ON vp.drawing_id = d.id
JOIN external_organizations o ON vp.external_org_id = o.external_org_id
ORDER BY vp.submitted_at DESC;

-- =====================================================
-- TEST 10: FIELD SERVICE TICKETS
-- =====================================================

SELECT '=== TEST 10: Field Service Tickets ===' AS test;
SELECT 
  t.ticket_id,
  t.title,
  f.name AS facility,
  e.tag_number AS equipment,
  o.name AS assigned_to,
  t.priority,
  t.status
FROM field_service_tickets t
LEFT JOIN facilities f ON t.facility_id = f.facility_id
LEFT JOIN equipment_register e ON t.equipment_id = e.equipment_id
LEFT JOIN external_organizations o ON t.assigned_external_org_id = o.external_org_id
ORDER BY t.created_at DESC;

-- =====================================================
-- TEST 11: RLS POLICIES VERIFICATION
-- =====================================================

SELECT '=== TEST 11: RLS Policies ===' AS test;
SELECT 
  tablename,
  policyname,
  permissive,
  cmd
FROM pg_policies
WHERE tablename IN (
  'drawings', 'resource_access', 'external_organizations', 'facilities', 
  'equipment_register', 'drawing_customer_approvals', 
  'vendor_progress_updates', 'field_service_tickets'
)
ORDER BY tablename, policyname;

-- =====================================================
-- TEST 12: AUDIT LOG
-- =====================================================

SELECT '=== TEST 12: Audit Log ===' AS test;
SELECT 
  log_id,
  action_type,
  table_name,
  user_id,
  performed_at
FROM external_access_audit_log
ORDER BY performed_at DESC
LIMIT 10;

-- =====================================================
-- TEST 13: DATA INTEGRITY CHECKS
-- =====================================================

SELECT '=== TEST 13: Data Integrity ===' AS test;

-- Check for orphaned resource access
SELECT 'Orphaned Resource Access' AS check_name, COUNT(*) AS count
FROM resource_access ra
WHERE NOT EXISTS (
  SELECT 1 FROM external_organizations o 
  WHERE o.external_org_id = ra.external_org_id
);

-- Check for inactive users with active access
SELECT 'Inactive Users with Active Access' AS check_name, COUNT(*) AS count
FROM resource_access ra
JOIN external_org_users ou ON ra.external_org_id = ou.external_org_id
WHERE ra.is_active = true AND ou.is_active = false;

-- Check for expired access still marked active
SELECT 'Expired Access Still Active' AS check_name, COUNT(*) AS count
FROM resource_access
WHERE is_active = true 
  AND access_end_date IS NOT NULL 
  AND access_end_date < CURRENT_DATE;

-- =====================================================
-- TEST 14: PERFORMANCE CHECKS
-- =====================================================

SELECT '=== TEST 14: Performance Stats ===' AS test;

-- Count records in each table
SELECT 'external_organizations' AS table_name, COUNT(*) AS record_count FROM external_organizations
UNION ALL
SELECT 'external_org_users', COUNT(*) FROM external_org_users
UNION ALL
SELECT 'resource_access', COUNT(*) FROM resource_access
UNION ALL
SELECT 'facilities', COUNT(*) FROM facilities
UNION ALL
SELECT 'equipment_register', COUNT(*) FROM equipment_register
UNION ALL
SELECT 'drawing_customer_approvals', COUNT(*) FROM drawing_customer_approvals
UNION ALL
SELECT 'vendor_progress_updates', COUNT(*) FROM vendor_progress_updates
UNION ALL
SELECT 'field_service_tickets', COUNT(*) FROM field_service_tickets
ORDER BY table_name;

-- =====================================================
-- SUMMARY
-- =====================================================

SELECT '=== TEST SUMMARY ===' AS test;
SELECT 
  'Total Organizations' AS metric,
  COUNT(*) AS value
FROM external_organizations
UNION ALL
SELECT 
  'Active Organizations',
  COUNT(*)
FROM external_organizations
WHERE is_active = true
UNION ALL
SELECT 
  'Total Users',
  COUNT(*)
FROM external_org_users
UNION ALL
SELECT 
  'Active Users',
  COUNT(*)
FROM external_org_users
WHERE is_active = true
UNION ALL
SELECT 
  'Total Resource Access Grants',
  COUNT(*)
FROM resource_access
UNION ALL
SELECT 
  'Active Access Grants',
  COUNT(*)
FROM resource_access
WHERE is_active = true
UNION ALL
SELECT 
  'Released Drawings',
  COUNT(*)
FROM drawings
WHERE is_released = true;

RAISE NOTICE '=== ALL TESTS COMPLETED ===';
