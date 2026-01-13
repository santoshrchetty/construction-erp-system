-- Traditional Mode: Customer-Configurable Document Types
-- Customers can enable/disable MR, PR, PO based on their business processes

-- 1. Customer document type preferences
CREATE TABLE customer_document_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  
  -- Document type enablement
  enable_material_requests BOOLEAN DEFAULT true,
  enable_purchase_requisitions BOOLEAN DEFAULT true,
  enable_purchase_orders BOOLEAN DEFAULT false, -- Usually handled by ERP
  enable_reservations BOOLEAN DEFAULT true,
  
  -- Document flow configuration
  mr_to_pr_conversion BOOLEAN DEFAULT true,
  pr_to_po_conversion BOOLEAN DEFAULT false, -- Usually ERP handles this
  auto_conversion_enabled BOOLEAN DEFAULT false,
  
  -- Traditional mode settings per document type
  mr_approval_levels INTEGER DEFAULT 2,
  pr_approval_levels INTEGER DEFAULT 3,
  po_approval_levels INTEGER DEFAULT 4,
  
  -- Simple thresholds (traditional approach)
  mr_supervisor_limit DECIMAL(15,2) DEFAULT 5000,
  mr_manager_limit DECIMAL(15,2) DEFAULT 25000,
  
  pr_dept_head_limit DECIMAL(15,2) DEFAULT 10000,
  pr_procurement_limit DECIMAL(15,2) DEFAULT 50000,
  pr_finance_limit DECIMAL(15,2) DEFAULT 200000,
  
  po_procurement_limit DECIMAL(15,2) DEFAULT 25000,
  po_finance_limit DECIMAL(15,2) DEFAULT 100000,
  po_executive_limit DECIMAL(15,2) DEFAULT 500000,
  
  -- Integration settings
  erp_system VARCHAR(50), -- SAP, ORACLE, DYNAMICS, NETSUITE, CUSTOM
  erp_handles_po BOOLEAN DEFAULT true,
  erp_handles_pr BOOLEAN DEFAULT false,
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(customer_id)
);

-- 2. Document type templates by customer scenario
CREATE TABLE document_type_scenarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_name VARCHAR(100) NOT NULL,
  customer_type VARCHAR(50), -- SMALL, MEDIUM, LARGE
  erp_integration VARCHAR(50), -- NONE, BASIC, FULL
  description TEXT,
  
  -- Recommended document types
  recommended_documents JSONB,
  approval_structure JSONB,
  typical_thresholds JSONB,
  
  is_template BOOLEAN DEFAULT true
);

INSERT INTO document_type_scenarios VALUES
-- Scenario 1: Small company, no ERP
('Small Company - Manual Process', 'SMALL', 'NONE', 'Small construction company managing everything manually',
 '{"documents": ["MR", "PR"], "primary_flow": "MR → PR → Manual PO"}',
 '{"MR": {"levels": 2, "roles": ["Supervisor", "Manager"]}, "PR": {"levels": 2, "roles": ["Manager", "Owner"]}}',
 '{"MR": {"supervisor": 3000, "manager": 15000}, "PR": {"manager": 15000, "owner": 50000}}'),

-- Scenario 2: Medium company, basic ERP
('Medium Company - Basic ERP', 'MEDIUM', 'BASIC', 'Medium company with basic ERP for financials only',
 '{"documents": ["MR", "PR"], "primary_flow": "MR → PR → ERP handles PO"}',
 '{"MR": {"levels": 2, "roles": ["Supervisor", "Department Head"]}, "PR": {"levels": 3, "roles": ["Department Head", "Procurement", "Finance"]}}',
 '{"MR": {"supervisor": 5000, "dept_head": 25000}, "PR": {"dept_head": 10000, "procurement": 50000, "finance": 200000}}'),

-- Scenario 3: Large company, full ERP integration
('Large Company - Full ERP', 'LARGE', 'FULL', 'Large company with full ERP integration',
 '{"documents": ["MR"], "primary_flow": "MR → ERP handles PR/PO"}',
 '{"MR": {"levels": 3, "roles": ["Supervisor", "Manager", "Director"]}}',
 '{"MR": {"supervisor": 10000, "manager": 50000, "director": 200000}}'),

