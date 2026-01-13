-- Cost Centers table for GL Posting
CREATE TABLE IF NOT EXISTS cost_centers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_code VARCHAR(4) NOT NULL,
    cost_center_code VARCHAR(10) NOT NULL,
    cost_center_name VARCHAR(100) NOT NULL,
    cost_center_type VARCHAR(20) DEFAULT 'STANDARD',
    responsible_person VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(company_code, cost_center_code)
);

-- Insert sample cost centers
INSERT INTO cost_centers (company_code, cost_center_code, cost_center_name, cost_center_type, responsible_person) VALUES
('C001', 'CC-ADMIN', 'Administration', 'OVERHEAD', 'Admin Manager'),
('C001', 'CC-PROJ01', 'Project Alpha', 'PROJECT', 'Project Manager A'),
('C001', 'CC-PROJ02', 'Project Beta', 'PROJECT', 'Project Manager B'),
('C001', 'CC-MAINT', 'Equipment Maintenance', 'SERVICE', 'Maintenance Head'),
('C001', 'CC-SALES', 'Sales & Marketing', 'REVENUE', 'Sales Director'),
('C002', 'CC-ADMIN', 'Administration', 'OVERHEAD', 'Admin Manager EU'),
('C002', 'CC-PROJ03', 'Infrastructure Project', 'PROJECT', 'Project Manager EU');

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_cost_centers_company ON cost_centers(company_code);
CREATE INDEX IF NOT EXISTS idx_cost_centers_active ON cost_centers(is_active);