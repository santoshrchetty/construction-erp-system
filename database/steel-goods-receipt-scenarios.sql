-- Steel Goods Receipt - 3 Scenarios with GL Determination
-- Scenario 1: Internal Consumption, Scenario 2: Project Receipt, Scenario 3: Asset Receipt

-- Setup GL Rules for Steel Goods Receipt Scenarios
INSERT INTO construction_gl_determination (
  company_code, movement_type, account_key, business_process, project_category,
  valuation_class, material_group, gst_classification, hsn_sac_code, gst_rate,
  balance_sheet_category, pnl_category,
  debit_account, credit_account, posting_key,
  cost_center_derivation, wbs_element_derivation,
  rule_description
) VALUES 

-- Scenario 1: Steel Receipt for Internal Consumption (Warehouse Stock)
('C001', 'C101', 'BSX', 'PROCURE_TO_PAY', 'GENERAL', 
 'RAW_MATERIAL', 'STEEL', 'GOODS', '7214', 18.00,
 'CURRENT_ASSETS', 'DIRECT_EXPENSES',
 '130200', '210100', '89',
 'WAREHOUSE', 'COST_CENTER',
 'Steel receipt to warehouse for internal consumption'),

-- Scenario 2: Steel Receipt Against Project (Direct to Project)
('C001', 'C111', 'BSX', 'PROJECT_EXECUTION', 'BUILDING',
 'RAW_MATERIAL', 'STEEL', 'GOODS', '7214', 18.00,
 'CURRENT_ASSETS', 'DIRECT_EXPENSES', 
 '140100', '210100', '89',
 'PROJECT', 'PROJECT_WBS',
 'Steel receipt directly to project WIP'),

-- Scenario 3: Steel Receipt for Asset Construction (Capital WIP)
('C001', 'C121', 'AKS', 'ASSET_CONSTRUCTION', 'INFRASTRUCTURE',
 'CAPITAL_GOODS', 'STEEL_STRUCTURAL', 'CAPITAL_GOODS', '7308', 18.00,
 'FIXED_ASSETS', 'CAPITAL_EXPENDITURE',
 '151000', '210100', '70', 
 'ASSET', 'ASSET_WBS',
 'Steel receipt for asset under construction');

-- GL Account Master for Steel Scenarios
INSERT INTO gl_account_master (
  account_code, account_name, account_type,
  bs_classification, bs_sub_classification,
  schedule_iii_mapping, company_code
) VALUES
('130200', 'Steel Inventory - Raw Material', 'ASSET', 
 'CURRENT_ASSETS', 'INVENTORIES', 
 'Raw Materials', 'C001'),
('140100', 'WIP - Direct Material (Steel)', 'ASSET',
 'CURRENT_ASSETS', 'INVENTORIES',
 'Work-in-Progress', 'C001'),
('151000', 'Capital WIP - Steel Structure', 'ASSET',
 'FIXED_ASSETS', 'CAPITAL_WORK_IN_PROGRESS',
 'Capital Work-in-Progress', 'C001'),
('210100', 'Trade Payables - Steel Suppliers', 'LIABILITY',
 'CURRENT_LIABILITIES', 'TRADE_PAYABLES',
 'Trade Payables', 'C001');

-- SCENARIO 1: Steel Receipt for Internal Consumption
-- Business Transaction: 10 MT steel received at warehouse for general use
-- Amount: ₹8,00,000 + GST ₹1,44,000 = ₹9,44,000

SELECT 'SCENARIO 1: Steel Receipt for Internal Consumption' as scenario;

SELECT * FROM get_compliance_gl_accounts(
  'C001',           -- company_code
  'C101',           -- movement_type (goods receipt to warehouse)
  'RAW_MATERIAL',   -- valuation_class
  'GENERAL',        -- project_category
  'PROCURE_TO_PAY'  -- business_process
);

-- Journal Entry for Scenario 1:
SELECT 
  'Dr' as entry_type,
  '130200' as account_code,
  'Steel Inventory - Raw Material' as account_name,
  800000.00 as amount,
  'Material Cost' as narration
UNION ALL
SELECT 
  'Dr' as entry_type,
  '170100' as account_code,
  'Input GST Receivable' as account_name,
  144000.00 as amount,
  'GST Input Credit @ 18%' as narration
UNION ALL
SELECT 
  'Cr' as entry_type,
  '210100' as account_code,
  'Trade Payables - Steel Suppliers' as account_name,
  944000.00 as amount,
  'Steel supplier payable including GST' as narration;

