-- MR/PR/PO Document Types with Specific Approval Workflows
-- Each document type has different approval requirements and business logic

-- 1. Document type definitions and characteristics
CREATE TABLE document_type_config (
  document_type VARCHAR(20) PRIMARY KEY,
  document_name VARCHAR(100) NOT NULL,
  description TEXT,
  is_internal BOOLEAN DEFAULT true,
  requires_vendor BOOLEAN DEFAULT false,
  creates_financial_commitment BOOLEAN DEFAULT false,
  can_convert_to VARCHAR(20), -- Next document in workflow
  default_approval_levels INTEGER DEFAULT 2,
  characteristics JSONB
);

INSERT INTO document_type_config VALUES
('MATERIAL_REQ', 'Material Request', 'Internal request for materials from inventory or for procurement', true, false, false, 'PURCHASE_REQ', 2, 
 '{"purpose": "internal_request", "budget_impact": "none", "vendor_required": false, "legal_commitment": false}'),

('PURCHASE_REQ', 'Purchase Requisition', 'Formal request to procurement department to purchase materials/services', true, false, true, 'PURCHASE_ORDER', 3,
 '{"purpose": "procurement_request", "budget_impact": "reserved", "vendor_required": false, "legal_commitment": false}'),

('PURCHASE_ORDER', 'Purchase Order', 'Legal commitment to purchase materials/services from vendor', false, true, true, null, 4,
 '{"purpose": "vendor_commitment", "budget_impact": "committed", "vendor_required": true, "legal_commitment": true}'),

('RESERVATION', 'Material Reservation', 'Reserve materials from inventory for future use', true, false, false, null, 1,
 '{"purpose": "inventory_allocation", "budget_impact": "none", "vendor_required": false, "legal_commitment": false}');

-- 2. Document-specific approval workflows
DELETE FROM approval_workflows;

-- MATERIAL REQUEST WORKFLOWS
INSERT INTO approval_workflows (
  workflow_name, request_type, company_code, material_category, amount_threshold,
  level_1_approver_role, level_1_amount_limit,
  level_2_approver_role, level_2_amount_limit,
  level_3_approver_role, level_3_amount_limit
) VALUES
-- MR: Simple internal approval (no financial commitment)
('MR - Standard Materials', 'MATERIAL_REQ', 'C001', NULL, 0, 'SUPERVISOR', 5000, 'DEPARTMENT_HEAD', 25000, NULL, NULL),
('MR - Safety Equipment', 'MATERIAL_REQ', 'C001', 'SAFETY', 0, 'SAFETY_OFFICER', 10000, 'SITE_MANAGER', 50000, NULL, NULL),
('MR - Emergency Request', 'MATERIAL_REQ', 'C001', 'EMERGENCY', 0, 'DUTY_MANAGER', 15000, NULL, NULL, NULL, NULL);

-- PURCHASE REQUISITION WORKFLOWS  
INSERT INTO approval_workflows (
  workflow_name, request_type, company_code, material_category, amount_threshold,
  level_1_approver_role, level_1_amount_limit,
  level_2_approver_role, level_2_amount_limit,
  level_3_approver_role, level_3_amount_limit
) VALUES
-- PR: Budget impact requires financial approval
('PR - Standard Procurement', 'PURCHASE_REQ', 'C001', NULL, 1000, 'DEPARTMENT_HEAD', 10000, 'PROCUREMENT_MANAGER', 50000, 'FINANCE_MANAGER', 200000),
('PR - Construction Materials', 'PURCHASE_REQ', 'C001', 'CONSTRUCTION', 5000, 'SITE_ENGINEER', 25000, 'PROJECT_MANAGER', 100000, 'OPERATIONS_DIRECTOR', 500000),
('PR - Equipment Purchase', 'PURCHASE_REQ', 'C001', 'EQUIPMENT', 10000, 'EQUIPMENT_MANAGER', 50000, 'TECHNICAL_DIRECTOR', 200000, 'GENERAL_MANAGER', 1000000);

-- PURCHASE ORDER WORKFLOWS
INSERT INTO approval_workflows (
  workflow_name, request_type, company_code, material_category, amount_threshold,
  level_1_approver_role, level_1_amount_limit,
  level_2_approver_role, level_2_amount_limit,
  level_3_approver_role, level_3_amount_limit
) VALUES
-- PO: Legal commitment requires highest approval levels
('PO - Standard Purchase', 'PURCHASE_ORDER', 'C001', NULL, 5000, 'PROCUREMENT_MANAGER', 25000, 'FINANCE_MANAGER', 100000, 'CFO', 500000),
('PO - Capital Equipment', 'PURCHASE_ORDER', 'C001', 'CAPITAL', 25000, 'TECHNICAL_DIRECTOR', 100000, 'GENERAL_MANAGER', 500000, 'CEO', 2000000),
('PO - Major Contracts', 'PURCHASE_ORDER', 'C001', 'CONTRACT', 50000, 'GENERAL_MANAGER', 250000, 'CEO', 1000000, 'BOARD_APPROVAL', 999999999);

