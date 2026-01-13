-- Steel Goods Receipt - Standardized Baseline Comparison
-- Same Material: TMT Steel Bars, Same Quantity: 10 MT, Same Rate: ₹80,000/MT
-- Base Amount: ₹8,00,000, GST: ₹1,44,000, Total: ₹9,44,000

-- BASELINE PARAMETERS (Constant across all scenarios)
-- Material: TMT Steel Bars (HSN: 7214)
-- Quantity: 10 MT
-- Rate: ₹80,000 per MT
-- Base Value: ₹8,00,000
-- GST Rate: 18%
-- GST Amount: ₹1,44,000
-- Total Invoice: ₹9,44,000
-- Supplier: Steel India Ltd
-- Company: C001 (ABC Construction)

-- SCENARIO COMPARISON TABLE
SELECT 
  'Parameter' as comparison_aspect,
  'Scenario 1: Internal Consumption' as scenario_1,
  'Scenario 2: Project Receipt' as scenario_2,
  'Scenario 3: Asset Construction' as scenario_3

UNION ALL SELECT 'Material', 'TMT Steel Bars', 'TMT Steel Bars', 'TMT Steel Bars'
UNION ALL SELECT 'Quantity', '10 MT', '10 MT', '10 MT'
UNION ALL SELECT 'Rate per MT', '₹80,000', '₹80,000', '₹80,000'
UNION ALL SELECT 'Base Amount', '₹8,00,000', '₹8,00,000', '₹8,00,000'
UNION ALL SELECT 'GST @ 18%', '₹1,44,000', '₹1,44,000', '₹1,44,000'
UNION ALL SELECT 'Total Invoice', '₹9,44,000', '₹9,44,000', '₹9,44,000'

UNION ALL SELECT '--- GL DETERMINATION ---', '---', '---', '---'
UNION ALL SELECT 'Movement Type', 'C101 (GR to Warehouse)', 'C111 (GR to Project)', 'C121 (GR for Asset)'
UNION ALL SELECT 'Valuation Class', 'RAW_MATERIAL', 'RAW_MATERIAL', 'CAPITAL_GOODS'
UNION ALL SELECT 'Business Process', 'PROCURE_TO_PAY', 'PROJECT_EXECUTION', 'ASSET_CONSTRUCTION'
UNION ALL SELECT 'Project Category', 'GENERAL', 'BUILDING', 'INFRASTRUCTURE'

UNION ALL SELECT '--- JOURNAL ENTRIES ---', '---', '---', '---'
UNION ALL SELECT 'Debit Account 1', '130200 (Steel Inventory)', '140100 (WIP Material)', '151000 (Capital WIP)'
UNION ALL SELECT 'Debit Amount 1', '₹8,00,000', '₹8,00,000', '₹8,00,000'
UNION ALL SELECT 'Debit Account 2', '170100 (Input GST)', '170100 (Input GST)', '170200 (GST on Capital)'
UNION ALL SELECT 'Debit Amount 2', '₹1,44,000', '₹1,44,000', '₹1,44,000'
UNION ALL SELECT 'Credit Account', '210100 (Trade Payable)', '210100 (Trade Payable)', '210100 (Trade Payable)'
UNION ALL SELECT 'Credit Amount', '₹9,44,000', '₹9,44,000', '₹9,44,000'

UNION ALL SELECT '--- BALANCE SHEET IMPACT ---', '---', '---', '---'
UNION ALL SELECT 'Asset Classification', 'Current Assets', 'Current Assets', 'Fixed Assets'
UNION ALL SELECT 'Asset Sub-Category', 'Inventories', 'Inventories', 'Capital WIP'
UNION ALL SELECT 'Schedule III Line', 'Raw Materials', 'Work-in-Progress', 'Capital Work-in-Progress'
UNION ALL SELECT 'Asset Value', '₹8,00,000', '₹8,00,000', '₹8,00,000'

UNION ALL SELECT '--- P&L IMPACT ---', '---', '---', '---'
UNION ALL SELECT 'Immediate P&L Impact', 'None', 'None', 'None'
UNION ALL SELECT 'Future P&L Impact', 'Cost of Materials', 'Project Cost', 'Depreciation'
UNION ALL SELECT 'Expense Classification', 'Direct Material Cost', 'Project Direct Cost', 'Depreciation Expense'

UNION ALL SELECT '--- GST COMPLIANCE ---', '---', '---', '---'
UNION ALL SELECT 'HSN Code', '7214', '7214', '7214'
UNION ALL SELECT 'GST Rate', '18%', '18%', '18%'
UNION ALL SELECT 'Input Credit Status', 'Immediate', 'Immediate', 'Restricted'
UNION ALL SELECT 'Credit Utilization', 'Against Output Tax', 'Against Output Tax', 'Phased over 5 years'
UNION ALL SELECT 'GSTR-3B Impact', 'ITC Available', 'ITC Available', 'ITC Restricted'

UNION ALL SELECT '--- CASH FLOW IMPACT ---', '---', '---', '---'
UNION ALL SELECT 'Cash Flow Category', 'Operating Activities', 'Operating Activities', 'Investing Activities'
UNION ALL SELECT 'Cash Outflow', '₹9,44,000', '₹9,44,000', '₹9,44,000'
UNION ALL SELECT 'Working Capital Impact', 'Inventory Increase', 'WIP Increase', 'Fixed Asset Increase'

