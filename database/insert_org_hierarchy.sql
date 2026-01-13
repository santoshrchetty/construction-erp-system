-- Insert organizational hierarchy data for role-based approvals
INSERT INTO organizational_hierarchy (
    user_id, manager_id, company_code, country_code, department_code, 
    position_title, approval_limit, approval_limit_currency, 
    effective_from, is_active
) VALUES
-- Employee → Department Manager → Country Manager → CEO chain
('550e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440008', 'C001', 'USA', 'FINANCE', 'Finance Analyst', 5000, 'USD', '2024-01-01', true),
('550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440002', 'C001', 'USA', 'FINANCE', 'Finance Manager', 300000, 'USD', '2024-01-01', true),
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'C001', 'USA', 'EXECUTIVE', 'Country Manager USA', 5000000, 'USD', '2024-01-01', true),
('550e8400-e29b-41d4-a716-446655440001', NULL, 'C001', 'USA', 'EXECUTIVE', 'Chief Executive Officer', 10000000, 'USD', '2024-01-01', true);

-- Verify hierarchy
SELECT 
    h.user_id,
    h.position_title,
    h.approval_limit,
    m.position_title as manager_title
FROM organizational_hierarchy h
LEFT JOIN organizational_hierarchy m ON h.manager_id = m.user_id
ORDER BY h.approval_limit;