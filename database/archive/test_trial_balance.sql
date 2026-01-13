-- Test the trial balance function step by step

-- 1. Test the join directly
SELECT 
    coa.account_code,
    coa.account_name,
    je.debit_amount,
    je.credit_amount
FROM chart_of_accounts coa
LEFT JOIN journal_entries je ON coa.account_code = je.account_code
WHERE coa.company_code = 'C001'
LIMIT 10;

-- 2. Test the function call
SELECT * FROM get_trial_balance('C001', NULL, '2024-12-31');

-- 3. Check if accounts exist
SELECT account_code, account_name FROM chart_of_accounts WHERE account_code IN ('110000', '400100', '600100', '650100', '800100', '450100');