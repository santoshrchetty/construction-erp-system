-- Final Cost Reports Verification

-- 1. Total by Cost Type
SELECT 
    ce.cost_element_type,
    SUM(uj.company_amount) as total
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
GROUP BY ce.cost_element_type
ORDER BY total DESC;

-- 2. Direct vs Indirect
SELECT 
    CASE WHEN ce.is_direct_cost THEN 'Direct' ELSE 'Indirect' END as cost_type,
    SUM(uj.company_amount) as total
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
GROUP BY ce.is_direct_cost;

-- 3. Activity A01 Breakdown
SELECT 
    ce.cost_element_type,
    SUM(uj.company_amount) as total
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.activity_code = 'HW-0001.01-A01'
GROUP BY ce.cost_element_type
ORDER BY total DESC;

-- 4. Activity vs WBS Level
SELECT 
    CASE 
        WHEN uj.activity_code IS NOT NULL THEN 'Activity-Level (Direct)'
        ELSE 'WBS-Level (Indirect)'
    END as posting_level,
    COUNT(*) as transactions,
    SUM(uj.company_amount) as total
FROM universal_journal uj
WHERE uj.project_code = 'HW-0001'
GROUP BY CASE 
    WHEN uj.activity_code IS NOT NULL THEN 'Activity-Level (Direct)'
    ELSE 'WBS-Level (Indirect)'
END;
