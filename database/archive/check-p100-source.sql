-- Check if P100 exists in projects table
SELECT 'projects_table' as source, id, code, name, status, budget 
FROM projects 
WHERE code = 'P100' OR name LIKE '%P100%';

-- Check P100 in universal_journal
SELECT 'universal_journal' as source, project_code, COUNT(*) as transaction_count,
       SUM(debit_amount) as total_debits, SUM(credit_amount) as total_credits
FROM universal_journal 
WHERE project_code = 'P100'
GROUP BY project_code;

-- Check all project codes in universal_journal
SELECT DISTINCT project_code, COUNT(*) as transactions
FROM universal_journal 
WHERE project_code IS NOT NULL
GROUP BY project_code
ORDER BY project_code;