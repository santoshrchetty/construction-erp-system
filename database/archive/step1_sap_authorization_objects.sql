-- Step 1: SAP-Style Authorization Objects Schema
-- =====================================================

-- Authorization Objects (SAP-style)
CREATE TABLE authorization_objects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    object_name VARCHAR(10) UNIQUE NOT NULL, -- e.g., 'F_PROJ_CRE'
    description TEXT NOT NULL,
    module VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Authorization Fields for each object
CREATE TABLE authorization_fields (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_object_id UUID NOT NULL REFERENCES authorization_objects(id) ON DELETE CASCADE,
    field_name VARCHAR(10) NOT NULL, -- e.g., 'ACTVT', 'PROJ_TYPE'
    field_description TEXT,
    field_values TEXT[] NOT NULL, -- ['01', '02', '03'] for Create/Change/Display
    is_required BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(auth_object_id, field_name)
);

-- User Authorization Assignments
CREATE TABLE user_authorizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    auth_object_id UUID NOT NULL REFERENCES authorization_objects(id),
    field_values JSONB NOT NULL, -- {"ACTVT": ["01", "02"], "PROJ_TYPE": ["commercial"]}
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, auth_object_id)
);

-- Insert Core Authorization Objects
INSERT INTO authorization_objects (object_name, description, module) VALUES
-- Project Management
('F_PROJ_CRE', 'Project Creation Authorization', 'projects'),
('F_PROJ_CHG', 'Project Change Authorization', 'projects'),
('F_PROJ_DIS', 'Project Display Authorization', 'projects'),

-- Purchase Orders
('F_PO_CRE', 'Purchase Order Creation', 'procurement'),
('F_PO_CHG', 'Purchase Order Change', 'procurement'),
('F_PO_APP', 'Purchase Order Approval', 'procurement'),

-- Materials Management
('F_MAT_CRE', 'Material Master Creation', 'materials'),
('F_INV_DIS', 'Inventory Display', 'inventory'),
('F_GRN_CRE', 'Goods Receipt Creation', 'inventory'),

-- Timesheets
('F_TIME_CRE', 'Timesheet Creation', 'timesheets'),
('F_TIME_APP', 'Timesheet Approval', 'timesheets'),

-- Financial
('F_COST_DIS', 'Cost Display', 'finance'),
('F_BUDG_CHG', 'Budget Change', 'finance');

-- Insert Authorization Fields
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values) VALUES
-- Activity field (standard SAP activities)
((SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_CRE'), 'ACTVT', 'Activity', ARRAY['01']), -- Create only
((SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_CHG'), 'ACTVT', 'Activity', ARRAY['02']), -- Change only
((SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_DIS'), 'ACTVT', 'Activity', ARRAY['03']), -- Display only
((SELECT id FROM authorization_objects WHERE object_name = 'F_PO_APP'), 'ACTVT', 'Activity', ARRAY['05']), -- Approve only

-- Project Type field
((SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_CRE'), 'PROJ_TYPE', 'Project Type', ARRAY['commercial', 'residential', 'infrastructure']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_CHG'), 'PROJ_TYPE', 'Project Type', ARRAY['commercial', 'residential', 'infrastructure']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_DIS'), 'PROJ_TYPE', 'Project Type', ARRAY['commercial', 'residential', 'infrastructure']),

-- Purchase Order Type
((SELECT id FROM authorization_objects WHERE object_name = 'F_PO_CRE'), 'PO_TYPE', 'PO Type', ARRAY['standard', 'blanket', 'contract']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_PO_CHG'), 'PO_TYPE', 'PO Type', ARRAY['standard', 'blanket', 'contract']);

-- Create indexes for performance
CREATE INDEX idx_auth_objects_module ON authorization_objects(module);
CREATE INDEX idx_auth_fields_object ON authorization_fields(auth_object_id);
CREATE INDEX idx_user_auth_user ON user_authorizations(user_id);
CREATE INDEX idx_user_auth_object ON user_authorizations(auth_object_id);