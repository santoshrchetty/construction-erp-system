-- Compliance-Driven GL Determination Framework
-- Supports Indian Accounting Standards, GST, and Construction Industry Requirements

-- Enhanced GL Determination Table
CREATE TABLE IF NOT EXISTS construction_gl_determination (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Multi-company isolation
  company_code VARCHAR(10) NOT NULL,
  
  -- Transaction Classification (SAP-inspired)
  movement_type VARCHAR(10) NOT NULL,  -- C101, C201, etc.
  account_key VARCHAR(10) NOT NULL,    -- BSX, GBB, etc.
  
  -- Business Context (Workday-inspired)
  business_process VARCHAR(50) NOT NULL, -- PROCURE_TO_PAY, PROJECT_EXECUTION
  project_category VARCHAR(20) NOT NULL, -- BUILDING, INFRASTRUCTURE
  
  -- Compliance Dimensions (Regulatory-driven)
  valuation_class VARCHAR(20) NOT NULL,  -- RAW_MATERIAL, CONSUMABLE, CAPITAL_GOODS
  material_group VARCHAR(20),            -- CEMENT, STEEL, EQUIPMENT
  asset_class VARCHAR(20),               -- CONSTRUCTION_EQUIPMENT, VEHICLES
  
  -- GST Compliance
  gst_classification VARCHAR(20),        -- GOODS, SERVICES, CAPITAL_GOODS
  hsn_sac_code VARCHAR(10),             -- HSN/SAC code for GST
  gst_rate DECIMAL(5,2),                -- 0, 5, 12, 18, 28
  
  -- Financial Statement Mapping
  balance_sheet_category VARCHAR(30),    -- CURRENT_ASSETS, FIXED_ASSETS, CURRENT_LIABILITIES
  pnl_category VARCHAR(30),             -- DIRECT_EXPENSES, INDIRECT_EXPENSES, REVENUE
  
  -- Account Determination Results
  debit_account VARCHAR(20) NOT NULL,
  credit_account VARCHAR(20) NOT NULL,
  posting_key VARCHAR(10) NOT NULL,
  
  -- Dimensional Analysis
  cost_center_derivation VARCHAR(50),   -- PROJECT, PLANT, DEPARTMENT
  profit_center_derivation VARCHAR(50), -- BUSINESS_UNIT, PROJECT_TYPE
  wbs_element_derivation VARCHAR(50),   -- PROJECT_WBS, ACTIVITY_WBS
  
  -- Rule Management
  rule_priority INTEGER DEFAULT 100,
  effective_date DATE DEFAULT CURRENT_DATE,
  expiry_date DATE,
  rule_description TEXT,
  
  -- Audit & Control
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(50),
  
  -- Constraints
  UNIQUE(company_code, movement_type, account_key, valuation_class, business_process, project_category)
);

-- Compliance-Driven GL Account Structure
CREATE TABLE IF NOT EXISTS gl_account_master (
  account_code VARCHAR(20) PRIMARY KEY,
  account_name VARCHAR(100) NOT NULL,
  account_type VARCHAR(30) NOT NULL, -- ASSET, LIABILITY, INCOME, EXPENSE
  
  -- Balance Sheet Classification (AS-1 compliant)
  bs_classification VARCHAR(50), -- CURRENT_ASSETS, FIXED_ASSETS, CURRENT_LIABILITIES, etc.
  bs_sub_classification VARCHAR(50), -- INVENTORIES, TRADE_RECEIVABLES, etc.
  
  -- P&L Classification (AS-1 compliant)
  pnl_classification VARCHAR(50), -- DIRECT_EXPENSES, INDIRECT_EXPENSES, OTHER_INCOME
  
  -- GST Compliance
  gst_applicable BOOLEAN DEFAULT false,
  input_credit_eligible BOOLEAN DEFAULT false,
  
  -- Regulatory Reporting
  schedule_iii_mapping VARCHAR(50), -- Companies Act Schedule III mapping
  cash_flow_classification VARCHAR(30), -- OPERATING, INVESTING, FINANCING
  
  -- Control Accounts
  is_control_account BOOLEAN DEFAULT false,
  reconciliation_required BOOLEAN DEFAULT false,
  
  company_code VARCHAR(10) NOT NULL,
  is_active BOOLEAN DEFAULT true
);