-- RESERVATION WORKFLOWS
INSERT INTO approval_workflows (
  workflow_name, request_type, company_code, material_category, amount_threshold,
  level_1_approver_role, level_1_amount_limit,
  level_2_approver_role, level_2_amount_limit,
  level_3_approver_role, level_3_amount_limit
) VALUES
-- Reservations: Minimal approval (no financial impact)
('Reservation - Project Materials', 'RESERVATION', 'C001', NULL, 0, 'PROJECT_ENGINEER', 50000, 'PROJECT_MANAGER', 200000, NULL, NULL),
('Reservation - Emergency', 'RESERVATION', 'C001', 'EMERGENCY', 0, 'SITE_SUPERVISOR', 25000, NULL, NULL, NULL, NULL);

-- 3. Document conversion rules
CREATE TABLE document_conversion_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_document_type VARCHAR(20) NOT NULL,
  to_document_type VARCHAR(20) NOT NULL,
  conversion_trigger VARCHAR(50) NOT NULL, -- 'MANUAL', 'AUTO_APPROVED', 'STOCK_UNAVAILABLE'
  requires_approval BOOLEAN DEFAULT false,
  approval_level INTEGER DEFAULT 1,
  conditions JSONB,
  is_active BOOLEAN DEFAULT true
);

INSERT INTO document_conversion_rules (from_document_type, to_document_type, conversion_trigger, requires_approval, conditions) VALUES
-- MR to PR conversions
('MATERIAL_REQ', 'PURCHASE_REQ', 'STOCK_UNAVAILABLE', true, '{"check_inventory": true, "min_stock_level": 0}'),
('MATERIAL_REQ', 'PURCHASE_REQ', 'MANUAL', true, '{"user_initiated": true}'),

-- PR to PO conversions  
('PURCHASE_REQ', 'PURCHASE_ORDER', 'AUTO_APPROVED', false, '{"pr_status": "APPROVED", "vendor_selected": true}'),
('PURCHASE_REQ', 'PURCHASE_ORDER', 'MANUAL', true, '{"user_initiated": true, "vendor_required": true}');

-- 4. Approval level comparison by document type
SELECT 'APPROVAL LEVEL COMPARISON BY DOCUMENT TYPE:' as info;

SELECT 
  'MATERIAL REQUEST (MR)' as document_type,
  'Internal request - Low approval requirements' as characteristics,
  'Supervisor → Department Head' as typical_flow,
  '$5K → $25K' as amount_thresholds;

SELECT 
  'PURCHASE REQUISITION (PR)' as document_type,
  'Budget impact - Medium approval requirements' as characteristics,
  'Dept Head → Procurement Mgr → Finance Mgr' as typical_flow,
  '$10K → $50K → $200K' as amount_thresholds;

SELECT 
  'PURCHASE ORDER (PO)' as document_type,
  'Legal commitment - High approval requirements' as characteristics,
  'Procurement Mgr → Finance Mgr → CFO' as typical_flow,
  '$25K → $100K → $500K' as amount_thresholds;

SELECT 
  'RESERVATION' as document_type,
  'Inventory allocation - Minimal approval' as characteristics,
  'Project Engineer → Project Manager' as typical_flow,
  '$50K → $200K' as amount_thresholds;

-- 5. Document workflow states by type
CREATE TABLE document_workflow_states (
  document_type VARCHAR(20) NOT NULL,
  state_code VARCHAR(20) NOT NULL,
  state_name VARCHAR(100) NOT NULL,
  description TEXT,
  is_final_state BOOLEAN DEFAULT false,
  next_possible_states TEXT[], -- Array of possible next states
  PRIMARY KEY (document_type, state_code)
);

INSERT INTO document_workflow_states VALUES
-- Material Request states
('MATERIAL_REQ', 'DRAFT', 'Draft', 'Being prepared by requestor', false, '{"SUBMITTED"}'),
('MATERIAL_REQ', 'SUBMITTED', 'Submitted', 'Submitted for approval', false, '{"APPROVED", "REJECTED"}'),
('MATERIAL_REQ', 'APPROVED', 'Approved', 'Approved for fulfillment', false, '{"FULFILLED", "CONVERTED", "CANCELLED"}'),
('MATERIAL_REQ', 'FULFILLED', 'Fulfilled', 'Materials provided from inventory', true, '{}'),
('MATERIAL_REQ', 'CONVERTED', 'Converted to PR', 'Converted to Purchase Requisition', true, '{}'),
('MATERIAL_REQ', 'REJECTED', 'Rejected', 'Request rejected', true, '{}'),
('MATERIAL_REQ', 'CANCELLED', 'Cancelled', 'Cancelled by requestor', true, '{}'),

