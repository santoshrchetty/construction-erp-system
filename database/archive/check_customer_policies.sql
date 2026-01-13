-- Check all customer_ids and their policy counts
SELECT 
    customer_id,
    COUNT(*) as policy_count,
    STRING_AGG(policy_name, ', ') as policy_names
FROM approval_policies 
GROUP BY customer_id
ORDER BY policy_count DESC;

-- Check if UI is using a different customer_id
SELECT DISTINCT customer_id FROM approval_policies;