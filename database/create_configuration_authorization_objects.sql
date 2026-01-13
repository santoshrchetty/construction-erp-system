-- Configuration Category Authorization Objects
-- ============================================

-- Insert Configuration Authorization Objects
INSERT INTO authorization_objects (object_name, description, module) VALUES
-- ERP Configuration Objects
('F_ERP_CONF', 'ERP Configuration Display', 'configuration'),
('F_MAT_CONF', 'Material Groups Configuration', 'configuration'),
('F_VEND_CONF', 'Vendor Categories Configuration', 'configuration'),
('F_PAY_CONF', 'Payment Terms Configuration', 'configuration'),
('F_ACCT_CONF', 'Account Determination Configuration', 'configuration'),

-- System Configuration Objects
('F_SYS_CONF', 'System Configuration', 'configuration'),
('F_USER_MGMT', 'User Management', 'configuration'),
('F_ROLE_MGMT', 'Role Management', 'configuration'),
('F_AUTH_MGMT', 'Authorization Management', 'configuration');

-- Insert Authorization Fields for Configuration Objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values) VALUES

-- F_ERP_CONF fields
((SELECT id FROM authorization_objects WHERE object_name = 'F_ERP_CONF'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_ERP_CONF'), 'BUKRS', 'Company Code', ARRAY['C001', 'C002', 'C003', 'C004', '*']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_ERP_CONF'), 'CONFIG_TYPE', 'Configuration Type', ARRAY['MATERIAL', 'VENDOR', 'PAYMENT', 'ACCOUNT', '*']),

-- F_MAT_CONF fields
((SELECT id FROM authorization_objects WHERE object_name = 'F_MAT_CONF'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_MAT_CONF'), 'BUKRS', 'Company Code', ARRAY['C001', 'C002', 'C003', 'C004', '*']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_MAT_CONF'), 'MAT_GROUP', 'Material Group', ARRAY['*']),

-- F_VEND_CONF fields
((SELECT id FROM authorization_objects WHERE object_name = 'F_VEND_CONF'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_VEND_CONF'), 'BUKRS', 'Company Code', ARRAY['C001', 'C002', 'C003', 'C004', '*']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_VEND_CONF'), 'VEND_CAT', 'Vendor Category', ARRAY['*']),

-- F_PAY_CONF fields
((SELECT id FROM authorization_objects WHERE object_name = 'F_PAY_CONF'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_PAY_CONF'), 'BUKRS', 'Company Code', ARRAY['C001', 'C002', 'C003', 'C004', '*']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_PAY_CONF'), 'PAY_TERM', 'Payment Term', ARRAY['*']),

-- F_ACCT_CONF fields
((SELECT id FROM authorization_objects WHERE object_name = 'F_ACCT_CONF'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_ACCT_CONF'), 'BUKRS', 'Company Code', ARRAY['C001', 'C002', 'C003', 'C004', '*']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_ACCT_CONF'), 'GL_ACCT', 'GL Account Range', ARRAY['100000-199999', '200000-299999', '400000-499999', '*']),

-- F_SYS_CONF fields
((SELECT id FROM authorization_objects WHERE object_name = 'F_SYS_CONF'), 'ACTVT', 'Activity', ARRAY['01', '02', '03']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_SYS_CONF'), 'SYS_PARAM', 'System Parameter', ARRAY['*']),

-- F_USER_MGMT fields
((SELECT id FROM authorization_objects WHERE object_name = 'F_USER_MGMT'), 'ACTVT', 'Activity', ARRAY['01', '02', '03', '06']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_USER_MGMT'), 'BUKRS', 'Company Code', ARRAY['C001', 'C002', 'C003', 'C004', '*']),

-- F_ROLE_MGMT fields
((SELECT id FROM authorization_objects WHERE object_name = 'F_ROLE_MGMT'), 'ACTVT', 'Activity', ARRAY['01', '02', '03', '06']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_ROLE_MGMT'), 'ROLE_TYPE', 'Role Type', ARRAY['ADMIN', 'MANAGER', 'USER', '*']),

-- F_AUTH_MGMT fields
((SELECT id FROM authorization_objects WHERE object_name = 'F_AUTH_MGMT'), 'ACTVT', 'Activity', ARRAY['01', '02', '03', '06']),
((SELECT id FROM authorization_objects WHERE object_name = 'F_AUTH_MGMT'), 'AUTH_OBJ', 'Authorization Object', ARRAY['*']);

-- Add Configuration Authorization Assignments to Roles
INSERT INTO role_authorization_objects (role_id, auth_object_id, field_values) VALUES

-- Admin Role - Full Configuration Access
((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_ERP_CONF'), 
 '{"ACTVT": ["01", "02", "03"], "BUKRS": ["*"], "CONFIG_TYPE": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_MAT_CONF'), 
 '{"ACTVT": ["01", "02", "03"], "BUKRS": ["*"], "MAT_GROUP": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_VEND_CONF'), 
 '{"ACTVT": ["01", "02", "03"], "BUKRS": ["*"], "VEND_CAT": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PAY_CONF'), 
 '{"ACTVT": ["01", "02", "03"], "BUKRS": ["*"], "PAY_TERM": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_ACCT_CONF'), 
 '{"ACTVT": ["01", "02", "03"], "BUKRS": ["*"], "GL_ACCT": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_SYS_CONF'), 
 '{"ACTVT": ["01", "02", "03"], "SYS_PARAM": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_USER_MGMT'), 
 '{"ACTVT": ["01", "02", "03", "06"], "BUKRS": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_ROLE_MGMT'), 
 '{"ACTVT": ["01", "02", "03", "06"], "ROLE_TYPE": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Admin'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_AUTH_MGMT'), 
 '{"ACTVT": ["01", "02", "03", "06"], "AUTH_OBJ": ["*"]}'),

-- Manager Role - Limited Configuration Access
((SELECT id FROM roles WHERE name = 'Manager'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_ERP_CONF'), 
 '{"ACTVT": ["03"], "BUKRS": ["C001"], "CONFIG_TYPE": ["MATERIAL", "VENDOR", "PAYMENT"]}'),

((SELECT id FROM roles WHERE name = 'Manager'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_MAT_CONF'), 
 '{"ACTVT": ["03"], "BUKRS": ["C001"], "MAT_GROUP": ["*"]}'),

-- Finance Role - Payment and Account Configuration
((SELECT id FROM roles WHERE name = 'Finance'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PAY_CONF'), 
 '{"ACTVT": ["01", "02", "03"], "BUKRS": ["C001"], "PAY_TERM": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Finance'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_ACCT_CONF'), 
 '{"ACTVT": ["01", "02", "03"], "BUKRS": ["C001"], "GL_ACCT": ["*"]}'),

-- Procurement Role - Vendor Configuration
((SELECT id FROM roles WHERE name = 'Procurement'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_VEND_CONF'), 
 '{"ACTVT": ["01", "02", "03"], "BUKRS": ["C001", "C002"], "VEND_CAT": ["*"]}'),

((SELECT id FROM roles WHERE name = 'Procurement'), 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_MAT_CONF'), 
 '{"ACTVT": ["03"], "BUKRS": ["C001", "C002"], "MAT_GROUP": ["*"]}');

-- Verify Configuration Authorization Objects
SELECT 
    'Configuration Authorization Objects Created:' as status,
    object_name,
    description,
    module,
    is_active
FROM authorization_objects 
WHERE module = 'configuration'
ORDER BY object_name;