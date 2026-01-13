-- Create Role Authorization Objects Table and Populate
-- ===================================================

-- Create the missing table
CREATE TABLE IF NOT EXISTS role_authorization_objects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    auth_object_id UUID NOT NULL REFERENCES authorization_objects(id) ON DELETE CASCADE,
    field_values JSONB NOT NULL,
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(role_id, auth_object_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_role_auth_objects_role ON role_authorization_objects(role_id);
CREATE INDEX IF NOT EXISTS idx_role_auth_objects_auth ON role_authorization_objects(auth_object_id);
CREATE INDEX IF NOT EXISTS idx_role_auth_objects_active ON role_authorization_objects(is_active);

-- Populate with Admin role assignments for existing objects
INSERT INTO role_authorization_objects (role_id, auth_object_id, field_values) 
SELECT 
    (SELECT id FROM roles WHERE name = 'Admin'),
    ao.id,
    '{"ACTVT": ["01", "02", "03"]}'
FROM authorization_objects ao
WHERE NOT EXISTS (
    SELECT 1 FROM role_authorization_objects rao 
    WHERE rao.role_id = (SELECT id FROM roles WHERE name = 'Admin') 
    AND rao.auth_object_id = ao.id
);