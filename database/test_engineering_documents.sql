-- 🧪 ENGINEERING DOCUMENT SYSTEM - COMPREHENSIVE TEST SUITE

-- Test 1: Create Documents with Lifecycle
SELECT '=== TEST 1: CREATE DOCUMENTS ===' as test_section;

SELECT * FROM create_document_with_lifecycle(
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW',
  'Master Site Plan',
  'ARCHITECTURAL',
  'PROJ-ALPHA-001',
  'Overall site layout and building positioning',
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
);

SELECT * FROM create_document_with_lifecycle(
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'SPE',
  'Concrete Specifications',
  'STRUCTURAL',
  'PROJ-ALPHA-001',
  'Technical specifications for concrete work',
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
);

SELECT * FROM create_document_with_lifecycle(
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'RFI',
  'Foundation Depth Clarification',
  'STRUCTURAL',
  'PROJ-ALPHA-001',
  'Request for information on foundation requirements',
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
);

-- Test 2: Verify Documents Created
SELECT '=== TEST 2: VERIFY DOCUMENTS CREATED ===' as test_section;

SELECT 
  d.document_number,
  d.document_type,
  d.title,
  d.discipline,
  d.project_code,
  dl.version,
  dl.status,
  dl.is_current
FROM documents d
JOIN document_lifecycle dl ON d.id = dl.document_id
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY d.created_at DESC;

-- Test 3: Add Document Relationships
SELECT '=== TEST 3: ADD RELATIONSHIPS ===' as test_section;

-- Get document IDs for relationship testing
WITH doc_ids AS (
  SELECT 
    d.id,
    d.document_number,
    d.document_type
  FROM documents d 
  WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  ORDER BY d.created_at DESC
  LIMIT 3
)
SELECT 
  add_document_relationship(
    (SELECT id FROM doc_ids WHERE document_type = 'SPE'),
    (SELECT id FROM doc_ids WHERE document_type = 'DRW'),
    'REFERENCES',
    true,
    (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
  ) as relationship_id;

-- Test 4: Add WBS Financial Ownership
SELECT '=== TEST 4: ADD WBS OWNERSHIP ===' as test_section;

-- Add financial owner WBS to each document
INSERT INTO document_wbs_links (document_id, wbs_id, is_financial_owner, created_by)
SELECT 
  d.id,
  gen_random_uuid(),
  true,
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
FROM documents d 
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

-- Test 5: Issue Revision (Cost Impact Trigger)
SELECT '=== TEST 5: ISSUE REVISION ===' as test_section;

SELECT issue_document_revision(
  (SELECT d.id FROM documents d WHERE d.document_type = 'DRW' AND d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1),
  'A',
  'IFC',
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
) as revision_issued;

-- Test 6: Verify Cost Impact Created
SELECT '=== TEST 6: VERIFY COST IMPACT ===' as test_section;

SELECT 
  d.document_number,
  dci.impact_type,
  dci.requires_approval,
  dci.created_at
FROM document_cost_impacts dci
JOIN documents d ON dci.document_id = d.id
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

-- Test 7: Test Hierarchical View
SELECT '=== TEST 7: HIERARCHICAL VIEW ===' as test_section;

SELECT * FROM get_document_hierarchy(
  (SELECT d.id FROM documents d WHERE d.document_type = 'DRW' AND d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
);

-- Test 8: Test Financial Ownership
SELECT '=== TEST 8: FINANCIAL OWNERSHIP ===' as test_section;

SELECT * FROM get_document_financial_ownership(
  (SELECT d.id FROM documents d WHERE d.document_type = 'DRW' AND d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
);

-- Test 9: Verify Document Lifecycle History
SELECT '=== TEST 9: LIFECYCLE HISTORY ===' as test_section;

SELECT 
  d.document_number,
  dl.version,
  dl.revision,
  dl.status,
  dl.effective_date,
  dl.is_current,
  dl.created_at
FROM documents d
JOIN document_lifecycle dl ON d.id = dl.document_id
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY d.document_number, dl.created_at;

-- Test 10: Verify Relationships
SELECT '=== TEST 10: DOCUMENT RELATIONSHIPS ===' as test_section;

SELECT 
  d1.document_number as document,
  dr.relationship_type,
  d2.document_number as related_document,
  dr.is_primary
FROM document_relationships dr
JOIN documents d1 ON dr.document_id = d1.id
JOIN documents d2 ON dr.related_document_id = d2.id
WHERE d1.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

-- Test 11: Test Constraints (Should Fail)
SELECT '=== TEST 11: CONSTRAINT TESTS ===' as test_section;

-- Try to add second financial owner (should fail)
DO $$
BEGIN
  INSERT INTO document_wbs_links (document_id, wbs_id, is_financial_owner, created_by)
  SELECT 
    d.id,
    gen_random_uuid(),
    true,
    (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
  FROM documents d 
  WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  LIMIT 1;
  
  RAISE NOTICE 'ERROR: Second financial owner should have been rejected!';
EXCEPTION
  WHEN unique_violation THEN
    RAISE NOTICE 'SUCCESS: Constraint prevented second financial owner';
END $$;

-- Test 12: Performance Test
SELECT '=== TEST 12: PERFORMANCE SUMMARY ===' as test_section;

SELECT 
  'Documents' as table_name,
  COUNT(*) as record_count
FROM documents 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'

UNION ALL

SELECT 
  'Lifecycle Records' as table_name,
  COUNT(*) as record_count
FROM document_lifecycle dl
JOIN documents d ON dl.document_id = d.id
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'

UNION ALL

SELECT 
  'Relationships' as table_name,
  COUNT(*) as record_count
FROM document_relationships dr
JOIN documents d ON dr.document_id = d.id
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'

UNION ALL

SELECT 
  'WBS Links' as table_name,
  COUNT(*) as record_count
FROM document_wbs_links dwl
JOIN documents d ON dwl.document_id = d.id
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'

UNION ALL

SELECT 
  'Cost Impacts' as table_name,
  COUNT(*) as record_count
FROM document_cost_impacts dci
JOIN documents d ON dci.document_id = d.id
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

SELECT '=== ALL TESTS COMPLETED ===' as test_result;