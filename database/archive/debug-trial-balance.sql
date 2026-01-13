-- Debug trial balance - check what's missing

-- 1. Check all test entries in universal journal
SELECT 
    gl_account,
    debit_credit,
    company_amount,
    source_document_id
FROM universal_journal 
WHERE source_document_id IN ('TS-TEST', 'INV-TEST', 'MD-TEST')
ORDER BY gl_account;

-- 2. Check if accounts exist in chart_of_accounts
SELECT 
    account_code,
    account_name,
    account_type,
    company_code
FROM chart_of_accounts 
WHERE account_code IN ('130000', '140000', '210000', '400000', '510000', '520000')
AND company_code = 'C001'
ORDER BY account_code;

-- 3. Test trial balance function directly
SELECT * FROM get_trial_balance('C001', 'ACCRUAL', '2026-01-03')
ORDER BY gl_account;

-- 4. Check if the JOIN in trial balance function is working
SELECT 
    uj.gl_account,
    uj.debit_credit,
    uj.company_amount,
    coa.account_name,
    coa.account_type
FROM universal_journal uj
LEFT JOIN chart_of_accounts coa ON uj.gl_account = coa.account_code AND uj.company_code = coa.company_code
WHERE uj.source_document_id IN ('TS-TEST', 'INV-TEST', 'MD-TEST')
ORDER BY uj.gl_account;