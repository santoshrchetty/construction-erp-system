-- Test if Trial Balance can see finance engine postings
-- Run this to verify the trial balance function works

SELECT * FROM get_trial_balance('C001', 'ACCRUAL', CURRENT_DATE)
WHERE gl_account IN ('130000', '140000', '210000', '400000', '510000', '520000')
ORDER BY gl_account;

-- Also check raw universal journal data
SELECT 
    gl_account,
    posting_key,
    debit_credit,
    company_amount,
    source_document_id,
    event_type
FROM universal_journal 
WHERE source_document_id IN ('TS-TEST', 'INV-TEST', 'MD-TEST')
ORDER BY gl_account, debit_credit;