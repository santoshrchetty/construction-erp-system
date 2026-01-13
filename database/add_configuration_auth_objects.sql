-- Add Missing Configuration Authorization Objects
-- ============================================

INSERT INTO authorization_objects (object_name, description, module) VALUES
('F_ERP_CONF', 'ERP Configuration Management', 'configuration'),
('F_MAT_CONF', 'Material Groups Configuration', 'configuration'),
('F_VEN_CONF', 'Vendor Categories Configuration', 'configuration'),
('F_PAY_CONF', 'Payment Terms Configuration', 'configuration'),
('F_ACC_CONF', 'Account Determination Configuration', 'configuration');

-- Add fields for configuration objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values) VALUES
((SELECT id FROM authorization_objects WHERE object_name = 'F_ERP_CONF'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_ERP_CONF'), 'BUKRS', 'Company Code', ARRAY['C001', 'C002', '*']),

((SELECT id FROM authorization_objects WHERE object_name = 'F_MAT_CONF'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_VEN_CONF'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_PAY_CONF'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_ACC_CONF'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']);

-- Assign to Admin role
INSERT INTO role_authorization_objects (role_id, auth_object_id, field_values) VALUES
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'F_ERP_CONF'), '{"ACTVT": ["01", "02", "03"], "BUKRS": ["*"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'F_MAT_CONF'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'F_VEN_CONF'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'F_PAY_CONF'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'F_ACC_CONF'), '{"ACTVT": ["01", "02", "03"]}');