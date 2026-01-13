-- Sample Data and Testing for Flexible Approval System
-- Create sample customers, approval configurations, and test data

-- 1. Sample customer configurations
INSERT INTO customer_material_request_config (customer_id, config_name, request_mode, intelligence_level) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Traditional Mode', 'TRADITIONAL', 'BASIC'),
('550e8400-e29b-41d4-a716-446655440002', 'Hybrid Mode', 'HYBRID', 'STANDARD'),
('550e8400-e29b-41d4-a716-446655440003', 'Intelligent Mode', 'INTELLIGENT', 'ADVANCED')
ON CONFLICT (customer_id, config_name) DO UPDATE SET
  request_mode = EXCLUDED.request_mode,
  intelligence_level = EXCLUDED.intelligence_level,
  updated_at = NOW();

-- 2. Clean existing configurations to avoid duplicates
DELETE FROM flexible_approval_levels WHERE customer_id IN (
  '550e8400-e29b-41d4-a716-446655440001',
  '550e8400-e29b-41d4-a716-446655440002', 
  '550e8400-e29b-41d4-a716-446655440003'
);

DELETE FROM customer_approval_configuration 
WHERE customer_id IN (
  '550e8400-e29b-41d4-a716-446655440001',
  '550e8400-e29b-41d4-a716-446655440002',
  '550e8400-e29b-41d4-a716-446655440003'
);

-- Apply approval templates to sample customers
SELECT apply_approval_template(
  '550e8400-e29b-41d4-a716-446655440001'::UUID,
  'MATERIAL_REQ',
  (SELECT id FROM approval_level_templates WHERE template_name = 'Standard 2-Level' LIMIT 1),
  'MR Standard Approval'
) as small_company_mr_setup;

SELECT apply_approval_template(
  '550e8400-e29b-41d4-a716-446655440002'::UUID,
  'PURCHASE_REQ',
  (SELECT id FROM approval_level_templates WHERE template_name = 'Construction 3-Level' LIMIT 1),
  'PR Construction Approval'
) as medium_company_pr_setup;

SELECT apply_approval_template(
  '550e8400-e29b-41d4-a716-446655440003'::UUID,
  'PURCHASE_ORDER',
  (SELECT id FROM approval_level_templates WHERE template_name = 'Enterprise 5-Level' LIMIT 1),
  'PO Enterprise Approval'
) as large_company_po_setup;

-- 3. Sample material requests for testing
INSERT INTO material_requests (
  request_number, request_type, status, priority, requested_by, required_date,
  company_code, plant_code, cost_center, project_code, purpose, notes, created_by
) VALUES
-- Small company material request
('MR-C001-240101-001', 'MATERIAL_REQ', 'SUBMITTED', 'MEDIUM', 
 '550e8400-e29b-41d4-a716-446655440001', '2024-02-15',
 'C001', 'P001', 'CC001', 'PRJ001', 'Construction materials for foundation work', 
 'Cement and steel required for foundation phase', '550e8400-e29b-41d4-a716-446655440001'),

-- Medium company purchase requisition
('PR-C002-240101-001', 'PURCHASE_REQ', 'SUBMITTED', 'HIGH',
 '550e8400-e29b-41d4-a716-446655440002', '2024-02-20',
 'C002', 'P002', 'CC002', 'PRJ002', 'Equipment procurement for project',
 'Heavy machinery required for construction phase', '550e8400-e29b-41d4-a716-446655440002'),

-- Large company purchase order
('PO-C003-240101-001', 'PURCHASE_ORDER', 'SUBMITTED', 'URGENT',
 '550e8400-e29b-41d4-a716-446655440003', '2024-02-10',
 'C003', 'P003', 'CC003', 'PRJ003', 'Major equipment purchase',
 'Capital equipment for infrastructure project', '550e8400-e29b-41d4-a716-446655440003')

ON CONFLICT (request_number) DO UPDATE SET
  status = EXCLUDED.status,
  updated_at = NOW();

-- 4. Sample request items
INSERT INTO material_request_items (
  request_id, line_number, material_code, material_name, description,
  requested_quantity, base_uom, estimated_price, currency_code
) VALUES
-- Items for MR-C001-240101-001
((SELECT id FROM material_requests WHERE request_number = 'MR-C001-240101-001'), 1, 
 'CEMENT-OPC-53', 'OPC 53 Grade Cement', 'High strength cement for foundation', 
 100, 'BAG', 500.00, 'USD'),
((SELECT id FROM material_requests WHERE request_number = 'MR-C001-240101-001'), 2,
 'STEEL-TMT-12MM', 'TMT Steel Bars 12mm', 'Reinforcement steel bars',
 5, 'TON', 65000.00, 'USD'),

-- Items for PR-C002-240101-001
((SELECT id FROM material_requests WHERE request_number = 'PR-C002-240101-001'), 1,
 'EXCAVATOR-CAT320', 'Caterpillar 320 Excavator', 'Heavy duty excavator',
 1, 'EA', 250000.00, 'USD'),

