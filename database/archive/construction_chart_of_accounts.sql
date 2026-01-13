-- Construction Industry Chart of Accounts
-- ========================================
-- Multi-Company Structure with Standard Account Ranges
-- Company Codes: C001 (USD), C002 (EUR), C003 (GBP)

-- Add company_code column first
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS company_code VARCHAR(4) DEFAULT 'C001';

-- Clear existing sample data first
DELETE FROM chart_of_accounts WHERE coa_code IN ('1100', '1400', '2000', '4001', '6001');

-- COMPANY C001 - US Construction Company (USD)
-- ============================================

-- ASSETS (100000-199999)
INSERT INTO chart_of_accounts (coa_code, coa_name, account_code, account_name, account_type, cost_element_category, cost_category, balance_sheet_account, cost_relevant, company_code) VALUES

-- Current Assets (100000-149999)
('1000', 'Cash - Operating', '100000', 'Cash and Cash Equivalents', 'ASSET', NULL, NULL, true, false, 'C001'),
('1010', 'Petty Cash', '101000', 'Petty Cash Fund', 'ASSET', NULL, NULL, true, false, 'C001'),
('1100', 'Accounts Receivable', '110000', 'Trade Accounts Receivable', 'ASSET', NULL, NULL, true, false, 'C001'),
('1110', 'Retention Receivable', '111000', 'Contract Retention Receivable', 'ASSET', NULL, NULL, true, false, 'C001'),
('1200', 'WIP - Unbilled', '120000', 'Work in Progress - Unbilled', 'ASSET', NULL, NULL, true, false, 'C001'),
('1210', 'WIP - Billed', '121000', 'Work in Progress - Billed', 'ASSET', NULL, NULL, true, false, 'C001'),
('1300', 'Raw Materials', '130000', 'Raw Materials Inventory', 'ASSET', NULL, NULL, true, false, 'C001'),
('1310', 'Construction Materials', '131000', 'Construction Materials Stock', 'ASSET', NULL, NULL, true, false, 'C001'),
('1320', 'Equipment Parts', '132000', 'Equipment Parts & Supplies', 'ASSET', NULL, NULL, true, false, 'C001'),
('1400', 'Prepaid Expenses', '140000', 'Prepaid Insurance & Expenses', 'ASSET', NULL, NULL, true, false, 'C001'),

-- Fixed Assets (150000-179999)
('1500', 'Land', '150000', 'Land and Building Sites', 'ASSET', NULL, NULL, true, false, 'C001'),
('1510', 'Buildings', '151000', 'Buildings and Structures', 'ASSET', NULL, NULL, true, false, 'C001'),
('1520', 'Construction Equipment', '152000', 'Heavy Construction Equipment', 'ASSET', NULL, NULL, true, false, 'C001'),
('1530', 'Vehicles', '153000', 'Trucks and Vehicles', 'ASSET', NULL, NULL, true, false, 'C001'),
('1540', 'Tools & Equipment', '154000', 'Small Tools and Equipment', 'ASSET', NULL, NULL, true, false, 'C001'),
('1600', 'Accumulated Depreciation', '160000', 'Accumulated Depreciation - Buildings', 'ASSET', NULL, NULL, true, false, 'C001'),
('1610', 'Accum Depr - Equipment', '161000', 'Accumulated Depreciation - Equipment', 'ASSET', NULL, NULL, true, false, 'C001'),

-- LIABILITIES (200000-299999)
-- Current Liabilities (200000-249999)
('2000', 'Accounts Payable', '200000', 'Trade Accounts Payable', 'LIABILITY', NULL, NULL, true, false, 'C001'),
('2010', 'Retention Payable', '201000', 'Contract Retention Payable', 'LIABILITY', NULL, NULL, true, false, 'C001'),
('2020', 'GR/IR Clearing', '202000', 'Goods Receipt/Invoice Receipt Clearing', 'LIABILITY', NULL, NULL, true, false, 'C001'),
('2100', 'Accrued Payroll', '210000', 'Accrued Wages and Salaries', 'LIABILITY', NULL, NULL, true, false, 'C001'),
('2110', 'Payroll Taxes', '211000', 'Payroll Taxes Payable', 'LIABILITY', NULL, NULL, true, false, 'C001'),
('2200', 'Short-term Debt', '220000', 'Short-term Bank Loans', 'LIABILITY', NULL, NULL, true, false, 'C001'),
('2300', 'Customer Advances', '230000', 'Customer Advance Payments', 'LIABILITY', NULL, NULL, true, false, 'C001'),

