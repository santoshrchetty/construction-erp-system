-- Test the projects API data directly
-- Check if we have data in universal_journal for projects
SELECT 
    project_code,
    COUNT(*) as transaction_count,
    SUM(CASE WHEN debit_credit = 'D' THEN company_amount ELSE 0 END) as total_debits,
    SUM(CASE WHEN debit_credit = 'C' THEN company_amount ELSE 0 END) as total_credits
FROM universal_journal 
WHERE project_code IS NOT NULL
GROUP BY project_code
ORDER BY project_code;

-- Check if we have projects in the projects table
SELECT code, name, budget, status FROM projects ORDER BY code;