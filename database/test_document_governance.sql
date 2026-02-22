-- =====================================================
-- DOCUMENT GOVERNANCE TEST DATA
-- =====================================================

-- Get tenant_id and user_id for test data
DO $$
DECLARE
  v_tenant_id UUID;
  v_user_id UUID;
BEGIN
  -- Get first tenant
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  
  -- Get first user
  SELECT id INTO v_user_id FROM users LIMIT 1;

  -- Insert test drawings
  INSERT INTO drawings (tenant_id, drawing_number, title, description, revision, discipline, status, created_by)
  VALUES 
    (v_tenant_id, 'DRW-001', 'Site Plan', 'Overall site layout and boundaries', 'Rev 0', 'Civil', 'Draft', v_user_id),
    (v_tenant_id, 'DRW-002', 'Foundation Plan', 'Foundation details and specifications', 'Rev 1', 'Structural', 'Approved', v_user_id),
    (v_tenant_id, 'DRW-003', 'Electrical Layout', 'Main electrical distribution', 'Rev 0', 'Electrical', 'Under Review', v_user_id),
    (v_tenant_id, 'DRW-004', 'HVAC System', 'Heating and cooling system design', 'Rev 2', 'Mechanical', 'Approved', v_user_id),
    (v_tenant_id, 'DRW-005', 'Plumbing Diagram', 'Water supply and drainage', 'Rev 0', 'Plumbing', 'Draft', v_user_id);

  -- Insert test contracts
  INSERT INTO contracts (tenant_id, contract_number, title, vendor_name, contract_value, start_date, end_date, status, created_by)
  VALUES 
    (v_tenant_id, 'CNT-001', 'General Construction Contract', 'ABC Construction Inc', 5000000.00, '2024-01-01', '2024-12-31', 'Active', v_user_id),
    (v_tenant_id, 'CNT-002', 'Electrical Installation', 'Elite Electric Co', 750000.00, '2024-03-01', '2024-09-30', 'Active', v_user_id),
    (v_tenant_id, 'CNT-003', 'HVAC Systems', 'Climate Control Ltd', 450000.00, '2024-02-15', '2024-08-15', 'Pending', v_user_id),
    (v_tenant_id, 'CNT-004', 'Plumbing Services', 'Pro Plumbing Solutions', 320000.00, '2024-04-01', '2024-10-31', 'Draft', v_user_id);

  -- Insert test RFIs
  INSERT INTO rfis (tenant_id, rfi_number, subject, description, discipline, priority, status, due_date, created_by)
  VALUES 
    (v_tenant_id, 'RFI-001', 'Foundation Depth Clarification', 'Need clarification on foundation depth in zone A', 'Structural', 'High', 'Open', CURRENT_DATE + 7, v_user_id),
    (v_tenant_id, 'RFI-002', 'Electrical Panel Location', 'Confirm location of main electrical panel', 'Electrical', 'Medium', 'Open', CURRENT_DATE + 14, v_user_id),
    (v_tenant_id, 'RFI-003', 'Material Specification', 'Clarify concrete grade for columns', 'Structural', 'High', 'Answered', CURRENT_DATE - 5, v_user_id),
    (v_tenant_id, 'RFI-004', 'HVAC Duct Routing', 'Alternative routing for HVAC ducts', 'Mechanical', 'Low', 'Open', CURRENT_DATE + 21, v_user_id),
    (v_tenant_id, 'RFI-005', 'Window Specifications', 'Confirm window type for north facade', 'Architectural', 'Medium', 'Closed', CURRENT_DATE - 10, v_user_id);

  -- Insert test specifications
  INSERT INTO specifications (tenant_id, spec_number, title, description, discipline, status, version, created_by)
  VALUES 
    (v_tenant_id, 'SPEC-001', 'Concrete Specifications', 'Concrete mix and placement requirements', 'Structural', 'Approved', 'v1.0', v_user_id),
    (v_tenant_id, 'SPEC-002', 'Electrical Standards', 'Electrical installation standards', 'Electrical', 'Draft', 'v1.0', v_user_id),
    (v_tenant_id, 'SPEC-003', 'HVAC Requirements', 'HVAC system performance requirements', 'Mechanical', 'Under Review', 'v2.0', v_user_id);

  -- Insert test submittals
  INSERT INTO submittals (tenant_id, submittal_number, title, vendor_name, spec_section, status, review_status, submitted_date, required_date, created_by)
  VALUES 
    (v_tenant_id, 'SUB-001', 'Structural Steel Shop Drawings', 'Steel Fabricators Inc', '05-12-00', 'Submitted', 'Pending', CURRENT_DATE - 3, CURRENT_DATE + 7, v_user_id),
    (v_tenant_id, 'SUB-002', 'Electrical Fixtures', 'Lighting Solutions Ltd', '26-51-00', 'Submitted', 'Approved', CURRENT_DATE - 10, CURRENT_DATE - 3, v_user_id),
    (v_tenant_id, 'SUB-003', 'HVAC Equipment', 'Climate Control Ltd', '23-00-00', 'Submitted', 'Rejected', CURRENT_DATE - 15, CURRENT_DATE - 8, v_user_id);

  -- Insert test change orders
  INSERT INTO change_orders (tenant_id, change_order_number, title, description, cost_impact, schedule_impact_days, status, priority, created_by)
  VALUES 
    (v_tenant_id, 'CO-001', 'Additional Foundation Work', 'Extra foundation work due to soil conditions', 125000.00, 14, 'Pending', 'High', v_user_id),
    (v_tenant_id, 'CO-002', 'Electrical Panel Upgrade', 'Upgrade main electrical panel capacity', 35000.00, 5, 'Approved', 'Medium', v_user_id),
    (v_tenant_id, 'CO-003', 'HVAC System Modification', 'Modify HVAC layout per client request', 68000.00, 10, 'Draft', 'Low', v_user_id);

  -- Insert test master data documents
  INSERT INTO master_data_documents (tenant_id, document_number, document_type, title, category, status, version, created_by)
  VALUES 
    (v_tenant_id, 'MD-001', 'Policy', 'Safety Policy Manual', 'Safety', 'Approved', 'v2.1', v_user_id),
    (v_tenant_id, 'MD-002', 'Procedure', 'Quality Control Procedures', 'Quality', 'Approved', 'v1.5', v_user_id),
    (v_tenant_id, 'MD-003', 'Standard', 'Material Testing Standards', 'Quality', 'Draft', 'v1.0', v_user_id),
    (v_tenant_id, 'MD-004', 'Template', 'RFI Response Template', 'Templates', 'Approved', 'v1.0', v_user_id);

  RAISE NOTICE 'Test data inserted successfully!';
  RAISE NOTICE 'Tenant ID: %', v_tenant_id;
  RAISE NOTICE 'User ID: %', v_user_id;
END $$;

-- Verify data insertion
SELECT 'Drawings' as table_name, COUNT(*) as record_count FROM drawings
UNION ALL
SELECT 'Contracts', COUNT(*) FROM contracts
UNION ALL
SELECT 'RFIs', COUNT(*) FROM rfis
UNION ALL
SELECT 'Specifications', COUNT(*) FROM specifications
UNION ALL
SELECT 'Submittals', COUNT(*) FROM submittals
UNION ALL
SELECT 'Change Orders', COUNT(*) FROM change_orders
UNION ALL
SELECT 'Master Data Documents', COUNT(*) FROM master_data_documents;
