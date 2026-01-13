-- Step 2: Map Existing Permissions to SAP Activities
-- ==================================================

-- Create role-to-authorization mapping table
CREATE TABLE role_authorization_mapping (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name VARCHAR(50) NOT NULL,
    auth_object_name VARCHAR(10) NOT NULL,
    field_values JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(role_name, auth_object_name)
);

-- Map existing roles to SAP authorization objects
INSERT INTO role_authorization_mapping (role_name, auth_object_name, field_values) VALUES

-- ADMIN - Full access to everything
('Admin', 'F_PROJ_CRE', '{"ACTVT": ["01"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Admin', 'F_PROJ_CHG', '{"ACTVT": ["02"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Admin', 'F_PROJ_DIS', '{"ACTVT": ["03"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Admin', 'F_PO_CRE', '{"ACTVT": ["01"], "PO_TYPE": ["standard", "blanket", "contract"]}'),
('Admin', 'F_PO_CHG', '{"ACTVT": ["02"], "PO_TYPE": ["standard", "blanket", "contract"]}'),
('Admin', 'F_PO_APP', '{"ACTVT": ["05"], "PO_TYPE": ["standard", "blanket", "contract"]}'),
('Admin', 'F_MAT_CRE', '{"ACTVT": ["01"]}'),
('Admin', 'F_INV_DIS', '{"ACTVT": ["03"]}'),
('Admin', 'F_GRN_CRE', '{"ACTVT": ["01"]}'),
('Admin', 'F_TIME_CRE', '{"ACTVT": ["01"]}'),
('Admin', 'F_TIME_APP', '{"ACTVT": ["05"]}'),
('Admin', 'F_COST_DIS', '{"ACTVT": ["03"]}'),
('Admin', 'F_BUDG_CHG', '{"ACTVT": ["02"]}'),

-- MANAGER - Project management and approvals
('Manager', 'F_PROJ_CRE', '{"ACTVT": ["01"], "PROJ_TYPE": ["commercial", "residential"]}'),
('Manager', 'F_PROJ_CHG', '{"ACTVT": ["02"], "PROJ_TYPE": ["commercial", "residential"]}'),
('Manager', 'F_PROJ_DIS', '{"ACTVT": ["03"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Manager', 'F_PO_APP', '{"ACTVT": ["05"], "PO_TYPE": ["standard", "blanket"]}'),
('Manager', 'F_TIME_APP', '{"ACTVT": ["05"]}'),
('Manager', 'F_COST_DIS', '{"ACTVT": ["03"]}'),

-- PROCUREMENT - Purchase orders and vendors
('Procurement', 'F_PROJ_DIS', '{"ACTVT": ["03"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Procurement', 'F_PO_CRE', '{"ACTVT": ["01"], "PO_TYPE": ["standard", "blanket", "contract"]}'),
('Procurement', 'F_PO_CHG', '{"ACTVT": ["02"], "PO_TYPE": ["standard", "blanket", "contract"]}'),
('Procurement', 'F_MAT_CRE', '{"ACTVT": ["01"]}'),
('Procurement', 'F_INV_DIS', '{"ACTVT": ["03"]}'),

-- STOREKEEPER - Inventory and goods receipt
('Storekeeper', 'F_PROJ_DIS', '{"ACTVT": ["03"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Storekeeper', 'F_GRN_CRE', '{"ACTVT": ["01"]}'),
('Storekeeper', 'F_INV_DIS', '{"ACTVT": ["03"]}'),

-- ENGINEER - Limited project access and progress
('Engineer', 'F_PROJ_DIS', '{"ACTVT": ["03"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Engineer', 'F_TIME_CRE', '{"ACTVT": ["01"]}'),

-- FINANCE - Cost and budget access
('Finance', 'F_PROJ_DIS', '{"ACTVT": ["03"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Finance', 'F_PO_APP', '{"ACTVT": ["05"], "PO_TYPE": ["standard", "blanket", "contract"]}'),
('Finance', 'F_COST_DIS', '{"ACTVT": ["03"]}'),
('Finance', 'F_BUDG_CHG', '{"ACTVT": ["02"]}'),

-- HR - Timesheet approvals and employee management
('HR', 'F_PROJ_DIS', '{"ACTVT": ["03"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('HR', 'F_TIME_APP', '{"ACTVT": ["05"]}'),

-- EMPLOYEE - Basic timesheet creation
('Employee', 'F_PROJ_DIS', '{"ACTVT": ["03"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Employee', 'F_TIME_CRE', '{"ACTVT": ["01"]}');

-- Create function to auto-assign authorizations based on role
CREATE OR REPLACE FUNCTION assign_role_authorizations(p_user_id UUID, p_role_name VARCHAR(50))
RETURNS VOID AS $$
DECLARE
    mapping_record RECORD;
BEGIN
    -- Clear existing authorizations for this user
    DELETE FROM user_authorizations WHERE user_id = p_user_id;
    
    -- Assign new authorizations based on role
    FOR mapping_record IN 
        SELECT ram.auth_object_name, ram.field_values, ao.id as auth_object_id
        FROM role_authorization_mapping ram
        JOIN authorization_objects ao ON ram.auth_object_name = ao.object_name
        WHERE ram.role_name = p_role_name
    LOOP
        INSERT INTO user_authorizations (user_id, auth_object_id, field_values)
        VALUES (p_user_id, mapping_record.auth_object_id, mapping_record.field_values)
        ON CONFLICT (user_id, auth_object_id) DO UPDATE SET
            field_values = EXCLUDED.field_values;
    END LOOP;
END;
$$ LANGUAGE plpgsql;