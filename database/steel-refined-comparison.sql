-- Steel Goods Receipt - Refined Comparison with Project Revenue vs Asset Distinction
-- Same Baseline: TMT Steel Bars, 10 MT @ ₹80,000/MT = ₹8,00,000 + GST ₹1,44,000

-- REFINED SCENARIO CLASSIFICATION
SELECT 
  'Scenario Classification' as aspect,
  'Scenario 1: Warehouse Stock' as scenario_1,
  'Scenario 2A: Revenue Project' as scenario_2a,
  'Scenario 2B: Asset Project' as scenario_2b,
  'Scenario 3: Direct Asset' as scenario_3

UNION ALL SELECT 'Business Purpose', 'General inventory', 'Customer project (Revenue)', 'Company asset project', 'Direct asset construction'
UNION ALL SELECT 'Final Outcome', 'Future consumption', 'Revenue generation', 'Company asset creation', 'Company asset creation'
UNION ALL SELECT 'Accounting Treatment', 'Inventory → COGS', 'WIP → Revenue', 'WIP → Fixed Asset', 'Direct to Fixed Asset'

-- ENHANCED GL DETERMINATION RULES
INSERT INTO construction_gl_determination (
  company_code, movement_type, account_key, business_process, project_category,
  valuation_class, material_group, gst_classification, hsn_sac_code, gst_rate,
  balance_sheet_category, pnl_category,
  debit_account, credit_account, posting_key,
  cost_center_derivation, wbs_element_derivation,
  rule_description
) VALUES 

-- Scenario 2A: Revenue-Generating Project (Customer Contract)
('C001', 'C111', 'BSX', 'PROJECT_EXECUTION', 'REVENUE_PROJECT',
 'RAW_MATERIAL', 'STEEL', 'GOODS', '7214', 18.00,
 'CURRENT_ASSETS', 'DIRECT_EXPENSES', 
 '141100', '210100', '89',
 'PROJECT', 'REVENUE_WBS',
 'Steel for revenue-generating customer project'),

-- Scenario 2B: Asset-Building Project (Internal Asset Creation)
('C001', 'C112', 'AKS', 'ASSET_PROJECT_EXECUTION', 'ASSET_PROJECT',
 'CAPITAL_GOODS', 'STEEL_STRUCTURAL', 'CAPITAL_GOODS', '7214', 18.00,
 'FIXED_ASSETS', 'CAPITAL_EXPENDITURE',
 '152100', '210100', '70', 
 'ASSET_PROJECT', 'ASSET_PROJECT_WBS',
 'Steel for internal asset construction project');

-- DETAILED COMPARISON WITH PROJECT DISTINCTION
SELECT 
  'Parameter' as comparison_aspect,
  'Warehouse Stock' as scenario_1,
  'Revenue Project' as scenario_2a,
  'Asset Project' as scenario_2b,
  'Direct Asset' as scenario_3

UNION ALL SELECT '--- BUSINESS CONTEXT ---', '---', '---', '---', '---'
UNION ALL SELECT 'Project Type', 'N/A', 'Customer Contract', 'Internal Asset Project', 'Direct Asset Purchase'
UNION ALL SELECT 'Revenue Generation', 'No', 'Yes (Customer billing)', 'No (Internal use)', 'No (Internal use)'
UNION ALL SELECT 'Asset Creation', 'No', 'No (Expense)', 'Yes (Company asset)', 'Yes (Company asset)'
UNION ALL SELECT 'Customer', 'N/A', 'External Customer', 'Internal (Company)', 'Internal (Company)'

UNION ALL SELECT '--- GL DETERMINATION ---', '---', '---', '---', '---'
UNION ALL SELECT 'Movement Type', 'C101', 'C111', 'C112', 'C121'
UNION ALL SELECT 'Valuation Class', 'RAW_MATERIAL', 'RAW_MATERIAL', 'CAPITAL_GOODS', 'CAPITAL_GOODS'
UNION ALL SELECT 'Business Process', 'PROCURE_TO_PAY', 'PROJECT_EXECUTION', 'ASSET_PROJECT_EXECUTION', 'ASSET_CONSTRUCTION'
UNION ALL SELECT 'Project Category', 'GENERAL', 'REVENUE_PROJECT', 'ASSET_PROJECT', 'INFRASTRUCTURE'

UNION ALL SELECT '--- JOURNAL ENTRIES ---', '---', '---', '---', '---'
UNION ALL SELECT 'Debit Account', '130200 (Inventory)', '141100 (Revenue WIP)', '152100 (Asset Project WIP)', '151000 (Capital WIP)'
UNION ALL SELECT 'Account Nature', 'Current Asset', 'Current Asset', 'Fixed Asset', 'Fixed Asset'
UNION ALL SELECT 'GST Account', '170100 (Immediate)', '170100 (Immediate)', '170200 (Restricted)', '170200 (Restricted)'

UNION ALL SELECT '--- FUTURE ACCOUNTING FLOW ---', '---', '---', '---', '---'
UNION ALL SELECT 'Next Step', 'Issue to projects', 'Revenue recognition', 'Asset capitalization', 'Asset capitalization'
UNION ALL SELECT 'P&L Impact', 'Material cost', 'Cost of sales', 'Depreciation', 'Depreciation'
UNION ALL SELECT 'Revenue Impact', 'None', 'Project revenue', 'None', 'None'
UNION ALL SELECT 'Asset Impact', 'None', 'None', 'Fixed asset increase', 'Fixed asset increase'