-- Scenario 4: Construction-specific workflow
('Construction Focused', 'MEDIUM', 'BASIC', 'Construction company with project-based workflow',
 '{"documents": ["MR", "RESERVATION"], "primary_flow": "Reservation → MR → Manual procurement"}',
 '{"MR": {"levels": 2, "roles": ["Site Supervisor", "Project Manager"]}, "RESERVATION": {"levels": 2, "roles": ["Foreman", "Site Manager"]}}',
 '{"MR": {"site_supervisor": 8000, "project_manager": 40000}, "RESERVATION": {"foreman": 15000, "site_manager": 75000}}'),

-- Scenario 5: Procurement-heavy company
('Procurement Focused', 'LARGE', 'BASIC', 'Company with dedicated procurement department',
 '{"documents": ["MR", "PR", "PO"], "primary_flow": "MR → PR → PO (all internal)"}',
 '{"MR": {"levels": 2, "roles": ["Requestor", "Department Head"]}, "PR": {"levels": 3, "roles": ["Department Head", "Procurement Manager", "Finance"]}, "PO": {"levels": 4, "roles": ["Procurement", "Finance", "General Manager", "CEO"]}}',
 '{"MR": {"requestor": 2000, "dept_head": 15000}, "PR": {"dept_head": 15000, "procurement": 75000, "finance": 300000}, "PO": {"procurement": 30000, "finance": 150000, "gm": 750000, "ceo": 2000000}}');

-- 3. Traditional workflow templates
CREATE TABLE traditional_workflow_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_name VARCHAR(100) NOT NULL,
  document_type VARCHAR(20) NOT NULL,
  workflow_steps JSONB NOT NULL,
  approval_matrix JSONB NOT NULL,
  is_active BOOLEAN DEFAULT true
);

INSERT INTO traditional_workflow_templates VALUES
-- MR Templates
('MR - 2 Level Simple', 'MATERIAL_REQ', 
 '{"steps": [{"step": 1, "action": "Create Request", "role": "REQUESTOR"}, {"step": 2, "action": "Supervisor Approval", "role": "SUPERVISOR"}, {"step": 3, "action": "Manager Approval", "role": "MANAGER"}, {"step": 4, "action": "Fulfill/Convert", "role": "SYSTEM"}]}',
 '{"level_1": {"role": "SUPERVISOR", "limit": 5000}, "level_2": {"role": "MANAGER", "limit": 25000}}'),

('MR - 3 Level Standard', 'MATERIAL_REQ',
 '{"steps": [{"step": 1, "action": "Create Request", "role": "REQUESTOR"}, {"step": 2, "action": "Supervisor Approval", "role": "SUPERVISOR"}, {"step": 3, "action": "Manager Approval", "role": "MANAGER"}, {"step": 4, "action": "Director Approval", "role": "DIRECTOR"}, {"step": 5, "action": "Fulfill/Convert", "role": "SYSTEM"}]}',
 '{"level_1": {"role": "SUPERVISOR", "limit": 5000}, "level_2": {"role": "MANAGER", "limit": 25000}, "level_3": {"role": "DIRECTOR", "limit": 100000}}'),

-- PR Templates  
('PR - 2 Level Basic', 'PURCHASE_REQ',
 '{"steps": [{"step": 1, "action": "Create PR", "role": "REQUESTOR"}, {"step": 2, "action": "Department Head Approval", "role": "DEPT_HEAD"}, {"step": 3, "action": "Manager Approval", "role": "MANAGER"}, {"step": 4, "action": "Send to Procurement", "role": "SYSTEM"}]}',
 '{"level_1": {"role": "DEPT_HEAD", "limit": 10000}, "level_2": {"role": "MANAGER", "limit": 50000}}'),

