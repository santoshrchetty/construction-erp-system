-- Fix Organizational Hierarchy Table Structure
-- Add missing columns first, then insert data with all required fields

-- Add missing columns if they don't exist
ALTER TABLE organizational_hierarchy ADD COLUMN IF NOT EXISTS customer_id UUID;
ALTER TABLE organizational_hierarchy ADD COLUMN IF NOT EXISTS position_level INTEGER DEFAULT 1;

-- Make user_id nullable for position-based hierarchy
ALTER TABLE organizational_hierarchy ALTER COLUMN user_id DROP NOT NULL;

-- Insert organizational hierarchy data for position-based approval
INSERT INTO organizational_hierarchy (
    company_code, country_code, position_title, department_code, plant_code, 
    approval_limit, position_level, is_active, customer_id, effective_from
) VALUES 
-- C001 - India Operations Hierarchy
('C001', 'IN', 'Site Supervisor', 'OPS', 'PLT_MUM', 25000, 2, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('C001', 'IN', 'Site Supervisor', 'OPS', 'PLT_DEL', 25000, 2, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('C001', 'IN', 'Plant Manager', 'OPS', 'PLT_MUM', 500000, 3, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('C001', 'IN', 'Plant Manager', 'OPS', 'PLT_DEL', 500000, 3, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('C001', 'IN', 'Ops Director', 'OPS', NULL, 3000000, 4, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('C001', 'IN', 'Finance Mgr', 'FIN', NULL, 2000000, 3, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('C001', 'IN', 'CFO', 'FIN', NULL, 10000000, 4, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('C001', 'IN', 'Safety Officer', 'SAFETY', 'PLT_MUM', 50000, 2, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('C001', 'IN', 'Safety Officer', 'SAFETY', 'PLT_DEL', 50000, 2, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('C001', 'IN', 'Safety Mgr', 'SAFETY', NULL, 250000, 3, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('C001', 'IN', 'Eng Manager', 'ENG', NULL, 750000, 3, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('C001', 'IN', 'Chief Eng', 'ENG', NULL, 1500000, 4, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('C001', 'IN', 'Country Mgr', 'EXEC', NULL, 50000000, 5, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),

-- B001 - USA Operations Hierarchy
('B001', 'US', 'Site Supervisor', 'OPS', 'PLT_NYC', 30000, 2, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('B001', 'US', 'Site Supervisor', 'OPS', 'PLT_CHI', 30000, 2, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('B001', 'US', 'Plant Manager', 'OPS', 'PLT_NYC', 750000, 3, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('B001', 'US', 'Plant Manager', 'OPS', 'PLT_CHI', 750000, 3, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('B001', 'US', 'Ops Director', 'OPS', NULL, 5000000, 4, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('B001', 'US', 'Finance Mgr', 'FIN', NULL, 3000000, 3, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('B001', 'US', 'CFO', 'FIN', NULL, 15000000, 4, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('B001', 'US', 'Safety Officer', 'SAFETY', 'PLT_NYC', 75000, 2, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('B001', 'US', 'Safety Officer', 'SAFETY', 'PLT_CHI', 75000, 2, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('B001', 'US', 'Safety Mgr', 'SAFETY', NULL, 400000, 3, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('B001', 'US', 'Eng Manager', 'ENG', NULL, 1000000, 3, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('B001', 'US', 'Chief Eng', 'ENG', NULL, 2000000, 4, true, '550e8400-e29b-41d4-a716-446655440001', NOW()),
('B001', 'US', 'Country Mgr', 'EXEC', NULL, 75000000, 5, true, '550e8400-e29b-41d4-a716-446655440001', NOW())

ON CONFLICT DO NOTHING;

-- Update existing records with customer_id if needed
UPDATE organizational_hierarchy 
SET customer_id = '550e8400-e29b-41d4-a716-446655440001' 
WHERE customer_id IS NULL;

SELECT 'Organizational hierarchy updated for both C001 and B001 companies' as status;