-- Long-term Liabilities (250000-299999)
('2500', 'Long-term Debt', '250000', 'Long-term Bank Loans', 'LIABILITY', NULL, NULL, true, false, 'C001'),
('2510', 'Equipment Financing', '251000', 'Equipment Financing Payable', 'LIABILITY', NULL, NULL, true, false, 'C001'),

-- EQUITY (300000-399999)
('3000', 'Share Capital', '300000', 'Common Stock', 'EQUITY', NULL, NULL, true, false, 'C001'),
('3100', 'Retained Earnings', '310000', 'Retained Earnings', 'EQUITY', NULL, NULL, true, false, 'C001'),
('3200', 'Current Year Earnings', '320000', 'Current Year Net Income', 'EQUITY', NULL, NULL, true, false, 'C001'),

-- PRIMARY COST ELEMENTS (400000-699999) - Cost Relevant = TRUE
-- Material Costs (400000-449999)
('4000', 'Raw Materials', '400000', 'Raw Materials Consumed', 'EXPENSE', '1', 'MATERIAL', false, true, 'C001'),
('4010', 'Concrete & Cement', '401000', 'Concrete and Cement Materials', 'EXPENSE', '1', 'MATERIAL', false, true, 'C001'),
('4020', 'Steel & Rebar', '402000', 'Steel and Reinforcement Materials', 'EXPENSE', '1', 'MATERIAL', false, true, 'C001'),
('4030', 'Lumber & Wood', '403000', 'Lumber and Wood Materials', 'EXPENSE', '1', 'MATERIAL', false, true, 'C001'),
('4040', 'Electrical Materials', '404000', 'Electrical Components and Wiring', 'EXPENSE', '1', 'MATERIAL', false, true, 'C001'),
('4050', 'Plumbing Materials', '405000', 'Plumbing and HVAC Materials', 'EXPENSE', '1', 'MATERIAL', false, true, 'C001'),
('4060', 'Finishing Materials', '406000', 'Paint, Flooring, and Finishes', 'EXPENSE', '1', 'MATERIAL', false, true, 'C001'),

-- Subcontractor Costs (450000-499999)
('4500', 'Subcontractor - Civil', '450000', 'Civil Work Subcontractors', 'EXPENSE', '1', 'SUBCONTRACT', false, true, 'C001'),
('4510', 'Subcontractor - Electrical', '451000', 'Electrical Work Subcontractors', 'EXPENSE', '1', 'SUBCONTRACT', false, true, 'C001'),
('4520', 'Subcontractor - Plumbing', '452000', 'Plumbing and HVAC Subcontractors', 'EXPENSE', '1', 'SUBCONTRACT', false, true, 'C001'),
('4530', 'Subcontractor - Finishing', '453000', 'Finishing Work Subcontractors', 'EXPENSE', '1', 'SUBCONTRACT', false, true, 'C001'),
('4540', 'Subcontractor - Specialty', '454000', 'Specialty Trade Subcontractors', 'EXPENSE', '1', 'SUBCONTRACT', false, true, 'C001'),

-- Labor Costs (600000-649999)
('6000', 'Direct Labor - General', '600000', 'General Construction Labor', 'EXPENSE', '1', 'LABOR', false, true, 'C001'),
('6010', 'Direct Labor - Skilled', '601000', 'Skilled Trades Labor', 'EXPENSE', '1', 'LABOR', false, true, 'C001'),
('6020', 'Direct Labor - Supervisors', '602000', 'Site Supervisors and Foremen', 'EXPENSE', '1', 'LABOR', false, true, 'C001'),
('6030', 'Direct Labor - Engineers', '603000', 'Site Engineers and Technicians', 'EXPENSE', '1', 'LABOR', false, true, 'C001'),
('6100', 'Payroll Taxes - Direct', '610000', 'Payroll Taxes on Direct Labor', 'EXPENSE', '1', 'LABOR', false, true, 'C001'),
('6110', 'Benefits - Direct', '611000', 'Employee Benefits - Direct Labor', 'EXPENSE', '1', 'LABOR', false, true, 'C001'),

