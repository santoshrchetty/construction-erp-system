-- Create missing project_numbering_rules table
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

-- Insert default numbering rules
INSERT INTO project_numbering_rules (entity_type, pattern, current_number, description, company_code) VALUES
('PROJECT', 'P{YYYY}{####}', 100, 'Annual project numbering', 'C001'),
('WBS_ELEMENT', '{PROJECT}.{##}.{##}', 1, 'Hierarchical WBS structure', 'C001'),
('ACTIVITY', '{WBS}.{###}', 1, 'Activity numbering within WBS', 'C001'),
('TASK', '{ACTIVITY}.{##}', 1, 'Task numbering within activities', 'C001')
ON CONFLICT DO NOTHING;

-- Create missing project_workflows table
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

-- Insert default workflows
INSERT INTO project_workflows (workflow_name, workflow_type, steps, status, description, company_code) VALUES
('Project Creation', 'CREATION', 3, 'Active', 'New project approval workflow', 'C001'),
('Budget Change', 'BUDGET', 4, 'Active', 'Budget modification approval', 'C001'),
('Project Closure', 'CLOSURE', 2, 'Active', 'Project completion workflow', 'C001'),
('WBS Modification', 'WBS', 2, 'Draft', 'WBS structure changes', 'C001')
ON CONFLICT DO NOTHING;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_project_numbering_rules_company ON project_numbering_rules(company_code);
CREATE INDEX IF NOT EXISTS idx_project_numbering_rules_entity ON project_numbering_rules(entity_type);
CREATE INDEX IF NOT EXISTS idx_project_workflows_company ON project_workflows(company_code);
CREATE INDEX IF NOT EXISTS idx_project_workflows_type ON project_workflows(workflow_type);