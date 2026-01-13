-- Approval Configuration for Plant B001, Company B001
-- Specific setup for B001 organizational structure

-- 1. Customer configuration for B001 company
INSERT INTO customer_material_request_config (customer_id, config_name, request_mode, intelligence_level) VALUES
('b001c0de-e29b-41d4-a716-446655440001', 'B001 Plant Operations', 'HYBRID', 'STANDARD')
ON CONFLICT (customer_id, config_name) DO UPDATE SET
  request_mode = EXCLUDED.request_mode,
  intelligence_level = EXCLUDED.intelligence_level,
  updated_at = NOW();

-- 2. Flexible approval levels for B001 plant operations
INSERT INTO flexible_approval_levels (
  customer_id, document_type, level_number, level_name, 
  amount_threshold_min, amount_threshold_max, approver_role, 
  is_required, is_active
) VALUES
-- Material Request approval levels for B001
('b001c0de-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 1, 'Plant Supervisor Approval', 0, 5000, 'PLANT_SUPERVISOR', true, true),
('b001c0de-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 2, 'Department Manager Approval', 5000, 25000, 'DEPT_MANAGER', true, true),
('b001c0de-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 3, 'Plant Manager Approval', 25000, 999999999, 'PLANT_MANAGER', true, true),

-- Purchase Requisition approval levels for B001
('b001c0de-e29b-41d4-a716-446655440001', 'PURCHASE_REQ', 1, 'Procurement Officer', 0, 10000, 'PROCUREMENT_OFFICER', true, true),
('b001c0de-e29b-41d4-a716-446655440001', 'PURCHASE_REQ', 2, 'Procurement Manager', 10000, 50000, 'PROCUREMENT_MANAGER', true, true),
('b001c0de-e29b-41d4-a716-446655440001', 'PURCHASE_REQ', 3, 'Plant Manager Approval', 50000, 999999999, 'PLANT_MANAGER', true, true),

-- Purchase Order approval levels for B001
('b001c0de-e29b-41d4-a716-446655440001', 'PURCHASE_ORDER', 1, 'Finance Officer', 0, 15000, 'FINANCE_OFFICER', true, true),
('b001c0de-e29b-41d4-a716-446655440001', 'PURCHASE_ORDER', 2, 'Finance Manager', 15000, 75000, 'FINANCE_MANAGER', true, true),
('b001c0de-e29b-41d4-a716-446655440001', 'PURCHASE_ORDER', 3, 'Plant Manager', 75000, 200000, 'PLANT_MANAGER', true, true),
('b001c0de-e29b-41d4-a716-446655440001', 'PURCHASE_ORDER', 4, 'General Manager', 200000, 999999999, 'GENERAL_MANAGER', true, true)

ON CONFLICT (customer_id, document_type, level_number) DO UPDATE SET
  level_name = EXCLUDED.level_name,
  amount_threshold_min = EXCLUDED.amount_threshold_min,
  amount_threshold_max = EXCLUDED.amount_threshold_max,
  approver_role = EXCLUDED.approver_role,
  updated_at = NOW();

-- 3. Customer approval configuration for B001
INSERT INTO customer_approval_configuration (
  customer_id, document_type, config_name, 
  emergency_override_enabled, emergency_override_roles,
  bulk_approval_enabled, parallel_approval_enabled
) VALUES
('b001c0de-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 'B001 MR Approval', 
 true, ARRAY['PLANT_MANAGER', 'GENERAL_MANAGER'], true, false),
('b001c0de-e29b-41d4-a716-446655440001', 'PURCHASE_REQ', 'B001 PR Approval', 
 true, ARRAY['PLANT_MANAGER', 'GENERAL_MANAGER'], true, false),
('b001c0de-e29b-41d4-a716-446655440001', 'PURCHASE_ORDER', 'B001 PO Approval', 
 true, ARRAY['GENERAL_MANAGER'], true, true)
ON CONFLICT (customer_id, document_type, config_name) DO UPDATE SET
  emergency_override_enabled = EXCLUDED.emergency_override_enabled,
  emergency_override_roles = EXCLUDED.emergency_override_roles,
  bulk_approval_enabled = EXCLUDED.bulk_approval_enabled,
  parallel_approval_enabled = EXCLUDED.parallel_approval_enabled,
  updated_at = NOW();

-- 4. Sample material requests for B001 plant
INSERT INTO material_requests (
  request_number, request_type, status, priority, requested_by, required_date,
  company_code, plant_code, cost_center, project_code, purpose, notes, created_by, total_amount
) VALUES
-- B001 Material Request - Low value
('MR-B001-240101-001', 'MATERIAL_REQ', 'SUBMITTED', 'MEDIUM', 
 'b001c0de-e29b-41d4-a716-446655440001', '2024-02-15',
 'B001', 'B001', 'CC-B001-PROD', 'PRJ-B001-001', 'Production materials for B001 plant', 
 'Raw materials for daily production operations', 'b001c0de-e29b-41d4-a716-446655440001', 3500.00),

-- B001 Purchase Requisition - Medium value
('PR-B001-240101-001', 'PURCHASE_REQ', 'SUBMITTED', 'HIGH',
 'b001c0de-e29b-41d4-a716-446655440001', '2024-02-20',
 'B001', 'B001', 'CC-B001-MAINT', 'PRJ-B001-002', 'Maintenance equipment for B001',
 'Spare parts and maintenance tools', 'b001c0de-e29b-41d4-a716-446655440001', 35000.00),

-- B001 Purchase Order - High value
('PO-B001-240101-001', 'PURCHASE_ORDER', 'SUBMITTED', 'URGENT',
 'b001c0de-e29b-41d4-a716-446655440001', '2024-02-10',
 'B001', 'B001', 'CC-B001-CAPEX', 'PRJ-B001-003', 'Capital equipment for B001 expansion',
 'New production line equipment', 'b001c0de-e29b-41d4-a716-446655440001', 150000.00)

ON CONFLICT (request_number) DO UPDATE SET
  status = EXCLUDED.status,
  total_amount = EXCLUDED.total_amount,
  updated_at = NOW();

-- 5. Test approval paths for B001 specific scenarios
SELECT 'B001 PLANT APPROVAL PATH TESTING:' as info;

-- Test $3,500 Material Request (should go to Plant Supervisor only)
SELECT 'B001 MR $3,500 - Plant Supervisor Level:' as test_case;
SELECT * FROM get_approval_path(
  'b001-company-uuid-4716-446655440001'::UUID,
  'MATERIAL_REQ',
  3500
);

-- Test $35,000 Purchase Requisition (should go through Procurement Manager)
SELECT 'B001 PR $35,000 - Procurement Manager Level:' as test_case;
SELECT * FROM get_approval_path(
  'b001-company-uuid-4716-446655440001'::UUID,
  'PURCHASE_REQ',
  35000
);

-- Test $150,000 Purchase Order (should go through Finance Manager + Plant Manager)
SELECT 'B001 PO $150,000 - Multi-Level Approval:' as test_case;
SELECT * FROM get_approval_path(
  'b001-company-uuid-4716-446655440001'::UUID,
  'PURCHASE_ORDER',
  150000
);

-- 6. Department-specific approval delegations for B001
INSERT INTO approval_delegations (
  delegator_id, delegate_id, document_types, amount_limit,
  valid_from, valid_to, reason, is_active
) VALUES
-- Plant Supervisor can delegate MR approvals up to $5,000
('b001-plant-supervisor-uuid', 'b001-assistant-supervisor-uuid', 
 ARRAY['MATERIAL_REQ'], 5000.00, '2024-01-01', '2024-12-31', 
 'Vacation and shift coverage delegation', true),

-- Department Manager can delegate PR approvals up to $25,000
('b001-dept-manager-uuid', 'b001-senior-engineer-uuid',
 ARRAY['PURCHASE_REQ'], 25000.00, '2024-01-01', '2024-12-31',
 'Business trip and leave coverage', true)

ON CONFLICT DO NOTHING;

-- 7. B001 specific validation and metrics
SELECT 'B001 CONFIGURATION VALIDATION:' as info;

-- Validate B001 approval configurations
SELECT 
  'B001 Plant Validation' as plant,
  document_type,
  config_name,
  (SELECT is_valid FROM validate_approval_config(cac.id)) as is_valid_config
FROM customer_approval_configuration cac
WHERE customer_id = 'b001-company-uuid-4716-446655440001'
AND is_active = true;

-- B001 approval level summary
SELECT 
  'B001 Approval Levels Summary' as summary,
  document_type,
  COUNT(*) as total_levels,
  MIN(amount_threshold_min) as min_amount,
  MAX(amount_threshold_max) as max_amount,
  STRING_AGG(approver_role, ' -> ' ORDER BY level_number) as approval_chain
FROM flexible_approval_levels
WHERE customer_id = 'b001-company-uuid-4716-446655440001'
AND is_active = true
GROUP BY document_type
ORDER BY document_type;

-- 8. Emergency override test for B001
SELECT 'B001 EMERGENCY SCENARIOS:' as info;

-- Emergency override roles for B001
SELECT 
  'B001 Emergency Override Roles' as scenario,
  document_type,
  emergency_override_roles,
  'Plant Manager and General Manager can override approvals' as capability
FROM customer_approval_configuration
WHERE customer_id = 'b001-company-uuid-4716-446655440001'
AND emergency_override_enabled = true;

COMMENT ON TABLE flexible_approval_levels IS 'B001 plant now configured with department-specific approval levels';
COMMENT ON TABLE customer_approval_configuration IS 'B001 company approval workflows configured for plant operations';