-- Equipment Costs (650000-699999)
('6500', 'Equipment Rental', '650000', 'Heavy Equipment Rental', 'EXPENSE', '1', 'EQUIPMENT', false, true, 'C001'),
('6510', 'Equipment Depreciation', '651000', 'Equipment Depreciation Expense', 'EXPENSE', '1', 'EQUIPMENT', false, true, 'C001'),
('6520', 'Equipment Maintenance', '652000', 'Equipment Repairs and Maintenance', 'EXPENSE', '1', 'EQUIPMENT', false, true, 'C001'),
('6530', 'Fuel and Oil', '653000', 'Equipment Fuel and Lubricants', 'EXPENSE', '1', 'EQUIPMENT', false, true, 'C001'),
('6540', 'Small Tools', '654000', 'Small Tools and Consumables', 'EXPENSE', '1', 'EQUIPMENT', false, true, 'C001'),

-- REVENUE (800000-899999)
('8000', 'Construction Revenue', '800000', 'Construction Contract Revenue', 'REVENUE', NULL, NULL, false, false, 'C001'),
('8010', 'Change Order Revenue', '801000', 'Change Order and Variation Revenue', 'REVENUE', NULL, NULL, false, false, 'C001'),
('8020', 'Equipment Rental Income', '802000', 'Equipment Rental Income', 'REVENUE', NULL, NULL, false, false, 'C001'),

-- SECONDARY COST ELEMENTS (900000-999999) - Internal Allocations
('9000', 'Project Management OH', '900000', 'Project Management Overhead', 'EXPENSE', '21', 'OVERHEAD', false, true, 'C001'),
('9010', 'Site Administration', '901000', 'Site Administration Overhead', 'EXPENSE', '21', 'OVERHEAD', false, true, 'C001'),
('9020', 'Quality Control', '902000', 'Quality Control and Testing', 'EXPENSE', '21', 'OVERHEAD', false, true, 'C001'),
('9030', 'Safety and Compliance', '903000', 'Safety and Regulatory Compliance', 'EXPENSE', '21', 'OVERHEAD', false, true, 'C001'),
('9040', 'Insurance Allocation', '904000', 'Insurance Cost Allocation', 'EXPENSE', '21', 'OVERHEAD', false, true, 'C001'),
('9050', 'Corporate Overhead', '905000', 'Corporate Overhead Allocation', 'EXPENSE', '21', 'OVERHEAD', false, true, 'C001');

-- Update existing records to have company code
UPDATE chart_of_accounts SET company_code = 'C001' WHERE company_code IS NULL;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_chart_of_accounts_company ON chart_of_accounts(company_code);
CREATE INDEX IF NOT EXISTS idx_chart_of_accounts_type ON chart_of_accounts(account_type);
CREATE INDEX IF NOT EXISTS idx_chart_of_accounts_cost_relevant ON chart_of_accounts(cost_relevant);

-- Summary Report
SELECT 
    company_code,
    account_type,
    cost_relevant,
    COUNT(*) as account_count
FROM chart_of_accounts 
WHERE company_code = 'C001'
GROUP BY company_code, account_type, cost_relevant
ORDER BY account_type, cost_relevant;

-- Show cost elements summary
SELECT 
    cost_category,
    COUNT(*) as count,
    MIN(coa_code) as from_code,
    MAX(coa_code) as to_code
FROM chart_of_accounts 
WHERE cost_relevant = true AND company_code = 'C001'
GROUP BY cost_category
ORDER BY cost_category;ompany_code,
    account_type,
    cost_relevant,
    COUNT(*) as account_count,
    STRING_AGG(DISTINCT cost_category, ', ') as cost_categories
FROM chart_of_accounts 
WHERE company_code = 'C001'
GROUP BY company_code, account_type, cost_relevant
ORDER BY account_type, cost_relevant;

-- Show cost elements summary
SELECT 
    'Cost Elements Summary for Company C001' as info,
    cost_category,
    COUNT(*) as count,
    MIN(coa_code) as from_code,
    MAX(coa_code) as to_code
FROM chart_of_accounts 
WHERE cost_relevant = true AND company_code = 'C001'
GROUP BY cost_category
ORDER BY cost_category;