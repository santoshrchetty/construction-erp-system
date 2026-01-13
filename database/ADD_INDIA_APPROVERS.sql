-- Add India-specific approvers for Material Request approval flows

INSERT INTO functional_approver_assignments (
    customer_id, functional_domain, approver_role, approval_scope, 
    approval_limit, company_code, country_code, department_code, is_active
) VALUES 
-- India Finance Approvers
('550e8400-e29b-41d4-a716-446655440001', 'FINANCE', 'Finance Manager India', 'COUNTRY', 2000000, 'C001', 'IN', NULL, true),
('550e8400-e29b-41d4-a716-446655440001', 'FINANCE', 'CFO India', 'COUNTRY', 10000000, 'C001', 'IN', NULL, true),

-- India Operations Approvers  
('550e8400-e29b-41d4-a716-446655440001', 'OPERATIONS', 'Plant Manager Mumbai', 'PLANT', 500000, 'C001', 'IN', NULL, true),
('550e8400-e29b-41d4-a716-446655440001', 'OPERATIONS', 'Plant Manager Delhi', 'PLANT', 500000, 'C001', 'IN', NULL, true),
('550e8400-e29b-41d4-a716-446655440001', 'OPERATIONS', 'Operations Director India', 'COUNTRY', 3000000, 'C001', 'IN', NULL, true),

-- India Procurement Approvers
('550e8400-e29b-41d4-a716-446655440001', 'PROCUREMENT', 'Procurement Manager India', 'COUNTRY', 1000000, 'C001', 'IN', NULL, true),
('550e8400-e29b-41d4-a716-446655440001', 'PROCUREMENT', 'Senior Buyer Mumbai', 'PLANT', 100000, 'C001', 'IN', NULL, true),
('550e8400-e29b-41d4-a716-446655440001', 'PROCUREMENT', 'Senior Buyer Delhi', 'PLANT', 100000, 'C001', 'IN', NULL, true),

-- India Safety Approvers
('550e8400-e29b-41d4-a716-446655440001', 'SAFETY', 'Safety Manager India', 'COUNTRY', 250000, 'C001', 'IN', NULL, true),
('550e8400-e29b-41d4-a716-446655440001', 'SAFETY', 'Safety Officer Mumbai', 'PLANT', 50000, 'C001', 'IN', NULL, true),
('550e8400-e29b-41d4-a716-446655440001', 'SAFETY', 'Safety Officer Delhi', 'PLANT', 50000, 'C001', 'IN', NULL, true),

-- India Department Heads
('550e8400-e29b-41d4-a716-446655440001', 'ENGINEERING', 'Engineering Manager India', 'COUNTRY', 750000, 'C001', 'IN', NULL, true),
('550e8400-e29b-41d4-a716-446655440001', 'MAINTENANCE', 'Maintenance Manager India', 'COUNTRY', 300000, 'C001', 'IN', NULL, true)

ON CONFLICT DO NOTHING;

SELECT 'India approvers added successfully' as status;