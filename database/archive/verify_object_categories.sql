-- Verify object category consistency for existing and new object types
-- Check current policies and their categories
SELECT 
    approval_object_type,
    object_category,
    object_subtype,
    COUNT(*) as policy_count,
    STRING_AGG(DISTINCT approval_strategy, ', ') as strategies_used
FROM approval_policies 
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
GROUP BY approval_object_type, object_category, object_subtype
ORDER BY object_category, approval_object_type;

-- Check object types master data
SELECT 
    object_type,
    object_category,
    object_name,
    default_strategy,
    'Master Data' as source
FROM approval_object_types
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
ORDER BY object_category, object_type;

-- Identify any inconsistencies
SELECT 
    ap.approval_object_type,
    ap.object_category as policy_category,
    aot.object_category as master_category,
    CASE 
        WHEN ap.object_category = aot.object_category THEN 'CONSISTENT'
        WHEN ap.object_category IS NULL AND aot.object_category IS NOT NULL THEN 'POLICY_MISSING_CATEGORY'
        WHEN ap.object_category IS NOT NULL AND aot.object_category IS NULL THEN 'MASTER_MISSING'
        ELSE 'INCONSISTENT'
    END as status
FROM approval_policies ap
FULL OUTER JOIN approval_object_types aot 
    ON ap.approval_object_type = aot.object_type 
    AND ap.customer_id = aot.customer_id
WHERE ap.customer_id = '550e8400-e29b-41d4-a716-446655440001'
   OR aot.customer_id = '550e8400-e29b-41d4-a716-446655440001';