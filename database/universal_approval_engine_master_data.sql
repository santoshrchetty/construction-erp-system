-- UNIVERSAL ENTERPRISE APPROVAL ENGINE - SAMPLE MASTER DATA
-- Populate with realistic organizational hierarchy and policies

-- 1. SAMPLE ORGANIZATIONAL HIERARCHY
INSERT INTO organizational_hierarchy (user_id, manager_id, company_code, country_code, department_code, plant_code, position_title, approval_limit, effective_from) VALUES
-- CEO Level
('550e8400-e29b-41d4-a716-446655440001', NULL, 'C001', 'USA', 'EXECUTIVE', NULL, 'Chief Executive Officer', 10000000.00, '2024-01-01'),

-- Country Managers
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'C001', 'USA', 'EXECUTIVE', NULL, 'Country Manager USA', 5000000.00, '2024-01-01'),
('550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', 'C002', 'GER', 'EXECUTIVE', NULL, 'Country Manager Germany', 4500000.00, '2024-01-01'),

-- Plant Managers
('550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002', 'C001', 'USA', 'OPERATIONS', 'B001', 'Plant Manager B001', 1000000.00, '2024-01-01'),
('550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440003', 'C002', 'GER', 'OPERATIONS', 'B002', 'Plant Manager B002', 900000.00, '2024-01-01'),

-- Department Managers
('550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440004', 'C001', 'USA', 'CONSTRUCTION', 'B001', 'Construction Manager', 500000.00, '2024-01-01'),
('550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440004', 'C001', 'USA', 'PROCUREMENT', 'B001', 'Procurement Manager', 200000.00, '2024-01-01'),
('550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440004', 'C001', 'USA', 'FINANCE', 'B001', 'Finance Manager', 300000.00, '2024-01-01'),
('550e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440004', 'C001', 'USA', 'SAFETY', 'B001', 'Safety Manager', 100000.00, '2024-01-01'),

-- Supervisors
('550e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440006', 'C001', 'USA', 'CONSTRUCTION', 'B001', 'Site Supervisor', 50000.00, '2024-01-01'),
('550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440007', 'C001', 'USA', 'PROCUREMENT', 'B001', 'Senior Buyer', 25000.00, '2024-01-01'),

-- Workers/Requestors
('550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440010', 'C001', 'USA', 'CONSTRUCTION', 'B001', 'Construction Worker', 1000.00, '2024-01-01'),
('550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440011', 'C001', 'USA', 'PROCUREMENT', 'B001', 'Junior Buyer', 5000.00, '2024-01-01');

-- 2. FUNCTIONAL APPROVER ASSIGNMENTS
INSERT INTO functional_approver_assignments (customer_id, functional_domain, approver_user_id, approver_role, approval_scope, company_code, country_code, department_code, approval_limit) VALUES
-- Finance Domain
('550e8400-e29b-41d4-a716-446655440001', 'FINANCE', '550e8400-e29b-41d4-a716-446655440008', 'Finance Manager', 'DEPARTMENT', 'C001', 'USA', 'FINANCE', 300000.00),
('550e8400-e29b-41d4-a716-446655440001', 'FINANCE', '550e8400-e29b-41d4-a716-446655440002', 'Country Manager USA', 'COUNTRY', 'C001', 'USA', NULL, 5000000.00),
('550e8400-e29b-41d4-a716-446655440001', 'FINANCE', '550e8400-e29b-41d4-a716-446655440001', 'Chief Executive Officer', 'GLOBAL', NULL, NULL, NULL, 10000000.00),

-- Legal Domain
('550e8400-e29b-41d4-a716-446655440001', 'LEGAL', '550e8400-e29b-41d4-a716-446655440002', 'Country Manager USA', 'COUNTRY', 'C001', 'USA', NULL, 1000000.00),
('550e8400-e29b-41d4-a716-446655440001', 'LEGAL', '550e8400-e29b-41d4-a716-446655440001', 'Chief Executive Officer', 'GLOBAL', NULL, NULL, NULL, 10000000.00),

-- Safety Domain
('550e8400-e29b-41d4-a716-446655440001', 'SAFETY', '550e8400-e29b-41d4-a716-446655440009', 'Safety Manager', 'DEPARTMENT', 'C001', 'USA', 'SAFETY', 100000.00),
('550e8400-e29b-41d4-a716-446655440001', 'SAFETY', '550e8400-e29b-41d4-a716-446655440004', 'Plant Manager B001', 'COUNTRY', 'C001', 'USA', NULL, 1000000.00),

-- Quality Domain
('550e8400-e29b-41d4-a716-446655440001', 'QUALITY', '550e8400-e29b-41d4-a716-446655440004', 'Plant Manager B001', 'DEPARTMENT', 'C001', 'USA', NULL, 500000.00);