-- Valuation Class Master (Compliance-driven)
CREATE TABLE IF NOT EXISTS valuation_class_master (
  valuation_class VARCHAR(20) PRIMARY KEY,
  class_description VARCHAR(100) NOT NULL,
  
  -- Financial Statement Impact
  balance_sheet_line_item VARCHAR(50), -- Raw Materials, WIP, Finished Goods
  pnl_impact VARCHAR(30), -- DIRECT_COST, INDIRECT_COST, CAPITAL_EXPENDITURE
  
  -- GST Classification
  gst_category VARCHAR(20), -- GOODS, SERVICES, CAPITAL_GOODS
  default_gst_rate DECIMAL(5,2),
  input_credit_category VARCHAR(20), -- IMMEDIATE, RESTRICTED, BLOCKED
  
  -- Depreciation (for assets)
  depreciation_applicable BOOLEAN DEFAULT false,
  depreciation_rate DECIMAL(5,2),
  depreciation_method VARCHAR(20), -- SLM, WDV
  
  -- Inventory Valuation
  valuation_method VARCHAR(20), -- FIFO, WEIGHTED_AVERAGE, STANDARD_COST
  
  company_code VARCHAR(10) NOT NULL,
  is_active BOOLEAN DEFAULT true
);

-- Sample Compliance-Driven GL Rules
INSERT INTO construction_gl_determination (
  company_code, movement_type, account_key, business_process, project_category,
  valuation_class, material_group, gst_classification, hsn_sac_code, gst_rate,
  balance_sheet_category, pnl_category,
  debit_account, credit_account, posting_key,
  cost_center_derivation, wbs_element_derivation,
  rule_description
) VALUES 
-- Raw Material Receipt (AS-2 compliant)
('C001', 'C101', 'BSX', 'PROCURE_TO_PAY', 'BUILDING', 
 'RAW_MATERIAL', 'CEMENT', 'GOODS', '2523', 18.00,
 'CURRENT_ASSETS', 'DIRECT_EXPENSES',
 '130100', '210100', '89',
 'WAREHOUSE', 'PROJECT_WBS',
 'Raw material receipt - Cement inventory'),

-- Capital Goods Receipt (GST Input Credit restricted)
('C001', 'C102', 'AKS', 'PROCURE_TO_PAY', 'BUILDING',
 'CAPITAL_GOODS', 'CONSTRUCTION_EQUIPMENT', 'CAPITAL_GOODS', '8426', 18.00,
 'FIXED_ASSETS', 'CAPITAL_EXPENDITURE', 
 '150100', '210100', '70',
 'PLANT', 'ASSET_WBS',
 'Capital goods receipt - Construction equipment'),

-- Material Issue to Project (AS-7 Construction Contract)
('C001', 'C201', 'BSX', 'PROJECT_EXECUTION', 'BUILDING',
 'RAW_MATERIAL', 'CEMENT', 'GOODS', '2523', 0.00,
 'CURRENT_ASSETS', 'DIRECT_EXPENSES',
 '140100', '130100', '89',
 'PROJECT', 'PROJECT_WBS',
 'Material issue to WIP - Direct material cost'),

-- Labor Cost Posting (Payroll compliance)
('C001', 'C301', 'LAB', 'PROJECT_EXECUTION', 'BUILDING',
 'SERVICES', 'DIRECT_LABOR', 'SERVICES', '9954', 0.00,
 'CURRENT_ASSETS', 'DIRECT_EXPENSES',
 '140200', '200100', '25',
 'PROJECT', 'PROJECT_WBS',
 'Direct labor cost to WIP'),

-- Subcontractor Services (GST on Services)
('C001', 'C501', 'SUB', 'PROJECT_EXECUTION', 'BUILDING',
 'SERVICES', 'SUBCONTRACTOR', 'SERVICES', '9954', 18.00,
 'CURRENT_ASSETS', 'DIRECT_EXPENSES',
 '140400', '210300', '31',
 'PROJECT', 'PROJECT_WBS',
 'Subcontractor services with GST');

