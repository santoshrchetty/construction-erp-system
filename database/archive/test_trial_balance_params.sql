-- Test trial balance function with different parameters

-- 1. Test without date filter
SELECT * FROM get_trial_balance('C001', NULL, NULL);

-- 2. Test with wide date range
SELECT * FROM get_trial_balance('C001', '2024-01-01', '2024-12-31');

-- 3. Test the raw query without function
SELECT 
    coa.account_code,
    coa.account_name,
    coa.account_type,
    COALESCE(SUM(je.debit_amount), 0) as debit_balance,
    COALESCE(SUM(je.credit_amount), 0) as credit_balance
FROM chart_of_accounts coa
LEFT JOIN journal_entries je ON coa.account_code = je.account_code
WHERE coa.company_code = 'C001'
AND coa.is_active = true
GROUP BY coa.account_code, coa.account_name, coa.account_type
HAVING COALESCE(SUM(je.debit_amount), 0) > 0 OR COALESCE(SUM(je.credit_amount), 0) > 0;