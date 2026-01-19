-- All-in-One Verification Query

SELECT 
    'Cost Elements' as metric,
    COUNT(*)::text as value
FROM cost_elements

UNION ALL

SELECT 
    'Universal Journal Entries (HW-0001)' as metric,
    COUNT(*)::text as value
FROM universal_journal
WHERE project_code = 'HW-0001'

UNION ALL

SELECT 
    'Project HW-0001 Exists' as metric,
    CASE WHEN COUNT(*) > 0 THEN 'YES' ELSE 'NO' END as value
FROM projects
WHERE code = 'HW-0001'

UNION ALL

SELECT 
    'Activity A01 Exists' as metric,
    CASE WHEN COUNT(*) > 0 THEN 'YES' ELSE 'NO' END as value
FROM activities
WHERE code = 'HW-0001.01-A01'

UNION ALL

SELECT 
    'Company Code 1000 Exists' as metric,
    CASE WHEN COUNT(*) > 0 THEN 'YES' ELSE 'NO' END as value
FROM company_codes
WHERE company_code = '1000'

ORDER BY metric;
