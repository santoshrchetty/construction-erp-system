-- Check the admin role
SELECT * FROM roles WHERE id = '00e8b52d-e653-47c2-b679-7d9623973a44';

-- Create permissions system
CREATE TABLE IF NOT EXISTS permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS role_permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id UUID NOT NULL REFERENCES roles(id),
    permission_id UUID NOT NULL REFERENCES permissions(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(role_id, permission_id)
);

-- Add ERP configuration permission
INSERT INTO permissions (name, description) VALUES 
('erp_configuration', 'Access ERP Configuration module')
ON CONFLICT (name) DO NOTHING;

-- Assign ERP permission to admin role
INSERT INTO role_permissions (role_id, permission_id) VALUES 
('00e8b52d-e653-47c2-b679-7d9623973a44', 
 (SELECT id FROM permissions WHERE name = 'erp_configuration'))
ON CONFLICT (role_id, permission_id) DO NOTHING;