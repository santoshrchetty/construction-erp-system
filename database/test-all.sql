-- Complete Verification Test

-- 1. Universal Journal Entry Count
SELECT COUNT(*) as journal_entries FROM universal_journal WHERE project_code = 'HW-0001';

-- 2. Activity A01 Total
SELECT activity_code, SUM(company_amount) as total_cost
FROM universal_journal
WHERE activity_code = 'HW-0001.01-A01'
GROUP BY activity_code;

-- 3. Cost by Type
SELECT ce.cost_element_type, SUM(uj.company_amount) as total
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
GROUP BY ce.cost_element_type
ORDER BY total DESC;

-- 4. Direct vs Indirect
SELECT ce.is_direct_cost, SUM(uj.company_amount) as total
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
GROUP BY ce.is_direct_cost;
