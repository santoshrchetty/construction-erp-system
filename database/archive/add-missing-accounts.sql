-- Add missing GL accounts to chart_of_accounts for trial balance

INSERT INTO chart_of_accounts (coa_code, coa_name, account_code, account_name, account_type, company_code, is_active, balance_sheet_account, cost_relevant) VALUES
('1400', 'Inventory', '140000', 'Inventory', 'ASSET', 'C001', true, true, false),
('2100', 'Payroll Liability', '210000', 'Payroll Liability', 'LIABILITY', 'C001', true, true, false),
('5100', 'Labor Expense', '510000', 'Labor Expense', 'EXPENSE', 'C001', true, false, true),
('5200', 'Production Cost', '520000', 'Production Cost', 'EXPENSE', 'C001', true, false, true)
ON CONFLICT (coa_code, company_code) DO UPDATE SET
    account_name = EXCLUDED.account_name,
    account_type = EXCLUDED.account_type,
    is_active = EXCLUDED.is_active;

-- Verify all accounts now exist
SELECT 
    account_code,
    account_name,
    account_type,
    company_code
FROM chart_of_accounts 
WHERE account_code IN ('130000', '140000', '210000', '400000', '510000', '520000')
AND company_code = 'C001'
ORDER BY account_code;