('PR - 3 Level Standard', 'PURCHASE_REQ',
 '{"steps": [{"step": 1, "action": "Create PR", "role": "REQUESTOR"}, {"step": 2, "action": "Department Head Approval", "role": "DEPT_HEAD"}, {"step": 3, "action": "Procurement Review", "role": "PROCUREMENT"}, {"step": 4, "action": "Finance Approval", "role": "FINANCE"}, {"step": 5, "action": "Convert to PO", "role": "SYSTEM"}]}',
 '{"level_1": {"role": "DEPT_HEAD", "limit": 10000}, "level_2": {"role": "PROCUREMENT", "limit": 50000}, "level_3": {"role": "FINANCE", "limit": 200000}}'),

-- PO Templates
('PO - 3 Level Standard', 'PURCHASE_ORDER',
 '{"steps": [{"step": 1, "action": "Create PO", "role": "PROCUREMENT"}, {"step": 2, "action": "Finance Review", "role": "FINANCE"}, {"step": 3, "action": "Manager Approval", "role": "MANAGER"}, {"step": 4, "action": "Send to Vendor", "role": "SYSTEM"}]}',
 '{"level_1": {"role": "FINANCE", "limit": 25000}, "level_2": {"role": "MANAGER", "limit": 100000}, "level_3": {"role": "DIRECTOR", "limit": 500000}}');

-- 4. Customer onboarding wizard
CREATE OR REPLACE FUNCTION setup_traditional_mode(
  p_customer_id UUID,
  p_company_size VARCHAR(20),
  p_erp_integration VARCHAR(20),
  p_primary_business VARCHAR(50)
) RETURNS JSONB AS $$
DECLARE
  v_config JSONB;
  v_scenario RECORD;
BEGIN
  -- Find matching scenario
  SELECT * INTO v_scenario 
  FROM document_type_scenarios 
  WHERE customer_type = p_company_size 
    AND erp_integration = p_erp_integration
  LIMIT 1;
  
  -- Create default configuration
  INSERT INTO customer_document_preferences (
    customer_id,
    enable_material_requests,
    enable_purchase_requisitions, 
    enable_purchase_orders,
    enable_reservations,
    erp_system,
    erp_handles_po,
    mr_supervisor_limit,
    mr_manager_limit,
    pr_dept_head_limit,
    pr_procurement_limit,
    pr_finance_limit
  ) VALUES (
    p_customer_id,
    (v_scenario.recommended_documents->>'documents')::JSONB ? 'MR',
    (v_scenario.recommended_documents->>'documents')::JSONB ? 'PR', 
    (v_scenario.recommended_documents->>'documents')::JSONB ? 'PO',
    (v_scenario.recommended_documents->>'documents')::JSONB ? 'RESERVATION',
    CASE p_erp_integration WHEN 'FULL' THEN 'SAP' WHEN 'BASIC' THEN 'QUICKBOOKS' ELSE 'NONE' END,
    p_erp_integration = 'FULL',
    (v_scenario.typical_thresholds->'MR'->>'supervisor')::DECIMAL,
    (v_scenario.typical_thresholds->'MR'->>'manager')::DECIMAL,
    (v_scenario.typical_thresholds->'PR'->>'dept_head')::DECIMAL,
    (v_scenario.typical_thresholds->'PR'->>'procurement')::DECIMAL,
    (v_scenario.typical_thresholds->'PR'->>'finance')::DECIMAL
  );
  
  -- Return configuration summary
  v_config := jsonb_build_object(
    'scenario', v_scenario.scenario_name,
    'documents_enabled', v_scenario.recommended_documents,
    'approval_structure', v_scenario.approval_structure,
    'thresholds', v_scenario.typical_thresholds
  );
  
  RETURN v_config;
END;
$$ LANGUAGE plpgsql;

