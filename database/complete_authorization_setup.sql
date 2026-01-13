-- Step 1: Add Configuration Authorization Objects
-- ==============================================

INSERT INTO authorization_objects (object_name, description, module) VALUES
('MM_MAT_GRP', 'Material Groups Configuration', 'materials'),
('MM_VEN_CAT', 'Vendor Categories Configuration', 'procurement'), 
('MM_PAY_TRM', 'Payment Terms Configuration', 'procurement'),
('MM_ACC_DET', 'Account Determination Configuration', 'materials'),
('SY_ERP_CFG', 'ERP Configuration Management', 'system');

-- Add authorization fields
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values) VALUES
((SELECT id FROM authorization_objects WHERE object_name = 'MM_MAT_GRP'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']),
((SELECT id FROM authorization_objects WHERE object_name = 'MM_VEN_CAT'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']),
((SELECT id FROM authorization_objects WHERE object_name = 'MM_PAY_TRM'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']),
((SELECT id FROM authorization_objects WHERE object_name = 'MM_ACC_DET'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']),
((SELECT id FROM authorization_objects WHERE object_name = 'SY_ERP_CFG'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']);

-- Step 2: Create Role Authorization Objects Table
-- ==============================================

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

CREATE INDEX IF NOT EXISTS idx_role_auth_objects_role ON role_authorization_objects(role_id);
CREATE INDEX IF NOT EXISTS idx_role_auth_objects_auth ON role_authorization_objects(auth_object_id);
CREATE INDEX IF NOT EXISTS idx_role_auth_objects_active ON role_authorization_objects(is_active);

-- Step 3: Assign New Objects to Admin Role (avoid duplicates)
-- ==========================================================

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