-- GL Account Master (Schedule III compliant)
INSERT INTO gl_account_master (
  account_code, account_name, account_type,
  bs_classification, bs_sub_classification,
  pnl_classification, gst_applicable, input_credit_eligible,
  schedule_iii_mapping, cash_flow_classification,
  company_code
) VALUES
('130100', 'Raw Materials Inventory', 'ASSET', 
 'CURRENT_ASSETS', 'INVENTORIES', 
 NULL, true, true,
 'Raw Materials', 'OPERATING', 'C001'),

('140100', 'WIP - Material Cost', 'ASSET',
 'CURRENT_ASSETS', 'INVENTORIES',
 NULL, false, false,
 'Work-in-Progress', 'OPERATING', 'C001'),

('150100', 'Construction Equipment', 'ASSET',
 'FIXED_ASSETS', 'PROPERTY_PLANT_EQUIPMENT',
 NULL, true, false,
 'Plant and Equipment', 'INVESTING', 'C001'),

('210100', 'Trade Payables', 'LIABILITY',
 'CURRENT_LIABILITIES', 'TRADE_PAYABLES',
 NULL, false, false,
 'Trade Payables', 'OPERATING', 'C001');

-- Valuation Class Master (Regulatory compliant)
INSERT INTO valuation_class_master (
  valuation_class, class_description,
  balance_sheet_line_item, pnl_impact,
  gst_category, default_gst_rate, input_credit_category,
  valuation_method, company_code
) VALUES
('RAW_MATERIAL', 'Raw Materials for Construction',
 'Raw Materials', 'DIRECT_COST',
 'GOODS', 18.00, 'IMMEDIATE',
 'WEIGHTED_AVERAGE', 'C001'),

('CAPITAL_GOODS', 'Construction Equipment & Machinery',
 'Property, Plant & Equipment', 'CAPITAL_EXPENDITURE',
 'CAPITAL_GOODS', 18.00, 'RESTRICTED',
 'STANDARD_COST', 'C001'),

('CONSUMABLE', 'Consumable Materials & Supplies',
 'Stores and Spares', 'INDIRECT_COST',
 'GOODS', 18.00, 'IMMEDIATE',
 'FIFO', 'C001');

-- Compliance-Driven GL Determination Function
CREATE OR REPLACE FUNCTION get_compliance_gl_accounts(
  p_company_code VARCHAR(10),
  p_movement_type VARCHAR(10),
  p_valuation_class VARCHAR(20),
  p_project_category VARCHAR(20),
  p_business_process VARCHAR(50) DEFAULT 'PROJECT_EXECUTION'
) RETURNS TABLE (
  debit_account VARCHAR(20),
  credit_account VARCHAR(20),
  posting_key VARCHAR(10),
  gst_rate DECIMAL(5,2),
  hsn_sac_code VARCHAR(10),
  cost_center_derivation VARCHAR(50),
  wbs_element_derivation VARCHAR(50),
  balance_sheet_impact VARCHAR(30),
  pnl_impact VARCHAR(30)
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    cgd.debit_account,
    cgd.credit_account,
    cgd.posting_key,
    cgd.gst_rate,
    cgd.hsn_sac_code,
    cgd.cost_center_derivation,
    cgd.wbs_element_derivation,
    cgd.balance_sheet_category,
    cgd.pnl_category
  FROM construction_gl_determination cgd
  WHERE cgd.company_code = p_company_code
    AND cgd.movement_type = p_movement_type
    AND cgd.valuation_class = p_valuation_class
    AND cgd.project_category = p_project_category
    AND cgd.business_process = p_business_process
    AND cgd.is_active = true
    AND cgd.effective_date <= CURRENT_DATE
    AND (cgd.expiry_date IS NULL OR cgd.expiry_date > CURRENT_DATE)
  ORDER BY cgd.rule_priority
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Example Usage
-- SELECT * FROM get_compliance_gl_accounts('C001', 'C101', 'RAW_MATERIAL', 'BUILDING');