-- SCENARIO 2: Steel Receipt Against Project
-- Business Transaction: 15 MT steel received directly for Building Project Alpha
-- Amount: ₹12,00,000 + GST ₹2,16,000 = ₹14,16,000

SELECT 'SCENARIO 2: Steel Receipt Against Project' as scenario;

SELECT * FROM get_compliance_gl_accounts(
  'C001',             -- company_code
  'C111',             -- movement_type (goods receipt to project)
  'RAW_MATERIAL',     -- valuation_class
  'BUILDING',         -- project_category
  'PROJECT_EXECUTION' -- business_process
);

-- Journal Entry for Scenario 2:
SELECT 
  'Dr' as entry_type,
  '140100' as account_code,
  'WIP - Direct Material (Steel)' as account_name,
  1200000.00 as amount,
  'Steel direct to Project Alpha - WBS: ALPHA-STRUCTURE-001' as narration
UNION ALL
SELECT 
  'Dr' as entry_type,
  '170100' as account_code,
  'Input GST Receivable' as account_name,
  216000.00 as amount,
  'GST Input Credit @ 18%' as narration
UNION ALL
SELECT 
  'Cr' as entry_type,
  '210100' as account_code,
  'Trade Payables - Steel Suppliers' as account_name,
  1416000.00 as amount,
  'Steel supplier payable for Project Alpha' as narration;

-- SCENARIO 3: Steel Receipt for Asset Construction
-- Business Transaction: 20 MT structural steel for constructing company warehouse
-- Amount: ₹16,00,000 + GST ₹2,88,000 = ₹18,88,000

SELECT 'SCENARIO 3: Steel Receipt for Asset Construction' as scenario;

SELECT * FROM get_compliance_gl_accounts(
  'C001',               -- company_code
  'C121',               -- movement_type (goods receipt for asset)
  'CAPITAL_GOODS',      -- valuation_class
  'INFRASTRUCTURE',     -- project_category
  'ASSET_CONSTRUCTION'  -- business_process
);

-- Journal Entry for Scenario 3:
SELECT 
  'Dr' as entry_type,
  '151000' as account_code,
  'Capital WIP - Steel Structure' as account_name,
  1600000.00 as amount,
  'Structural steel for warehouse construction - Asset: WH-MUM-001' as narration
UNION ALL
SELECT 
  'Dr' as entry_type,
  '170200' as account_code,
  'Input GST on Capital Goods' as account_name,
  288000.00 as amount,
  'GST Input Credit @ 18% (Restricted for Capital Goods)' as narration
UNION ALL
SELECT 
  'Cr' as entry_type,
  '210100' as account_code,
  'Trade Payables - Steel Suppliers' as account_name,
  1888000.00 as amount,
  'Steel supplier payable for asset construction' as narration;

-- Compliance Impact Summary
SELECT 
  'Balance Sheet Impact' as report_type,
  'Current Assets - Inventories' as line_item,
  'Raw Materials: ₹8,00,000' as scenario_1,
  'Work-in-Progress: ₹12,00,000' as scenario_2,
  'Fixed Assets - CWIP: ₹16,00,000' as scenario_3
UNION ALL
SELECT 
  'P&L Impact',
  'Direct Expenses',
  'None (Asset created)',
  'None (WIP created)', 
  'None (Capital Asset)'
UNION ALL
SELECT 
  'GST Impact',
  'Input Tax Credit',
  'Immediate Credit: ₹1,44,000',
  'Immediate Credit: ₹2,16,000',
  'Restricted Credit: ₹2,88,000'
UNION ALL
SELECT 
  'Cash Flow Impact',
  'Operating Activities',
  'Operating Outflow: ₹9,44,000',
  'Operating Outflow: ₹14,16,000',
  'Investing Outflow: ₹18,88,000';

-- Regulatory Compliance Check
SELECT 
  'AS-2 Inventory Valuation' as standard,
  'Raw materials at cost' as scenario_1_compliance,
  'WIP at cost including direct materials' as scenario_2_compliance,
  'Capital WIP at cost' as scenario_3_compliance
UNION ALL
SELECT 
  'GST Law Compliance',
  'HSN 7214 - 18% GST applicable',
  'HSN 7214 - 18% GST applicable', 
  'HSN 7308 - 18% GST, Input credit restricted'
UNION ALL
SELECT 
  'Schedule III Presentation',
  'Current Assets > Inventories > Raw Materials',
  'Current Assets > Inventories > Work-in-Progress',
  'Fixed Assets > Capital Work-in-Progress';