-- Purchase Requisition states
('PURCHASE_REQ', 'DRAFT', 'Draft', 'Being prepared', false, '{"SUBMITTED"}'),
('PURCHASE_REQ', 'SUBMITTED', 'Submitted', 'Submitted for approval', false, '{"APPROVED", "REJECTED"}'),
('PURCHASE_REQ', 'APPROVED', 'Approved', 'Approved for procurement', false, '{"VENDOR_SELECTION", "CONVERTED"}'),
('PURCHASE_REQ', 'VENDOR_SELECTION', 'Vendor Selection', 'Selecting vendor/getting quotes', false, '{"CONVERTED", "CANCELLED"}'),
('PURCHASE_REQ', 'CONVERTED', 'Converted to PO', 'Converted to Purchase Order', true, '{}'),
('PURCHASE_REQ', 'REJECTED', 'Rejected', 'Requisition rejected', true, '{}'),
('PURCHASE_REQ', 'CANCELLED', 'Cancelled', 'Cancelled before conversion', true, '{}'),

-- Purchase Order states
('PURCHASE_ORDER', 'DRAFT', 'Draft', 'Being prepared', false, '{"SUBMITTED"}'),
('PURCHASE_ORDER', 'SUBMITTED', 'Submitted', 'Submitted for approval', false, '{"APPROVED", "REJECTED"}'),
('PURCHASE_ORDER', 'APPROVED', 'Approved', 'Approved and sent to vendor', false, '{"ACKNOWLEDGED", "DELIVERED", "CANCELLED"}'),
('PURCHASE_ORDER', 'ACKNOWLEDGED', 'Acknowledged', 'Acknowledged by vendor', false, '{"DELIVERED", "CANCELLED"}'),
('PURCHASE_ORDER', 'DELIVERED', 'Delivered', 'Goods/services delivered', false, '{"INVOICED", "COMPLETED"}'),
('PURCHASE_ORDER', 'INVOICED', 'Invoiced', 'Invoice received', false, '{"PAID", "COMPLETED"}'),
('PURCHASE_ORDER', 'PAID', 'Paid', 'Payment completed', true, '{}'),
('PURCHASE_ORDER', 'COMPLETED', 'Completed', 'PO fully completed', true, '{}'),
('PURCHASE_ORDER', 'REJECTED', 'Rejected', 'PO rejected', true, '{}'),
('PURCHASE_ORDER', 'CANCELLED', 'Cancelled', 'PO cancelled', true, '{}'),

-- Reservation states
('RESERVATION', 'DRAFT', 'Draft', 'Being prepared', false, '{"SUBMITTED"}'),
('RESERVATION', 'SUBMITTED', 'Submitted', 'Submitted for approval', false, '{"APPROVED", "REJECTED"}'),
('RESERVATION', 'APPROVED', 'Approved', 'Materials reserved', false, '{"FULFILLED", "EXPIRED", "CANCELLED"}'),
('RESERVATION', 'FULFILLED', 'Fulfilled', 'Materials issued against reservation', true, '{}'),
('RESERVATION', 'EXPIRED', 'Expired', 'Reservation expired unused', true, '{}'),
('RESERVATION', 'REJECTED', 'Rejected', 'Reservation rejected', true, '{}'),
('RESERVATION', 'CANCELLED', 'Cancelled', 'Reservation cancelled', true, '{}');

-- 6. Summary of key differences
SELECT 'KEY DIFFERENCES BETWEEN MR/PR/PO:' as info;

SELECT 
  document_type,
  document_name,
  CASE WHEN is_internal THEN 'Internal' ELSE 'External' END as scope,
  CASE WHEN requires_vendor THEN 'Yes' ELSE 'No' END as vendor_required,
  CASE WHEN creates_financial_commitment THEN 'Yes' ELSE 'No' END as financial_commitment,
  can_convert_to as converts_to,
  default_approval_levels as approval_levels
FROM document_type_config
ORDER BY 
  CASE document_type 
    WHEN 'MATERIAL_REQ' THEN 1 
    WHEN 'PURCHASE_REQ' THEN 2 
    WHEN 'PURCHASE_ORDER' THEN 3 
    WHEN 'RESERVATION' THEN 4 
  END;

COMMENT ON TABLE document_type_config IS 'Configuration and characteristics of different document types (MR/PR/PO/Reservation)';
COMMENT ON TABLE document_conversion_rules IS 'Rules for converting between document types (MR→PR→PO)';
COMMENT ON TABLE document_workflow_states IS 'Document-specific workflow states and transitions';