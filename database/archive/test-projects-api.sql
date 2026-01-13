-- Test the exact query that projectFinanceServices.ts uses
-- This should match what getProjectSummary() is doing

-- First, check what data exists
SELECT 
    project_code,
    COUNT(*) as transaction_count,
    SUM(CASE WHEN debit_credit = 'D' THEN company_amount ELSE 0 END) as total_debits,
    SUM(CASE WHEN debit_credit = 'C' THEN company_amount ELSE 0 END) as total_credits
FROM universal_journal 
WHERE company_code = 'C001' 
AND project_code IS NOT NULL
GROUP BY project_code
ORDER BY project_code;

-- Check projects table for budget data
SELECT code, budget FROM projects;

-- Test the exact service query
SELECT 
    project_code,
    gl_account,
    debit_credit,
    company_amount,
    posting_date,
    cost_center,
    wbs_element
FROM universal_journal
WHERE company_code = 'C001'
AND project_code IS NOT NULL
ORDER BY posting_date DESC
LIMIT 10;