-- Items for PO-C003-240101-001
((SELECT id FROM material_requests WHERE request_number = 'PO-C003-240101-001'), 1,
 'CRANE-TOWER-50T', 'Tower Crane 50 Ton', 'Heavy lifting tower crane',
 1, 'EA', 500000.00, 'USD')

ON CONFLICT (request_id, line_number) DO UPDATE SET
  estimated_price = EXCLUDED.estimated_price,
  updated_at = NOW();

-- 5. Test approval path calculations
SELECT 'TESTING APPROVAL PATHS:' as info;

-- Test $15,000 Material Request for small company
SELECT 'Small Company MR ($15,000):' as test_case;
SELECT * FROM get_approval_path(
  '550e8400-e29b-41d4-a716-446655440001'::UUID,
  'MATERIAL_REQ',
  15000
);

-- Test $75,000 Purchase Requisition for medium company
SELECT 'Medium Company PR ($75,000):' as test_case;
SELECT * FROM get_approval_path(
  '550e8400-e29b-41d4-a716-446655440002'::UUID,
  'PURCHASE_REQ',
  75000
);

-- Test $500,000 Purchase Order for large company
SELECT 'Large Company PO ($500,000):' as test_case;
SELECT * FROM get_approval_path(
  '550e8400-e29b-41d4-a716-446655440003'::UUID,
  'PURCHASE_ORDER',
  500000
);

-- 6. Sample approval executions
INSERT INTO approval_executions (
  request_id, config_id, current_level, status, total_levels, execution_path
) VALUES
((SELECT id FROM material_requests WHERE request_number = 'MR-C001-240101-001'),
 (SELECT id FROM customer_approval_configuration WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001' AND document_type = 'MATERIAL_REQ' LIMIT 1),
 1, 'PENDING', 2, '{"levels": [{"level": 1, "role": "SUPERVISOR"}, {"level": 2, "role": "MANAGER"}]}'),

((SELECT id FROM material_requests WHERE request_number = 'PR-C002-240101-001'),
 (SELECT id FROM customer_approval_configuration WHERE customer_id = '550e8400-e29b-41d4-a716-446655440002' AND document_type = 'PURCHASE_REQ' LIMIT 1),
 1, 'PENDING', 3, '{"levels": [{"level": 1, "role": "SITE_SUPERVISOR"}, {"level": 2, "role": "PROJECT_MANAGER"}, {"level": 3, "role": "OPERATIONS_MANAGER"}]}')

ON CONFLICT DO NOTHING;

-- 7. Configuration validation tests
SELECT 'CONFIGURATION VALIDATION TESTS:' as info;

-- Validate all customer configurations
SELECT 
  customer_id,
  document_type,
  config_name,
  (SELECT is_valid FROM validate_approval_config(cac.id)) as is_valid_config,
  (SELECT validation_errors FROM validate_approval_config(cac.id)) as validation_errors
FROM customer_approval_configuration cac
WHERE is_active = true;

-- 8. Performance test data
SELECT 'PERFORMANCE METRICS:' as info;

-- Count of approval levels by customer
SELECT 
  'Approval Levels by Customer' as metric,
  customer_id,
  document_type,
  COUNT(*) as level_count,
  MIN(amount_threshold_min) as min_threshold,
  MAX(amount_threshold_max) as max_threshold
FROM flexible_approval_levels
WHERE is_active = true
GROUP BY customer_id, document_type
ORDER BY customer_id, document_type;

-- Template usage statistics
SELECT 
  'Template Usage Statistics' as metric,
  template_name,
  customer_type,
  industry_type,
  usage_count
FROM approval_level_templates
WHERE is_public = true
ORDER BY usage_count DESC;

-- 9. Integration test scenarios
SELECT 'INTEGRATION TEST SCENARIOS:' as info;

-- Scenario 1: Emergency approval bypass
SELECT 'Emergency Bypass Test' as scenario,
       'Should allow emergency override for urgent requests' as expected_behavior;

-- Scenario 2: Delegation workflow
SELECT 'Delegation Test' as scenario,
       'Should route to delegate when primary approver is unavailable' as expected_behavior;

-- Scenario 3: Parallel approval
SELECT 'Parallel Approval Test' as scenario,
       'Should require both technical and financial approval simultaneously' as expected_behavior;

-- 10. Cleanup function for testing
CREATE OR REPLACE FUNCTION cleanup_test_data()
RETURNS TEXT AS $$
BEGIN
  -- Remove test material requests
  DELETE FROM material_request_items WHERE request_id IN (
    SELECT id FROM material_requests WHERE request_number LIKE '%-C00_-240101-%'
  );
  DELETE FROM material_requests WHERE request_number LIKE '%-C00_-240101-%';
  
  -- Remove test approval executions
  DELETE FROM approval_executions WHERE request_id NOT IN (SELECT id FROM material_requests);
  
  RETURN 'Test data cleaned up successfully';
END;
$$ LANGUAGE plpgsql;

-- Usage: SELECT cleanup_test_data(); -- Run this to clean up test data

COMMENT ON FUNCTION cleanup_test_data IS 'Cleanup function to remove test data after testing';