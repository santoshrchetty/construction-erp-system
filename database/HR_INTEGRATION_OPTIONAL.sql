-- Optional HR Integration Table for Employee-Based Approval Flows
-- This table is only needed if HR system integration is required

CREATE TABLE IF NOT EXISTS employee_hierarchy (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    employee_id VARCHAR(50) NOT NULL,
    employee_name VARCHAR(200) NOT NULL,
    position_title VARCHAR(100) NOT NULL,
    department_code VARCHAR(20),
    plant_code VARCHAR(20),
    manager_employee_id VARCHAR(50), -- Direct manager
    department_head_id VARCHAR(50),  -- Department head
    approval_limit DECIMAL(15,2) DEFAULT 0,
    position_level INTEGER DEFAULT 1, -- 1=Junior, 2=Senior, 3=Manager, 4=Director
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(customer_id, employee_id)
);

-- Sample HR data (only if HR integration is needed)
INSERT INTO employee_hierarchy (
    customer_id, employee_id, employee_name, position_title, 
    department_code, plant_code, manager_employee_id, department_head_id,
    approval_limit, position_level
) VALUES 
-- India Operations Team
('550e8400-e29b-41d4-a716-446655440001', 'EMP001', 'Raj Kumar', 'Site Supervisor', 'OPERATIONS', 'PLANT_MUMBAI', 'EMP003', 'EMP005', 25000, 2),
('550e8400-e29b-41d4-a716-446655440001', 'EMP002', 'Priya Sharma', 'Safety Officer', 'SAFETY', 'PLANT_MUMBAI', 'EMP006', 'EMP006', 50000, 2),
('550e8400-e29b-41d4-a716-446655440001', 'EMP003', 'Amit Patel', 'Plant Manager', 'OPERATIONS', 'PLANT_MUMBAI', 'EMP005', 'EMP005', 500000, 3),
('550e8400-e29b-41d4-a716-446655440001', 'EMP004', 'Sunita Reddy', 'Finance Manager', 'FINANCE', NULL, 'EMP007', 'EMP007', 2000000, 3),
('550e8400-e29b-41d4-a716-446655440001', 'EMP005', 'Vikram Singh', 'Operations Director', 'OPERATIONS', NULL, 'EMP008', 'EMP008', 3000000, 4),
('550e8400-e29b-41d4-a716-446655440001', 'EMP006', 'Meera Joshi', 'Safety Manager', 'SAFETY', NULL, 'EMP008', 'EMP008', 250000, 3),
('550e8400-e29b-41d4-a716-446655440001', 'EMP007', 'Ravi Gupta', 'CFO India', 'FINANCE', NULL, 'EMP008', 'EMP008', 10000000, 4),
('550e8400-e29b-41d4-a716-446655440001', 'EMP008', 'Kavita Nair', 'Country Manager India', 'EXECUTIVE', NULL, NULL, 'EMP008', 50000000, 5)

ON CONFLICT (customer_id, employee_id) DO NOTHING;

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_employee_hierarchy_manager 
ON employee_hierarchy (customer_id, manager_employee_id, is_active) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_employee_hierarchy_dept 
ON employee_hierarchy (customer_id, department_code, is_active) WHERE is_active = true;

SELECT 'HR integration table created (optional)' as status;