UNION ALL SELECT '--- COMPLIANCE DIFFERENCES ---', '---', '---', '---', '---'
UNION ALL SELECT 'Accounting Standard', 'AS-2 (Inventory)', 'AS-7 (Construction)', 'AS-10 (Fixed Assets)', 'AS-10 (Fixed Assets)'
UNION ALL SELECT 'Revenue Recognition', 'N/A', 'Percentage completion', 'N/A', 'N/A'
UNION ALL SELECT 'Asset Capitalization', 'N/A', 'N/A', 'On project completion', 'On asset completion'
UNION ALL SELECT 'Depreciation Start', 'N/A', 'N/A', 'When asset ready for use', 'When asset ready for use'

UNION ALL SELECT '--- TAX IMPLICATIONS ---', '---', '---', '---', '---'
UNION ALL SELECT 'GST Input Credit', 'Immediate', 'Immediate', 'Restricted (Capital)', 'Restricted (Capital)'
UNION ALL SELECT 'Income Tax', 'Closing stock', 'Project income/expense', 'Depreciation base', 'Depreciation base'
UNION ALL SELECT 'Transfer Pricing', 'N/A', 'Customer billing', 'Internal allocation', 'Internal allocation';

-- EXAMPLE JOURNAL ENTRIES FOR ALL SCENARIOS

-- Scenario 1: Warehouse Stock (Unchanged)
SELECT 'SCENARIO 1: WAREHOUSE STOCK' as scenario_title;
SELECT 'Dr  130200  Steel Inventory                 ₹8,00,000' as journal_entry
UNION ALL SELECT 'Dr  170100  Input GST Receivable          ₹1,44,000'
UNION ALL SELECT '    Cr  210100  Trade Payables             ₹9,44,000';

-- Scenario 2A: Revenue-Generating Project
SELECT 'SCENARIO 2A: REVENUE PROJECT (Customer Contract)' as scenario_title;
SELECT 'Dr  141100  WIP - Revenue Project Material  ₹8,00,000' as journal_entry
UNION ALL SELECT 'Dr  170100  Input GST Receivable          ₹1,44,000'
UNION ALL SELECT '    Cr  210100  Trade Payables             ₹9,44,000'
UNION ALL SELECT ''
UNION ALL SELECT '-- Future: Revenue Recognition --'
UNION ALL SELECT 'Dr  120100  Accounts Receivable          ₹15,00,000'
UNION ALL SELECT '    Cr  400100  Project Revenue            ₹15,00,000'
UNION ALL SELECT 'Dr  500100  Cost of Sales                ₹8,00,000'
UNION ALL SELECT '    Cr  141100  WIP - Revenue Project      ₹8,00,000';

-- Scenario 2B: Asset-Building Project
SELECT 'SCENARIO 2B: ASSET PROJECT (Internal Asset Creation)' as scenario_title;
SELECT 'Dr  152100  Asset Project WIP - Material    ₹8,00,000' as journal_entry
UNION ALL SELECT 'Dr  170200  Input GST on Capital Goods    ₹1,44,000'
UNION ALL SELECT '    Cr  210100  Trade Payables             ₹9,44,000'
UNION ALL SELECT ''
UNION ALL SELECT '-- Future: Asset Capitalization --'
UNION ALL SELECT 'Dr  150200  Building - Company Warehouse  ₹50,00,000'
UNION ALL SELECT '    Cr  152100  Asset Project WIP          ₹50,00,000';

-- Scenario 3: Direct Asset Construction (Unchanged)
SELECT 'SCENARIO 3: DIRECT ASSET CONSTRUCTION' as scenario_title;
SELECT 'Dr  151000  Capital WIP - Steel Structure   ₹8,00,000' as journal_entry
UNION ALL SELECT 'Dr  170200  Input GST on Capital Goods    ₹1,44,000'
UNION ALL SELECT '    Cr  210100  Trade Payables             ₹9,44,000';

-- KEY INSIGHT: PROJECT PURPOSE DETERMINES ACCOUNTING TREATMENT
SELECT 'CRITICAL DISTINCTION' as insight_type, 'PROJECT PURPOSE MATTERS' as description
UNION ALL SELECT 'Revenue Project', 'Steel → WIP → Cost of Sales (when revenue recognized)'
UNION ALL SELECT 'Asset Project', 'Steel → Asset WIP → Fixed Asset (when project complete)'
UNION ALL SELECT 'Direct Asset', 'Steel → Capital WIP → Fixed Asset (when asset complete)'
UNION ALL SELECT 'Warehouse Stock', 'Steel → Inventory → Material Cost (when consumed)'
UNION ALL SELECT '', ''
UNION ALL SELECT 'Same Material', 'Different final accounting treatment'
UNION ALL SELECT 'Same Cost', 'Different P&L and Balance Sheet impact'
UNION ALL SELECT 'Same GST', 'Different input credit treatment';