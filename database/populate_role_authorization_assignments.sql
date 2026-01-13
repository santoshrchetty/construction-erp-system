-- Populate Role Authorization Objects Assignments
-- ===============================================

-- First, check if role_authorization_objects table exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'role_authorization_objects') THEN
        -- Create the table if it doesn't exist
        CREATE TABLE role_authorization_objects (
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
        CREATE INDEX idx_role_auth_objects_role ON role_authorization_objects(role_id);
        CREATE INDEX idx_role_auth_objects_auth ON role_authorization_objects(auth_object_id);
        CREATE INDEX idx_role_auth_objects_active ON role_authorization_objects(is_active);
    END IF;
END
$$;

-- Clear existing assignments to avoid duplicates
DELETE FROM role_authorization_objects;

-- Insert comprehensive role authorization assignments
INSERT INTO role_authorization_objects (role_id, auth_object_id, field_values) VALUES

-- Admin Role - Full Access to All Objects
((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_CRE'), 
 '{"ACTVT": ["01"], "PROJ_TYPE": ["*"], "BUKRS": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_CHG'), 
 '{"ACTVT": ["02"], "PROJ_TYPE": ["*"], "BUKRS": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_DIS'), 
 '{"ACTVT": ["03"], "PROJ_TYPE": ["*"], "BUKRS": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PO_CRE'), 
 '{"ACTVT": ["01"], "PO_TYPE": ["*"], "BUKRS": ["*"], "EKORG": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PO_CHG'), 
 '{"ACTVT": ["02"], "PO_TYPE": ["*"], "BUKRS": ["*"], "EKORG": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PO_APP'), 
 '{"ACTVT": ["05"], "PO_VALUE": ["*"], "BUKRS": ["*"], "EKORG": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_MAT_CRE'), 
 '{"ACTVT": ["01"], "MAT_TYPE": ["*"], "BUKRS": ["*"], "WERKS": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_INV_DIS'), 
 '{"ACTVT": ["03"], "BUKRS": ["*"], "WERKS": ["*"], "LGORT": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_GRN_CRE'), 
 '{"ACTVT": ["01"], "BUKRS": ["*"], "WERKS": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_TIME_CRE'), 
 '{"ACTVT": ["01"], "BUKRS": ["*"], "WERKS": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_TIME_APP'), 
 '{"ACTVT": ["05"], "BUKRS": ["*"], "KOSTL": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_COST_DIS'), 
 '{"ACTVT": ["03"], "BUKRS": ["*"], "KOSTL": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_BUDG_CHG'), 
 '{"ACTVT": ["02"], "BUKRS": ["*"]}'),

-- Manager Role - Project and Approval Access
((SELECT id FROM roles WHERE name = 'Manager'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_CRE'), 
 '{"ACTVT": ["01"], "PROJ_TYPE": ["commercial", "residential"], "BUKRS": ["C001"]}'),

((SELECT id FROM roles WHERE name = 'Manager'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_CHG'), 
 '{"ACTVT": ["02"], "PROJ_TYPE": ["commercial", "residential"], "BUKRS": ["C001"]}'),

((SELECT id FROM roles WHERE name = 'Manager'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_DIS'), 
 '{"ACTVT": ["03"], "PROJ_TYPE": ["*"], "BUKRS": ["C001"]}'),

((SELECT id FROM roles WHERE name = 'Manager'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PO_APP'), 
 '{"ACTVT": ["05"], "PO_VALUE": ["100000", "500000"], "BUKRS": ["C001"], "EKORG": ["PO01", "PO02"]}'),

((SELECT id FROM roles WHERE name = 'Manager'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_TIME_APP'), 
 '{"ACTVT": ["05"], "BUKRS": ["C001"], "KOSTL": ["*"]}'),

-- Procurement Role - Purchasing Access
((SELECT id FROM roles WHERE name = 'Procurement'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PO_CRE'), 
 '{"ACTVT": ["01"], "PO_TYPE": ["standard", "blanket"], "BUKRS": ["C001", "C002"], "EKORG": ["PO01", "PO02"]}'),

((SELECT id FROM roles WHERE name = 'Procurement'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PO_CHG'), 
 '{"ACTVT": ["02"], "PO_TYPE": ["standard", "blanket"], "BUKRS": ["C001", "C002"], "EKORG": ["PO01", "PO02"]}'),

((SELECT id FROM roles WHERE name = 'Procurement'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_MAT_CRE'), 
 '{"ACTVT": ["01"], "MAT_TYPE": ["FERT", "ROH"], "BUKRS": ["*"], "WERKS": ["*"]}'),

-- Storekeeper Role - Inventory Access
((SELECT id FROM roles WHERE name = 'Storekeeper'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_GRN_CRE'), 
 '{"ACTVT": ["01"], "BUKRS": ["C001"], "WERKS": ["P001", "P002"]}'),

((SELECT id FROM roles WHERE name = 'Storekeeper'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_INV_DIS'), 
 '{"ACTVT": ["03"], "BUKRS": ["C001"], "WERKS": ["P001", "P002"], "LGORT": ["0001", "0002"]}'),

-- Engineer Role - Limited Project Access
((SELECT id FROM roles WHERE name = 'Engineer'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_CHG'), 
 '{"ACTVT": ["02"], "PROJ_TYPE": ["*"], "BUKRS": ["C001"]}'),

((SELECT id FROM roles WHERE name = 'Engineer'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_DIS'), 
 '{"ACTVT": ["03"], "PROJ_TYPE": ["*"], "BUKRS": ["C001"]}'),

-- Finance Role - Financial Access
((SELECT id FROM roles WHERE name = 'Finance'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_COST_DIS'), 
 '{"ACTVT": ["03"], "BUKRS": ["C001"], "KOSTL": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Finance'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_BUDG_CHG'), 
 '{"ACTVT": ["02"], "BUKRS": ["C001"]}'),

-- HR Role - Human Resources Access
((SELECT id FROM roles WHERE name = 'HR'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_TIME_APP'), 
 '{"ACTVT": ["05"], "BUKRS": ["*"], "KOSTL": ["*"]}'),

-- Employee Role - Basic Access
((SELECT id FROM roles WHERE name = 'Employee'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_TIME_CRE'), 
 '{"ACTVT": ["01"], "BUKRS": ["*"], "WERKS": ["*"]}');

-- Verify the assignments
SELECT 
    'Role Authorization Assignments Created:' as status,
    r.name as role_name,
    ao.object_name,
    ao.description,
    rao.field_values,
    rao.is_active
FROM role_authorization_objects rao
JOIN roles r ON rao.role_id = r.id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
ORDER BY r.name, ao.object_name;