UNION ALL SELECT '--- COST ACCOUNTING ---', '---', '---', '---'
UNION ALL SELECT 'Cost Center', 'Warehouse', 'Project Alpha', 'Asset Construction'
UNION ALL SELECT 'Cost Object', 'Inventory Pool', 'WBS Element', 'Asset Code'
UNION ALL SELECT 'Profit Center', 'Corporate', 'Building Projects', 'Infrastructure'

UNION ALL SELECT '--- REGULATORY COMPLIANCE ---', '---', '---', '---'
UNION ALL SELECT 'AS-2 (Inventory)', 'Raw material at cost', 'WIP at cost', 'Not applicable'
UNION ALL SELECT 'AS-7 (Construction)', 'Not applicable', 'Contract WIP', 'Not applicable'
UNION ALL SELECT 'AS-10 (Fixed Assets)', 'Not applicable', 'Not applicable', 'Asset under construction'
UNION ALL SELECT 'Companies Act', 'Schedule III compliant', 'Schedule III compliant', 'Schedule III compliant'

UNION ALL SELECT '--- AUDIT CONSIDERATIONS ---', '---', '---', '---'
UNION ALL SELECT 'Physical Verification', 'Annual stock count', 'Project milestone', 'Asset completion'
UNION ALL SELECT 'Valuation Method', 'FIFO/Weighted Avg', 'Actual Cost', 'Actual Cost'
UNION ALL SELECT 'Impairment Test', 'NRV Test', 'Contract Loss Test', 'Recoverable Amount'

UNION ALL SELECT '--- TAX IMPLICATIONS ---', '---', '---', '---'
UNION ALL SELECT 'Income Tax', 'Closing stock', 'WIP valuation', 'Depreciation base'
UNION ALL SELECT 'GST Impact', 'Input credit', 'Input credit', 'Restricted credit'
UNION ALL SELECT 'Transfer Pricing', 'Not applicable', 'Project allocation', 'Asset allocation';

-- DETAILED JOURNAL ENTRIES WITH SAME BASELINE

-- Scenario 1: Internal Consumption
SELECT 'SCENARIO 1: INTERNAL CONSUMPTION - JOURNAL ENTRY' as title;
SELECT 
  1 as entry_line,
  'Dr' as dr_cr,
  '130200' as account_code,
  'Steel Inventory - Raw Material' as account_name,
  800000.00 as amount,
  'TMT Steel 10MT @ ₹80,000/MT for warehouse stock' as narration
UNION ALL
SELECT 2, 'Dr', '170100', 'Input GST Receivable', 144000.00, 'GST 18% on steel purchase - HSN 7214'
UNION ALL  
SELECT 3, 'Cr', '210100', 'Trade Payables - Steel India Ltd', 944000.00, 'Steel supplier invoice including GST';

-- Scenario 2: Project Receipt  
SELECT 'SCENARIO 2: PROJECT RECEIPT - JOURNAL ENTRY' as title;
SELECT 
  1 as entry_line,
  'Dr' as dr_cr,
  '140100' as account_code,
  'WIP - Direct Material (Steel)' as account_name,
  800000.00 as amount,
  'TMT Steel 10MT @ ₹80,000/MT for Project Alpha - WBS: ALPHA-STR-001' as narration
UNION ALL
SELECT 2, 'Dr', '170100', 'Input GST Receivable', 144000.00, 'GST 18% on steel purchase - HSN 7214'
UNION ALL
SELECT 3, 'Cr', '210100', 'Trade Payables - Steel India Ltd', 944000.00, 'Steel supplier invoice for Project Alpha';

-- Scenario 3: Asset Construction
SELECT 'SCENARIO 3: ASSET CONSTRUCTION - JOURNAL ENTRY' as title;
SELECT 
  1 as entry_line,
  'Dr' as dr_cr,
  '151000' as account_code,
  'Capital WIP - Steel Structure' as account_name,
  800000.00 as amount,
  'TMT Steel 10MT @ ₹80,000/MT for Warehouse Asset - WH-MUM-001' as narration
UNION ALL
SELECT 2, 'Dr', '170200', 'Input GST on Capital Goods', 144000.00, 'GST 18% on capital goods - Restricted credit'
UNION ALL
SELECT 3, 'Cr', '210100', 'Trade Payables - Steel India Ltd', 944000.00, 'Steel supplier invoice for asset construction';

-- KEY INSIGHT: SAME TRANSACTION, DIFFERENT ACCOUNTING TREATMENT
SELECT 'KEY INSIGHT' as insight_type, 'SAME BASELINE PARAMETERS' as description
UNION ALL SELECT 'Material', 'Identical TMT Steel Bars - 10 MT @ ₹80,000/MT'
UNION ALL SELECT 'Invoice Amount', 'Identical ₹9,44,000 (₹8,00,000 + ₹1,44,000 GST)'
UNION ALL SELECT 'Supplier', 'Identical Steel India Ltd'
UNION ALL SELECT 'GL Treatment', 'DIFFERENT based on business purpose'
UNION ALL SELECT 'Balance Sheet', 'Current Assets vs Fixed Assets'
UNION ALL SELECT 'GST Impact', 'Immediate vs Restricted input credit'
UNION ALL SELECT 'Compliance', 'Different accounting standards apply';