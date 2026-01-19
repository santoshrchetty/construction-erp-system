-- Verification Queries for Cost Elements and Universal Journal

-- 1. Check Cost Elements Master Data
SELECT 
    cost_element_category,
    cost_element_type,
    COUNT(*) as element_count
FROM cost_elements
WHERE is_active = true
GROUP BY cost_element_category, cost_element_type
ORDER BY cost_element_category, cost_element_type;

-- 2. Check Universal Journal Data for HW-0001
SELECT 
    activity_code,
    cost_element,
    gl_account,
    company_amount,
    event_type
FROM universal_journal
WHERE project_code = 'HW-0001'
ORDER BY posting_date;

-- 3. Direct vs Indirect Cost Report
SELECT 
    ce.is_direct_cost,
    ce.cost_element_type,
    COUNT(*) as transaction_count,
    SUM(uj.company_amount) as total_cost
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
GROUP BY ce.is_direct_cost, ce.cost_element_type
ORDER BY ce.is_direct_cost DESC, total_cost DESC;

-- 4. Activity-Level Cost Breakdown
SELECT 
    uj.activity_code,
    ce.cost_element_type,
    SUM(uj.company_amount) as actual_cost
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
  AND uj.activity_code IS NOT NULL
GROUP BY uj.activity_code, ce.cost_element_type
ORDER BY uj.activity_code, actual_cost DESC;

-- 5. WBS-Level Summary (including indirect costs)
SELECT 
    uj.wbs_element,
    CASE 
        WHEN uj.activity_code IS NOT NULL THEN 'Direct (Activity-level)'
        ELSE 'Indirect (WBS-level)'
    END as cost_type,
    SUM(uj.company_amount) as total_cost
FROM universal_journal uj
WHERE uj.project_code = 'HW-0001'
GROUP BY uj.wbs_element, 
    CASE 
        WHEN uj.activity_code IS NOT NULL THEN 'Direct (Activity-level)'
        ELSE 'Indirect (WBS-level)'
    END
ORDER BY uj.wbs_element, cost_type;

-- 6. Cost Element Category Summary
SELECT 
    ce.cost_element_category,
    COUNT(DISTINCT uj.cost_element) as elements_used,
    COUNT(*) as transaction_count,
    SUM(uj.company_amount) as total_cost
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
GROUP BY ce.cost_element_category
ORDER BY total_cost DESC;

-- 7. Detailed Activity A01 Cost Breakdown
SELECT 
    ce.cost_element,
    ce.cost_element_name,
    ce.cost_element_type,
    uj.company_amount,
    uj.event_type,
    uj.posting_date
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.activity_code = 'HW-0001.01-A01'
ORDER BY uj.posting_date;

-- 8. Secondary Cost Elements (Allocations)
SELECT 
    uj.activity_code,
    ce.cost_element_name,
    ce.default_allocation_basis,
    uj.company_amount,
    uj.gl_account as financial_gl
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
  AND ce.is_secondary_cost = true;

-- 9. Total Project Cost Summary
SELECT 
    'Direct Costs' as category,
    SUM(uj.company_amount) as amount
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001' AND ce.is_direct_cost = true
UNION ALL
SELECT 
    'Indirect Costs' as category,
    SUM(uj.company_amount) as amount
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001' AND ce.is_direct_cost = false
UNION ALL
SELECT 
    'Total Project Cost' as category,
    SUM(uj.company_amount) as amount
FROM universal_journal uj
WHERE uj.project_code = 'HW-0001';

-- 10. Verify Trigger (cost_element auto-populated from gl_account)
SELECT 
    gl_account,
    cost_element,
    CASE 
        WHEN gl_account = cost_element THEN 'Synced'
        WHEN gl_account IS NULL AND cost_element IS NOT NULL THEN 'Secondary Cost'
        ELSE 'Mismatch'
    END as sync_status
FROM universal_journal
WHERE project_code = 'HW-0001';
