-- Context-specific approval policies
INSERT INTO approval_policies (
    id, customer_id, policy_name, approval_object_type, approval_object_document_type,
    approval_strategy, approval_pattern, amount_thresholds,
    company_code, country_code, plant_code, purchase_org, project_code,
    is_active, created_at
) VALUES
-- Company-wide policies
('550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440001', 
 'Global PO Standard Policy', 'PO', 'NB', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 999999999, "currency": "USD"}',
 'C001', 'USA', NULL, NULL, NULL, true, NOW()),

-- Plant-specific policies
('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440001',
 'NYC Plant PO Policy', 'PO', 'NB', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 100000, "currency": "USD"}',
 'C001', 'USA', 'PLANT_NYC', 'PO_CONSTRUCTION', NULL, true, NOW()),

('550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440001',
 'Chicago Plant PO Policy', 'PO', 'NB', 'ROLE_BASED', 'HIERARCHY_ONLY', 
 '{"min": 0, "max": 150000, "currency": "USD"}',
 'C001', 'USA', 'PLANT_CHI', 'PO_CONSTRUCTION', NULL, true, NOW()),

-- Project-specific policies
('550e8400-e29b-41d4-a716-446655440103', '550e8400-e29b-41d4-a716-446655440001',
 'Project Alpha MR Policy', 'MR', 'NB', 'HYBRID', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 50000, "currency": "USD"}',
 'C001', 'USA', NULL, NULL, 'PROJ_ALPHA_2024', true, NOW()),

-- Purchase org specific
('550e8400-e29b-41d4-a716-446655440104', '550e8400-e29b-41d4-a716-446655440001',
 'Construction Procurement Claims', 'CLAIM', 'CR', 'AMOUNT_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 25000, "currency": "USD"}',
 'C001', 'USA', NULL, 'PO_CONSTRUCTION', NULL, true, NOW());

-- Verify context-specific policies
SELECT 
    policy_name,
    approval_object_type,
    approval_object_document_type,
    company_code,
    country_code,
    plant_code,
    purchase_org,
    project_code,
    approval_strategy
FROM approval_policies 
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
ORDER BY company_code, plant_code, project_code;