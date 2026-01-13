-- Check posting dates in universal journal
SELECT 
    posting_date,
    COUNT(*) as entry_count,
    SUM(CASE WHEN debit_credit = 'D' THEN company_amount ELSE 0 END) as total_debits,
    SUM(CASE WHEN debit_credit = 'C' THEN company_amount ELSE 0 END) as total_credits
FROM universal_journal 
GROUP BY posting_date
ORDER BY posting_date DESC;

-- Check specific test data dates
SELECT 
    posting_date,
    gl_account,
    debit_credit,
    company_amount,
    source_document_id
FROM universal_journal 
WHERE source_document_id IN ('TS-TEST', 'INV-TEST', 'MD-TEST')
ORDER BY posting_date DESC, gl_account;