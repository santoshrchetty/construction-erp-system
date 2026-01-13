-- Debug Trial Balance - Run this to check what's happening

-- 1. Check if chart_of_accounts has data
SELECT 'Chart of Accounts:' as check, count(*) as count FROM chart_of_accounts WHERE company_code = 'C001';

-- 2. Check if journal_entries has data  
SELECT 'Journal Entries:' as check, count(*) as count FROM journal_entries;

-- 3. Check the join between tables
SELECT 
    coa.account_number,
    coa.account_name,
    je.debit_amount,
    je.credit_amount,
    fd.posting_date
FROM chart_of_accounts coa
LEFT JOIN journal_entries je ON coa.account_number = je.account_code
LEFT JOIN financial_documents fd ON je.document_id = fd.id
WHERE coa.company_code = 'C001'
LIMIT 10;

-- 4. Test the trial balance function directly
SELECT * FROM get_trial_balance('C001', NULL, CURRENT_DATE);