-- 5. Document type routing logic
CREATE OR REPLACE FUNCTION get_enabled_document_types(p_customer_id UUID)
RETURNS TABLE (
  document_type VARCHAR(20),
  is_enabled BOOLEAN,
  approval_levels INTEGER,
  max_amount DECIMAL(15,2)
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    'MATERIAL_REQ'::VARCHAR(20),
    cdp.enable_material_requests,
    cdp.mr_approval_levels,
    cdp.mr_manager_limit
  FROM customer_document_preferences cdp
  WHERE cdp.customer_id = p_customer_id
  
  UNION ALL
  
  SELECT 
    'PURCHASE_REQ'::VARCHAR(20),
    cdp.enable_purchase_requisitions,
    cdp.pr_approval_levels,
    cdp.pr_finance_limit
  FROM customer_document_preferences cdp
  WHERE cdp.customer_id = p_customer_id
  
  UNION ALL
  
  SELECT 
    'PURCHASE_ORDER'::VARCHAR(20),
    cdp.enable_purchase_orders,
    cdp.po_approval_levels,
    cdp.po_executive_limit
  FROM customer_document_preferences cdp
  WHERE cdp.customer_id = p_customer_id
  
  UNION ALL
  
  SELECT 
    'RESERVATION'::VARCHAR(20),
    cdp.enable_reservations,
    2, -- Default 2 levels for reservations
    50000::DECIMAL(15,2) -- Default limit
  FROM customer_document_preferences cdp
  WHERE cdp.customer_id = p_customer_id;
END;
$$ LANGUAGE plpgsql;

-- 6. Sample customer setups
SELECT 'SETTING UP SAMPLE CUSTOMERS:' as info;

-- Small company setup
SELECT setup_traditional_mode(
  '550e8400-e29b-41d4-a716-446655440001'::UUID,
  'SMALL',
  'NONE', 
  'RESIDENTIAL_CONSTRUCTION'
) as small_company_config;

-- Medium company setup  
SELECT setup_traditional_mode(
  '550e8400-e29b-41d4-a716-446655440002'::UUID,
  'MEDIUM',
  'BASIC',
  'COMMERCIAL_CONSTRUCTION'
) as medium_company_config;

-- Large company setup
SELECT setup_traditional_mode(
  '550e8400-e29b-41d4-a716-446655440003'::UUID,
  'LARGE', 
  'FULL',
  'INFRASTRUCTURE'
) as large_company_config;

-- 7. Configuration summary view
CREATE VIEW customer_traditional_config_summary AS
SELECT 
  cdp.customer_id,
  
  -- Enabled document types
  CASE WHEN cdp.enable_material_requests THEN 'MR' ELSE '' END ||
  CASE WHEN cdp.enable_purchase_requisitions THEN ', PR' ELSE '' END ||
  CASE WHEN cdp.enable_purchase_orders THEN ', PO' ELSE '' END ||
  CASE WHEN cdp.enable_reservations THEN ', RES' ELSE '' END as enabled_documents,
  
  -- Document flow
  CASE 
    WHEN cdp.mr_to_pr_conversion AND cdp.pr_to_po_conversion THEN 'MR → PR → PO'
    WHEN cdp.mr_to_pr_conversion THEN 'MR → PR → ERP'
    WHEN cdp.enable_material_requests ONLY THEN 'MR → Manual'
    ELSE 'Custom Flow'
  END as document_flow,
  
  -- ERP integration
  cdp.erp_system,
  CASE WHEN cdp.erp_handles_po THEN 'ERP handles PO' ELSE 'Internal PO' END as po_handling,
  
  -- Approval complexity
  (cdp.mr_approval_levels + cdp.pr_approval_levels + cdp.po_approval_levels) as total_approval_levels,
  
  cdp.created_at
FROM customer_document_preferences cdp
WHERE cdp.is_active = true;

-- Display sample configurations
SELECT * FROM customer_traditional_config_summary;

COMMENT ON TABLE customer_document_preferences IS 'Customer-specific preferences for which document types (MR/PR/PO) to enable in traditional mode';
COMMENT ON TABLE document_type_scenarios IS 'Pre-defined scenarios for different customer types and ERP integration levels';
COMMENT ON FUNCTION setup_traditional_mode IS 'Automated setup wizard for traditional mode based on customer characteristics';