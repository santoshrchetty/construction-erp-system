-- INSERT TEST APPROVAL POLICIES FROM PREVIOUS TESTS
-- Production-grade approach with proper customer grouping

-- Create a single test customer UUID for all policies
WITH test_customer AS (
  SELECT 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::uuid as customer_uuid
)
INSERT INTO approval_policies (
    customer_id, policy_name, approval_object_type, approval_object_document_type, 
    approval_strategy, approval_pattern, amount_thresholds, is_active
)
SELECT 
    customer_uuid,
    policy_name,
    approval_object_type,
    approval_object_document_type,
    approval_strategy,
    approval_pattern,
    amount_thresholds::jsonb,
    is_active
FROM test_customer, (
  VALUES
  -- Material Request Policies
  ('MR Normal Business Policy', 'MR', 'NB', 'HYBRID', 'HIERARCHY_ONLY', '{"min": 0, "max": 10000, "currency": "USD"}', true),
  ('MR Emergency Policy', 'MR', 'EM', 'ROLE_BASED', 'HIERARCHY_ONLY', '{"min": 0, "max": 999999999, "currency": "USD"}', true),
  ('MR Special Project Policy', 'MR', 'SP', 'AMOUNT_BASED', 'FUNCTIONAL_THEN_HIERARCHY', '{"min": 0, "max": 50000, "currency": "USD"}', true),
  
  -- Purchase Requisition Policies  
  ('PR Normal Business Policy', 'PR', 'NB', 'HYBRID', 'HIERARCHY_ONLY', '{"min": 0, "max": 25000, "currency": "USD"}', true),
  ('PR Emergency Policy', 'PR', 'EM', 'ROLE_BASED', 'HIERARCHY_ONLY', '{"min": 0, "max": 999999999, "currency": "USD"}', true),
  ('PR Critical Policy', 'PR', 'CR', 'AMOUNT_BASED', 'FUNCTIONAL_THEN_HIERARCHY', '{"min": 0, "max": 100000, "currency": "USD"}', true),
  
  -- Purchase Order Policies
  ('PO Normal Business Policy', 'PO', 'NB', 'HYBRID', 'HIERARCHY_ONLY', '{"min": 0, "max": 50000, "currency": "USD"}', true),
  ('PO Emergency Policy', 'PO', 'EM', 'ROLE_BASED', 'HIERARCHY_ONLY', '{"min": 0, "max": 999999999, "currency": "USD"}', true),
  ('PO Critical Policy', 'PO', 'CR', 'AMOUNT_BASED', 'FUNCTIONAL_THEN_HIERARCHY', '{"min": 25000, "max": 999999999, "currency": "USD"}', true),
  
  -- Claims Policies
  ('CLAIM Emergency Policy', 'CLAIM', 'EM', 'HYBRID', 'HIERARCHY_ONLY', '{"min": 0, "max": 25000, "currency": "USD"}', true),
  ('CLAIM Critical Policy', 'CLAIM', 'CR', 'AMOUNT_BASED', 'FUNCTIONAL_THEN_HIERARCHY', '{"min": 10000, "max": 999999999, "currency": "USD"}', true),
  ('CLAIM Special Policy', 'CLAIM', 'SP', 'ROLE_BASED', 'HIERARCHY_ONLY', '{"min": 0, "max": 999999999, "currency": "USD"}', true)
) AS policies(policy_name, approval_object_type, approval_object_document_type, approval_strategy, approval_pattern, amount_thresholds, is_active);

SELECT 'Test approval policies inserted' as result;