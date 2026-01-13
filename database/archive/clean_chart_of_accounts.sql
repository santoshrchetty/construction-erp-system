-- Construction Industry Chart of Accounts - Clean Version
-- =======================================================

-- Add company_code column first
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS company_code VARCHAR(4) DEFAULT 'C001';

-- Clear dependent data first
DELETE FROM gl_accounts;
DELETE FROM chart_of_accounts;

-- Insert Construction Chart of Accounts
INSERT INTO chart_of_accounts (coa_code, coa_name, account_code, account_name, account_type, cost_element_category, cost_category, balance_sheet_account, cost_relevant, company_code) VALUES

-- ASSETS
('1000', 'Cash', '100000', 'Cash and Cash Equivalents', 'ASSET', NULL, NULL, true, false, 'C001'),
('1100', 'A/R Trade', '110000', 'Trade Accounts Receivable', 'ASSET', NULL, NULL, true, false, 'C001'),
('1300', 'Inventory', '130000', 'Raw Materials Inventory', 'ASSET', NULL, NULL, true, false, 'C001'),
('1520', 'Equipment', '152000', 'Construction Equipment', 'ASSET', NULL, NULL, true, false, 'C001'),

-- LIABILITIES  
('2000', 'A/P Trade', '200000', 'Trade Accounts Payable', 'LIABILITY', NULL, NULL, true, false, 'C001'),
('2020', 'GR/IR Clear', '202000', 'GR/IR Clearing Account', 'LIABILITY', NULL, NULL, true, false, 'C001'),

-- EQUITY
('3000', 'Share Capital', '300000', 'Common Stock', 'EQUITY', NULL, NULL, true, false, 'C001'),

-- PRIMARY COST ELEMENTS (Cost Relevant = TRUE)
('4000', 'Materials', '400000', 'Raw Materials Consumed', 'EXPENSE', '1', 'MATERIAL', false, true, 'C001'),
('4010', 'Concrete', '401000', 'Concrete Materials', 'EXPENSE', '1', 'MATERIAL', false, true, 'C001'),
('4020', 'Steel', '402000', 'Steel Materials', 'EXPENSE', '1', 'MATERIAL', false, true, 'C001'),
('4500', 'Subcontract', '450000', 'Subcontractor Costs', 'EXPENSE', '1', 'SUBCONTRACT', false, true, 'C001'),
('6000', 'Labor', '600000', 'Direct Labor', 'EXPENSE', '1', 'LABOR', false, true, 'C001'),
('6500', 'Equipment', '650000', 'Equipment Costs', 'EXPENSE', '1', 'EQUIPMENT', false, true, 'C001'),

-- REVENUE
('8000', 'Revenue', '800000', 'Construction Revenue', 'REVENUE', NULL, NULL, false, false, 'C001'),

-- SECONDARY COST ELEMENTS  
('9000', 'Overhead', '900000', 'Project Overhead', 'EXPENSE', '21', 'OVERHEAD', false, true, 'C001');

-- Update existing records
UPDATE chart_of_accounts SET company_code = 'C001' WHERE company_code IS NULL;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_chart_company ON chart_of_accounts(company_code);
CREATE INDEX IF NOT EXISTS idx_chart_type ON chart_of_accounts(account_type);

-- Summary
SELECT 'Chart of Accounts created successfully!' as status;
SELECT account_type, cost_relevant, COUNT(*) as count 
FROM chart_of_accounts 
WHERE company_code = 'C001' 
GROUP BY account_type, cost_relevant 
ORDER BY account_type;