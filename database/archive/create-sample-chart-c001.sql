-- Insert sample Chart of Accounts data for company C001
-- This will provide data to copy from C001 to B001

INSERT INTO chart_of_accounts (company_code, account_code, account_name, account_type, parent_account, is_active, created_at, updated_at) VALUES
-- Assets
('C001', '1000', 'Cash and Cash Equivalents', 'ASSET', NULL, true, NOW(), NOW()),
('C001', '1100', 'Petty Cash', 'ASSET', '1000', true, NOW(), NOW()),
('C001', '1200', 'Bank Account - Main', 'ASSET', '1000', true, NOW(), NOW()),
('C001', '1300', 'Accounts Receivable', 'ASSET', NULL, true, NOW(), NOW()),
('C001', '1400', 'Inventory - Raw Materials', 'ASSET', NULL, true, NOW(), NOW()),
('C001', '1500', 'Inventory - Finished Goods', 'ASSET', NULL, true, NOW(), NOW()),
('C001', '1600', 'Prepaid Expenses', 'ASSET', NULL, true, NOW(), NOW()),
('C001', '1700', 'Fixed Assets - Equipment', 'ASSET', NULL, true, NOW(), NOW()),
('C001', '1800', 'Accumulated Depreciation', 'ASSET', NULL, true, NOW(), NOW()),

-- Liabilities
('C001', '2000', 'Accounts Payable', 'LIABILITY', NULL, true, NOW(), NOW()),
('C001', '2100', 'Accrued Expenses', 'LIABILITY', NULL, true, NOW(), NOW()),
('C001', '2200', 'Short-term Loans', 'LIABILITY', NULL, true, NOW(), NOW()),
('C001', '2300', 'Long-term Debt', 'LIABILITY', NULL, true, NOW(), NOW()),
('C001', '2400', 'Tax Payable', 'LIABILITY', NULL, true, NOW(), NOW()),

-- Equity
('C001', '3000', 'Share Capital', 'EQUITY', NULL, true, NOW(), NOW()),
('C001', '3100', 'Retained Earnings', 'EQUITY', NULL, true, NOW(), NOW()),
('C001', '3200', 'Current Year Earnings', 'EQUITY', NULL, true, NOW(), NOW()),

-- Revenue
('C001', '4000', 'Sales Revenue', 'REVENUE', NULL, true, NOW(), NOW()),
('C001', '4100', 'Service Revenue', 'REVENUE', NULL, true, NOW(), NOW()),
('C001', '4200', 'Other Income', 'REVENUE', NULL, true, NOW(), NOW()),

-- Expenses
('C001', '5000', 'Cost of Goods Sold', 'EXPENSE', NULL, true, NOW(), NOW()),
('C001', '5100', 'Salaries and Wages', 'EXPENSE', NULL, true, NOW(), NOW()),
('C001', '5200', 'Rent Expense', 'EXPENSE', NULL, true, NOW(), NOW()),
('C001', '5300', 'Utilities Expense', 'EXPENSE', NULL, true, NOW(), NOW()),
('C001', '5400', 'Depreciation Expense', 'EXPENSE', NULL, true, NOW(), NOW()),
('C001', '5500', 'Marketing Expense', 'EXPENSE', NULL, true, NOW(), NOW()),
('C001', '5600', 'Administrative Expense', 'EXPENSE', NULL, true, NOW(), NOW()),
('C001', '5700', 'Interest Expense', 'EXPENSE', NULL, true, NOW(), NOW());

-- Verify the data was inserted
SELECT 'C001 Chart of Accounts Created' as status, COUNT(*) as total_accounts 
FROM chart_of_accounts 
WHERE company_code = 'C001';