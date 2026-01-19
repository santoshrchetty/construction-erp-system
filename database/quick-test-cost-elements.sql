-- Quick Test: Verify Cost Elements Integration

-- Test 1: Count cost elements by category
SELECT 'Cost Elements by Category' as test;
SELECT cost_element_category, COUNT(*) FROM cost_elements GROUP BY cost_element_category;

-- Test 2: Count universal journal entries for HW-0001
SELECT 'Universal Journal Entries for HW-0001' as test;
SELECT COUNT(*) as entry_count FROM universal_journal WHERE project_code = 'HW-0001';

-- Test 3: Activity A01 Total Cost
SELECT 'Activity A01 Total Cost' as test;
SELECT 
    activity_code,
    SUM(company_amount) as total_cost
FROM universal_journal
WHERE activity_code = 'HW-0001.01-A01'
GROUP BY activity_code;

-- Test 4: Cost by Type (using cost_elements join)
SELECT 'Cost by Type' as test;
SELECT 
    ce.cost_element_type,
    SUM(uj.company_amount) as total
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
GROUP BY ce.cost_element_type
ORDER BY total DESC;
