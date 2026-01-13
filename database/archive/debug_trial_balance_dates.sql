-- Test trial balance function with various date parameters

-- 1. Test with no date restrictions
SELECT 'No dates' as test, * FROM get_trial_balance('C001', NULL, NULL);

-- 2. Test with wide date range
SELECT 'Wide range' as test, * FROM get_trial_balance('C001', '2024-01-01', '2024-12-31');

-- 3. Test with current date (what the API uses by default)
SELECT 'Current date' as test, * FROM get_trial_balance('C001', NULL, CURRENT_DATE);

-- 4. Check if the issue is the date comparison
SELECT 'Raw data' as test, 
    coa.account_code,
    coa.account_name,
    SUM(je.debit_amount) as debit,
    SUM(je.credit_amount) as credit,
    fd.posting_date
FROM chart_of_accounts coa
LEFT JOIN journal_entries je ON coa.account_code = je.account_code
LEFT JOIN financial_documents fd ON je.document_id = fd.id
WHERE coa.company_code = 'C001'
GROUP BY coa.account_code, coa.account_name, fd.posting_date
HAVING SUM(je.debit_amount) > 0 OR SUM(je.credit_amount) > 0;