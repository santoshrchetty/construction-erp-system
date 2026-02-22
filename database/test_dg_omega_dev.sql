-- =====================================================
-- DOCUMENT GOVERNANCE TEST DATA FOR OMEGA-DEV
-- =====================================================
-- Tenant: OMEGA-DEV (9bd339ec-9877-4d9f-b3dc-3e60048c1b15)
-- User: internaluser@abc.com (2d17fcf3-d4f0-4308-a2f4-2e97205a3765)

DO $$
DECLARE
  v_tenant_id UUID := '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';
  v_user_id UUID := '2d17fcf3-d4f0-4308-a2f4-2e97205a3765';
BEGIN

-- =====================================================
-- 1. CONTRACTS
-- =====================================================
INSERT INTO contracts (tenant_id, contract_number, title, status, start_date, end_date, contract_value, created_by)
VALUES 
  (v_tenant_id, 'CNT-DEV-001', 'Main Construction Contract - Phase 1', 'Active', '2024-01-01', '2024-12-31', 5000000.00, v_user_id),
  (v_tenant_id, 'CNT-DEV-002', 'Electrical Works Contract', 'Active', '2024-03-01', '2024-09-30', 750000.00, v_user_id),
  (v_tenant_id, 'CNT-DEV-003', 'HVAC Installation Contract', 'Draft', '2024-04-01', '2024-10-31', 450000.00, v_user_id);

-- =====================================================
-- 2. RFIS (Request for Information)
-- =====================================================
INSERT INTO rfis (tenant_id, rfi_number, subject, description, status, priority, created_by)
VALUES 
  (v_tenant_id, 'RFI-DEV-001', 'Foundation Design Clarification', 'Need clarification on foundation depth requirements', 'Open', 'High', v_user_id),
  (v_tenant_id, 'RFI-DEV-002', 'Material Specification Query', 'Confirm approved material brands for plumbing', 'In Review', 'Medium', v_user_id),
  (v_tenant_id, 'RFI-DEV-003', 'Schedule Conflict Resolution', 'Resolve scheduling conflict between trades', 'Closed', 'Low', v_user_id);

-- =====================================================
-- 3. SPECIFICATIONS
-- =====================================================
INSERT INTO specifications (tenant_id, spec_number, title, version, status, created_by)
VALUES 
  (v_tenant_id, 'SPEC-DEV-001', 'Concrete Mix Design Specification', '1.0', 'Approved', v_user_id),
  (v_tenant_id, 'SPEC-DEV-002', 'Electrical Installation Standards', '2.1', 'Approved', v_user_id),
  (v_tenant_id, 'SPEC-DEV-003', 'Safety Equipment Requirements', '1.0', 'Draft', v_user_id);

-- =====================================================
-- 4. SUBMITTALS
-- =====================================================
INSERT INTO submittals (tenant_id, submittal_number, title, status, submitted_date, created_by)
VALUES 
  (v_tenant_id, 'SUB-DEV-001', 'Structural Steel Shop Drawings', 'Approved', CURRENT_DATE - 5, v_user_id),
  (v_tenant_id, 'SUB-DEV-002', 'Window System Product Data', 'Under Review', CURRENT_DATE - 2, v_user_id),
  (v_tenant_id, 'SUB-DEV-003', 'Concrete Test Reports', 'Submitted', CURRENT_DATE, v_user_id);

-- =====================================================
-- 5. CHANGE ORDERS
-- =====================================================
INSERT INTO change_orders (tenant_id, change_order_number, title, description, status, cost_impact, created_by)
VALUES 
  (v_tenant_id, 'CO-DEV-001', 'Additional Parking Spaces', 'Add 20 additional parking spaces per client request', 'Approved', 125000.00, v_user_id),
  (v_tenant_id, 'CO-DEV-002', 'HVAC System Upgrade', 'Upgrade to more efficient HVAC system', 'Pending', 85000.00, v_user_id),
  (v_tenant_id, 'CO-DEV-003', 'Scope Reduction - Landscaping', 'Reduce landscaping scope to meet budget', 'Draft', -45000.00, v_user_id);

-- =====================================================
-- 6. MASTER DATA DOCUMENTS
-- =====================================================
INSERT INTO master_data_documents (tenant_id, document_number, document_type, title, category, status, created_by)
VALUES 
  (v_tenant_id, 'MDD-DEV-001', 'Quality', 'Project Quality Plan', 'Project Management', 'Active', v_user_id),
  (v_tenant_id, 'MDD-DEV-002', 'Safety', 'Safety Management Plan', 'HSE', 'Active', v_user_id),
  (v_tenant_id, 'MDD-DEV-003', 'Environmental', 'Environmental Management Plan', 'HSE', 'Active', v_user_id),
  (v_tenant_id, 'MDD-DEV-004', 'Procedure', 'Document Control Procedure', 'Administration', 'Active', v_user_id);

RAISE NOTICE 'Test data created for OMEGA-DEV tenant';
END $$;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check contracts
SELECT 'Contracts' as table_name, COUNT(*) as record_count
FROM contracts WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
UNION ALL
-- Check RFIs
SELECT 'RFIs', COUNT(*)
FROM rfis WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
UNION ALL
-- Check specifications
SELECT 'Specifications', COUNT(*)
FROM specifications WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
UNION ALL
-- Check submittals
SELECT 'Submittals', COUNT(*)
FROM submittals WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
UNION ALL
-- Check change orders
SELECT 'Change Orders', COUNT(*)
FROM change_orders WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
UNION ALL
-- Check master documents
SELECT 'Master Documents', COUNT(*)
FROM master_data_documents WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

-- Detailed view of all DG records
SELECT 
  'Contract' as doc_type,
  contract_number as doc_number,
  title,
  status,
  created_at
FROM contracts 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
UNION ALL
SELECT 
  'RFI',
  rfi_number,
  subject,
  status,
  created_at
FROM rfis 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
UNION ALL
SELECT 
  'Specification',
  spec_number,
  title,
  status,
  created_at
FROM specifications 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
UNION ALL
SELECT 
  'Submittal',
  submittal_number,
  title,
  status,
  created_at
FROM submittals 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
UNION ALL
SELECT 
  'Change Order',
  change_order_number,
  title,
  status,
  created_at
FROM change_orders 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
UNION ALL
SELECT 
  'Master Document',
  document_number,
  title,
  status,
  created_at
FROM master_data_documents 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY doc_type, doc_number;
