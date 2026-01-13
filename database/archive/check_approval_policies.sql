-- Check if approval policies exist and verify customer_id filtering
SELECT 
    customer_id,
    policy_name,
    approval_object_type,
    approval_object_document_type,
    approval_strategy,
    approval_pattern,
    is_active
FROM approval_policies 
WHERE customer_id = 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid
ORDER BY approval_object_type, approval_object_document_type;

-- Also check all policies regardless of customer_id
SELECT 'Total policies in database:' as info, COUNT(*) as count FROM approval_policies;