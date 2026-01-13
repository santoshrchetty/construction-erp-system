-- Create all missing project configuration tables

-- 1. Create project_gl_determination table
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

-- 2. Create project_numbering_rules table
CREATE TABLE IF NOT EXISTS project_numbering_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL,
    pattern VARCHAR(100) NOT NULL,
    current_number INTEGER DEFAULT 1,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    company_code VARCHAR(10) DEFAULT 'C001',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create project_workflows table
CREATE TABLE IF NOT EXISTS project_workflows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_name VARCHAR(100) NOT NULL,
    workflow_type VARCHAR(50) NOT NULL,
    steps INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'Active',
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    company_code VARCHAR(10) DEFAULT 'C001',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert data into project_gl_determination
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

-- Insert data into project_numbering_rules
INSERT INTO project_numbering_rules (entity_type, pattern, current_number, description, company_code) VALUES
('PROJECT', 'P{YYYY}{####}', 100, 'Annual project numbering', 'C001'),
('WBS_ELEMENT', '{PROJECT}.{##}.{##}', 1, 'Hierarchical WBS structure', 'C001'),
('ACTIVITY', '{WBS}.{###}', 1, 'Activity numbering within WBS', 'C001'),
('TASK', '{ACTIVITY}.{##}', 1, 'Task numbering within activities', 'C001')
ON CONFLICT DO NOTHING;

-- Insert data into project_workflows
INSERT INTO project_workflows (workflow_name, workflow_type, steps, status, description, company_code) VALUES
('Project Creation', 'CREATION', 3, 'Active', 'New project approval workflow', 'C001'),
('Budget Change', 'BUDGET', 4, 'Active', 'Budget modification approval', 'C001'),
('Project Closure', 'CLOSURE', 2, 'Active', 'Project completion workflow', 'C001'),
('WBS Modification', 'WBS', 2, 'Draft', 'WBS structure changes', 'C001')
ON CONFLICT DO NOTHING;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_project_gl_determination_category ON project_gl_determination(project_category);
CREATE INDEX IF NOT EXISTS idx_project_gl_determination_company ON project_gl_determination(company_code);
CREATE INDEX IF NOT EXISTS idx_project_numbering_rules_company ON project_numbering_rules(company_code);
CREATE INDEX IF NOT EXISTS idx_project_numbering_rules_entity ON project_numbering_rules(entity_type);
CREATE INDEX IF NOT EXISTS idx_project_workflows_company ON project_workflows(company_code);
CREATE INDEX IF NOT EXISTS idx_project_workflows_type ON project_workflows(workflow_type);