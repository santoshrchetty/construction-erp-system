-- Complete organizational hierarchy with plant/project dimensions
INSERT INTO organizational_hierarchy (
    user_id, manager_id, company_code, country_code, department_code, plant_code,
    position_title, approval_limit, approval_limit_currency, 
    effective_from, is_active
) VALUES
-- Department Hierarchy
('550e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440008', 'C001', 'USA', 'FINANCE', NULL, 'Finance Analyst', 5000, 'USD', '2024-01-01', true),
('550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440002', 'C001', 'USA', 'FINANCE', NULL, 'Finance Manager', 300000, 'USD', '2024-01-01', true),

-- Plant Hierarchy
('550e8400-e29b-41d4-a716-446655440020', '550e8400-e29b-41d4-a716-446655440021', 'C001', 'USA', 'OPERATIONS', 'PLANT_NYC', 'Site Supervisor NYC', 25000, 'USD', '2024-01-01', true),
('550e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440002', 'C001', 'USA', 'OPERATIONS', 'PLANT_NYC', 'Plant Manager NYC', 150000, 'USD', '2024-01-01', true),

('550e8400-e29b-41d4-a716-446655440030', '550e8400-e29b-41d4-a716-446655440031', 'C001', 'USA', 'OPERATIONS', 'PLANT_CHI', 'Site Supervisor Chicago', 25000, 'USD', '2024-01-01', true),
('550e8400-e29b-41d4-a716-446655440031', '550e8400-e29b-41d4-a716-446655440002', 'C001', 'USA', 'OPERATIONS', 'PLANT_CHI', 'Plant Manager Chicago', 150000, 'USD', '2024-01-01', true),

-- Executive Level
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'C001', 'USA', 'EXECUTIVE', NULL, 'Country Manager USA', 5000000, 'USD', '2024-01-01', true),
('550e8400-e29b-41d4-a716-446655440001', NULL, 'C001', 'USA', 'EXECUTIVE', NULL, 'Chief Executive Officer', 10000000, 'USD', '2024-01-01', true);

-- Verify multi-dimensional hierarchy
SELECT 
    h.position_title,
    h.department_code,
    h.plant_code,
    h.approval_limit,
    m.position_title as manager_title
FROM organizational_hierarchy h
LEFT JOIN organizational_hierarchy m ON h.manager_id = m.user_id
ORDER BY h.department_code, h.plant_code, h.approval_limit;