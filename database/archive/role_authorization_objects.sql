-- Role-Based Authorization Objects Assignment
-- ==========================================

-- Role Authorization Objects (Many-to-Many)
CREATE TABLE role_authorization_objects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    auth_object_id UUID NOT NULL REFERENCES authorization_objects(id) ON DELETE CASCADE,
    field_values JSONB NOT NULL, -- {"ACTVT": ["01", "02"], "BUKRS": ["C001", "C002"]}
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(role_id, auth_object_id)
);

-- Sample Role-Based Authorization Assignments
INSERT INTO role_authorization_objects (role_id, auth_object_id, field_values) VALUES
-- Admin Role - Full Access
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_CRE'), '{"ACTVT": ["01"], "PROJ_TYPE": ["*"], "BUKRS": ["*"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'F_PO_APP'), '{"ACTVT": ["05"], "PO_VALUE": ["*"], "BUKRS": ["*"], "EKORG": ["*"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'F_GL_POST'), '{"ACTVT": ["01", "02"], "GL_ACCT": ["*"], "BUKRS": ["*"]}'),

-- Manager Role - Project and Approval Access
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_CRE'), '{"ACTVT": ["01"], "PROJ_TYPE": ["commercial", "residential"], "BUKRS": ["C001"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'F_PO_APP'), '{"ACTVT": ["05"], "PO_VALUE": ["100000", "500000"], "BUKRS": ["C001"], "EKORG": ["PO01", "PO02"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'F_TIME_APP'), '{"ACTVT": ["05"], "BUKRS": ["C001"], "KOSTL": ["*"]}'),

-- Procurement Role - Purchasing Access
((SELECT id FROM roles WHERE name = 'Procurement'), (SELECT id FROM authorization_objects WHERE object_name = 'F_PO_CRE'), '{"ACTVT": ["01"], "PO_TYPE": ["standard", "blanket"], "BUKRS": ["C001", "C002"], "EKORG": ["PO01", "PO02"]}'),
((SELECT id FROM roles WHERE name = 'Procurement'), (SELECT id FROM authorization_objects WHERE object_name = 'F_MAT_CRE'), '{"ACTVT": ["01"], "MAT_TYPE": ["FERT", "ROH"], "BUKRS": ["*"], "WERKS": ["*"]}'),

-- Storekeeper Role - Inventory Access
((SELECT id FROM roles WHERE name = 'Storekeeper'), (SELECT id FROM authorization_objects WHERE object_name = 'F_GRN_POST'), '{"ACTVT": ["01"], "BUKRS": ["C001"], "WERKS": ["P001", "P002"]}'),
((SELECT id FROM roles WHERE name = 'Storekeeper'), (SELECT id FROM authorization_objects WHERE object_name = 'F_INV_DISP'), '{"ACTVT": ["03"], "BUKRS": ["C001"], "WERKS": ["P001", "P002"], "LGORT": ["0001", "0002"]}'),

-- Engineer Role - Limited Project Access
((SELECT id FROM roles WHERE name = 'Engineer'), (SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_CHG'), '{"ACTVT": ["02"], "PROJ_TYPE": ["*"], "BUKRS": ["C001"]}'),
((SELECT id FROM roles WHERE name = 'Engineer'), (SELECT id FROM authorization_objects WHERE object_name = 'F_WBS_MAINT'), '{"ACTVT": ["01", "02", "03"], "BUKRS": ["C001"], "WERKS": ["P001"]}'),

-- Finance Role - Financial Access
((SELECT id FROM roles WHERE name = 'Finance'), (SELECT id FROM authorization_objects WHERE object_name = 'F_GL_POST'), '{"ACTVT": ["01", "02"], "GL_ACCT": ["100000-199999", "400000-499999"], "BUKRS": ["C001"]}'),
((SELECT id FROM roles WHERE name = 'Finance'), (SELECT id FROM authorization_objects WHERE object_name = 'F_COST_DISP'), '{"ACTVT": ["03"], "BUKRS": ["C001"], "KOSTL": ["*"]}'),

-- HR Role - Human Resources Access
((SELECT id FROM roles WHERE name = 'HR'), (SELECT id FROM authorization_objects WHERE object_name = 'F_TIME_APP'), '{"ACTVT": ["05"], "BUKRS": ["*"], "KOSTL": ["*"]}'),
((SELECT id FROM roles WHERE name = 'HR'), (SELECT id FROM authorization_objects WHERE object_name = 'F_USER_MGMT'), '{"ACTVT": ["01", "02", "03"], "BUKRS": ["*"]}'),

-- Employee Role - Basic Access
((SELECT id FROM roles WHERE name = 'Employee'), (SELECT id FROM authorization_objects WHERE object_name = 'F_TIME_CRE'), '{"ACTVT": ["01"], "BUKRS": ["*"], "WERKS": ["*"]}');

-- Function to get user authorization objects through role
CREATE OR REPLACE FUNCTION get_user_auth_objects(user_id UUID)
RETURNS TABLE (
    object_name TEXT,
    field_values JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT ao.object_name, rao.field_values
    FROM users u
    JOIN roles r ON u.role_id = r.id
    JOIN role_authorization_objects rao ON r.id = rao.role_id
    JOIN authorization_objects ao ON rao.auth_object_id = ao.id
    WHERE u.id = user_id 
      AND rao.is_active = true
      AND ao.is_active = true
      AND (rao.valid_to IS NULL OR rao.valid_to >= CURRENT_DATE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check user authorization
CREATE OR REPLACE FUNCTION check_user_authorization(
    user_id UUID,
    auth_object TEXT,
    check_fields JSONB
) RETURNS BOOLEAN AS $$
DECLARE
    auth_record RECORD;
    field_key TEXT;
    field_values TEXT[];
    check_value TEXT;
BEGIN
    -- Get user's authorization for this object
    SELECT field_values INTO auth_record
    FROM get_user_auth_objects(user_id) 
    WHERE object_name = auth_object;
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- Check each field
    FOR field_key IN SELECT jsonb_object_keys(check_fields)
    LOOP
        -- Get authorized values for this field
        SELECT ARRAY(SELECT jsonb_array_elements_text(auth_record.field_values->field_key)) INTO field_values;
        
        -- Get value to check
        SELECT jsonb_extract_path_text(check_fields, field_key) INTO check_value;
        
        -- Check if authorized (wildcard * allows all)
        IF NOT ('*' = ANY(field_values) OR check_value = ANY(field_values)) THEN
            RETURN FALSE;
        END IF;
    END LOOP;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Indexes for performance
CREATE INDEX idx_role_auth_objects_role ON role_authorization_objects(role_id);
CREATE INDEX idx_role_auth_objects_auth ON role_authorization_objects(auth_object_id);
CREATE INDEX idx_role_auth_objects_active ON role_authorization_objects(is_active);