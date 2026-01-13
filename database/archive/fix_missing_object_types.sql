-- Fix missing master data entries for existing object types
INSERT INTO approval_object_types (
    customer_id, object_type, object_category, object_name, description,
    default_strategy, required_fields, validation_rules, form_config
) VALUES
-- Missing Financial Objects
('550e8400-e29b-41d4-a716-446655440001', 'PR', 'FINANCIAL', 'Purchase Requisition', 'Purchase requisitions for procurement requests', 'ROLE_BASED',
 '["material_code", "quantity", "estimated_cost", "department_code"]', '{"min_amount": 0, "max_amount": 1000000}',
 '{"fields": [{"name": "material_code", "type": "text", "required": true}, {"name": "estimated_cost", "type": "number", "required": true}]}'),

('550e8400-e29b-41d4-a716-446655440001', 'CLAIM', 'FINANCIAL', 'Claims Processing', 'Insurance and warranty claims processing', 'AMOUNT_BASED',
 '["claim_type", "amount", "currency", "incident_date"]', '{"min_amount": 0, "max_amount": 500000}',
 '{"fields": [{"name": "claim_type", "type": "select", "options": ["WARRANTY", "INSURANCE", "DAMAGE"]}, {"name": "amount", "type": "number", "required": true}]}');

-- Update existing policies object_subtype for consistency
UPDATE approval_policies 
SET object_subtype = CASE 
    WHEN approval_object_type = 'PR' THEN 'PURCHASE_REQUISITION'
    WHEN approval_object_type = 'CLAIM' THEN 'CLAIMS_PROCESSING'
    ELSE object_subtype
END
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
  AND approval_object_type IN ('PR', 'CLAIM')
  AND object_subtype IS NULL;

-- Verify all object types now have master data
SELECT 
    ap.approval_object_type,
    ap.object_category as policy_category,
    aot.object_category as master_category,
    aot.object_name,
    CASE 
        WHEN ap.object_category = aot.object_category THEN '✅ CONSISTENT'
        WHEN ap.object_category IS NULL AND aot.object_category IS NOT NULL THEN '⚠️ POLICY_MISSING_CATEGORY'
        WHEN ap.object_category IS NOT NULL AND aot.object_category IS NULL THEN '❌ MASTER_MISSING'
        ELSE '❌ INCONSISTENT'
    END as status
FROM approval_policies ap
FULL OUTER JOIN approval_object_types aot 
    ON ap.approval_object_type = aot.object_type 
    AND ap.customer_id = aot.customer_id
WHERE (ap.customer_id = '550e8400-e29b-41d4-a716-446655440001'
   OR aot.customer_id = '550e8400-e29b-41d4-a716-446655440001')
  AND ap.approval_object_type IS NOT NULL
ORDER BY ap.approval_object_type, status;