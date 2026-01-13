-- Configuration Authorization Objects with Proper Nomenclature
-- ===========================================================

-- Following existing patterns:
-- MM_ for Materials Management
-- SY_ for System Management  
-- Based on ERP Configuration tabs: Material Groups, Vendor Categories, Payment Terms, Account Determination

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

-- Note: Role assignments will be handled separately once role_authorization_objects table is created
-- For now, just creating the authorization objects and fields