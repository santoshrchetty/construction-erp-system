-- Create missing project_gl_determination table
CREATE TABLE IF NOT EXISTS project_gl_determination (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_category VARCHAR(50) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    gl_account_type VARCHAR(50) NOT NULL,
    debit_credit CHAR(1) NOT NULL CHECK (debit_credit IN ('D', 'C')),
    posting_key VARCHAR(10) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    company_code VARCHAR(10) DEFAULT 'C001',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default GL determination rules
INSERT INTO project_gl_determination (project_category, event_type, gl_account_type, debit_credit, posting_key, company_code) VALUES
('CUSTOMER', 'MATERIAL_CONSUMPTION', 'WIP', 'D', '40', 'C001'),
('CUSTOMER', 'MATERIAL_CONSUMPTION', 'EXPENSE', 'C', '50', 'C001'),
('CUSTOMER', 'LABOR_COST', 'WIP', 'D', '40', 'C001'),
('CUSTOMER', 'LABOR_COST', 'EXPENSE', 'C', '50', 'C001'),
('CONTRACT', 'REVENUE_RECOGNITION', 'REVENUE', 'C', '80', 'C001'),
('CONTRACT', 'REVENUE_RECOGNITION', 'WIP', 'D', '40', 'C001'),
('CAPITAL', 'MATERIAL_CONSUMPTION', 'WIP', 'D', '40', 'C001'),
('CAPITAL', 'MATERIAL_CONSUMPTION', 'EXPENSE', 'C', '50', 'C001'),
('OVERHEAD', 'OVERHEAD_ALLOCATION', 'EXPENSE', 'D', '40', 'C001'),
('OVERHEAD', 'OVERHEAD_ALLOCATION', 'WIP', 'C', '50', 'C001')
ON CONFLICT DO NOTHING;

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_project_gl_determination_category ON project_gl_determination(project_category);
CREATE INDEX IF NOT EXISTS idx_project_gl_determination_company ON project_gl_determination(company_code);
CREATE INDEX IF NOT EXISTS idx_project_gl_determination_active ON project_gl_determination(is_active);