-- Debug why trial balance shows no line items

-- 1. Check journal entries after update
SELECT account_code, SUM(debit_amount) as total_debit, SUM(credit_amount) as total_credit 
FROM journal_entries 
GROUP BY account_code;

-- 2. Check the join with financial documents
SELECT 
    je.account_code,
    je.debit_amount,
    je.credit_amount,
    fd.posting_date,
    fd.company_code
FROM journal_entries je
JOIN financial_documents fd ON je.document_id = fd.id
LIMIT 10;

-- 3. Check if financial documents have company_code C001
SELECT company_code, count(*) FROM financial_documents GROUP BY company_code;

-- 4. Test trial balance without date filter
SELECT 
    coa.account_code,
    coa.account_name,
    SUM(je.debit_amount) as total_debit,
    SUM(je.credit_amount) as total_credit
FROM chart_of_accounts coa
LEFT JOIN journal_entries je ON coa.account_code = je.account_code
WHERE coa.company_code = 'C001'
GROUP BY coa.account_code, coa.account_name
HAVING SUM(je.debit_amount) > 0 OR SUM(je.credit_amount) > 0;