-- Sync customer IDs - Update policies to match approvers customer_id
UPDATE approval_policies 
SET customer_id = '550e8400-e29b-41d4-a716-446655440001'
WHERE customer_id = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

-- Verify sync
SELECT 'Policies' as table_name, customer_id, COUNT(*) as count 
FROM approval_policies 
GROUP BY customer_id
UNION ALL
SELECT 'Approvers', customer_id, COUNT(*) 
FROM functional_approver_assignments 
GROUP BY customer_id;