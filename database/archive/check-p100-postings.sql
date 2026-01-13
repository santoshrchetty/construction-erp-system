-- Check P100 financial postings in universal_journal
SELECT 
    posting_date,
    event_type,
    gl_account,
    debit_credit,
    company_amount
FROM universal_journal 
WHERE project_code = 'P100'
ORDER BY posting_date, id;

-- Summary by debit/credit
SELECT 
    debit_credit,
    COUNT(*) as transaction_count,
    SUM(company_amount) as total_amount
FROM universal_journal 
WHERE project_code = 'P100'
GROUP BY debit_credit;