-- 3. APPROVAL POLICIES
INSERT INTO approval_policies (customer_id, policy_name, approval_object_type, approval_object_document_type, company_code, country_code, department_code, approval_strategy, approval_pattern, functional_domains, amount_thresholds, priority_order) VALUES
-- Purchase Order Policies
('550e8400-e29b-41d4-a716-446655440001', 'Standard PO USA', 'PO', 'NB', 'C001', 'USA', NULL, 'AMOUNT_BASED', 'FUNCTIONAL_THEN_HIERARCHY', 
 '{"required": ["FINANCE"]}', 
 '{"currency": "USD", "thresholds": [{"min": 0, "max": 50000, "authority": "BUYER"}, {"min": 50001, "max": 200000, "authority": "MANAGER"}, {"min": 200001, "max": 999999999, "authority": "DIRECTOR"}]}', 10),

('550e8400-e29b-41d4-a716-446655440001', 'Emergency PO USA', 'PO', 'EM', 'C001', 'USA', NULL, 'AMOUNT_BASED', 'HIERARCHY_THEN_FUNCTIONAL', 
 '{"required": ["FINANCE"]}', 
 '{"currency": "USD", "thresholds": [{"min": 0, "max": 25000, "authority": "SUPERVISOR"}, {"min": 25001, "max": 100000, "authority": "MANAGER"}]}', 10),

('550e8400-e29b-41d4-a716-446655440001', 'Critical PO USA', 'PO', 'CR', 'C001', 'USA', NULL, 'HYBRID', 'FUNCTIONAL_THEN_HIERARCHY', 
 '{"required": ["FINANCE", "LEGAL"]}', 
 '{"currency": "USD", "thresholds": [{"min": 0, "max": 25000, "authority": "MANAGER"}, {"min": 25001, "max": 100000, "authority": "DIRECTOR"}, {"min": 100001, "max": 999999999, "authority": "CEO"}]}', 10),

-- Material Request Policies
('550e8400-e29b-41d4-a716-446655440001', 'Standard MR Construction', 'MR', 'NB', 'C001', 'USA', 'CONSTRUCTION', 'ROLE_BASED', 'HIERARCHY_ONLY', '{}', '{}', 10),

('550e8400-e29b-41d4-a716-446655440001', 'Emergency MR Safety', 'MR', 'EM', 'C001', 'USA', 'SAFETY', 'ROLE_BASED', 'FUNCTIONAL_THEN_HIERARCHY', 
 '{"required": ["SAFETY"]}', '{}', 10),

('550e8400-e29b-41d4-a716-446655440001', 'Critical MR Construction', 'MR', 'CR', 'C001', 'USA', 'CONSTRUCTION', 'ROLE_BASED', 'FUNCTIONAL_THEN_HIERARCHY', 
 '{"required": ["SAFETY"]}', '{}', 10),

-- Purchase Request Policies
('550e8400-e29b-41d4-a716-446655440001', 'Standard PR Procurement', 'PR', 'NB', 'C001', 'USA', 'PROCUREMENT', 'ROLE_BASED', 'HIERARCHY_ONLY', '{}', '{}', 10),

('550e8400-e29b-41d4-a716-446655440001', 'Special PR Legal', 'PR', 'SP', 'C001', 'USA', 'PROCUREMENT', 'ROLE_BASED', 'FUNCTIONAL_THEN_HIERARCHY', 
 '{"required": ["LEGAL"]}', '{}', 10),

-- Claims Policies
('550e8400-e29b-41d4-a716-446655440001', 'Standard Claim', 'CLAIM', 'NB', 'C001', 'USA', NULL, 'HYBRID', 'FUNCTIONAL_THEN_HIERARCHY', 
 '{"required": ["FINANCE", "LEGAL"]}', 
 '{"currency": "USD", "thresholds": [{"min": 0, "max": 10000, "authority": "MANAGER"}, {"min": 10001, "max": 50000, "authority": "DIRECTOR"}, {"min": 50001, "max": 999999999, "authority": "CEO"}]}', 10);

-- 4. SAMPLE DELEGATIONS
INSERT INTO approval_delegations (delegator_user_id, delegate_user_id, delegation_scope, valid_from, valid_to, reason) VALUES
('550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440007', 'FUNCTIONAL', '2024-01-01', '2024-12-31', 'Finance Manager vacation coverage'),
('550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440010', 'SUPERVISORY', '2024-01-01', '2024-06-30', 'Construction Manager delegation to Site Supervisor');

SELECT 'UNIVERSAL ENTERPRISE APPROVAL ENGINE MASTER DATA LOADED' as status;
SELECT 'Ready for Runtime Testing' as next_step;

-- Quick verification queries
SELECT 'ORGANIZATIONAL HIERARCHY LOADED:' as info;
SELECT position_title, COUNT(*) as count 
FROM organizational_hierarchy 
WHERE is_active = true 
GROUP BY position_title 
ORDER BY count DESC;

SELECT 'FUNCTIONAL APPROVERS LOADED:' as info;
SELECT functional_domain, approval_scope, COUNT(*) as count 
FROM functional_approver_assignments 
WHERE is_active = true 
GROUP BY functional_domain, approval_scope 
ORDER BY functional_domain, approval_scope;

SELECT 'APPROVAL POLICIES LOADED:' as info;
SELECT approval_object_type, approval_object_document_type, approval_strategy, approval_pattern, COUNT(*) as count 
FROM approval_policies 
WHERE is_active = true 
GROUP BY approval_object_type, approval_object_document_type, approval_strategy, approval_pattern 
ORDER BY approval_object_type, approval_object_document_type;