-- COMPLETE AUTHORIZATION OBJECTS FOR NEW COMPONENTS
-- All authorization objects needed for the 6 implemented components

-- ========================================
-- MATERIAL MASTER AUTHORIZATION
-- ========================================

INSERT INTO authorization_objects (auth_object, description, module_code) VALUES
('MATERIAL_MASTER_READ', 'Material Master Data Read Access', 'MM'),
('MATERIAL_MASTER_WRITE', 'Material Master Data Write Access', 'MM')
ON CONFLICT (auth_object) DO NOTHING;

-- ========================================
-- SUPPLIER MASTER AUTHORIZATION  
-- ========================================

INSERT INTO authorization_objects (auth_object, description, module_code) VALUES
('SUPPLIER_MASTER_READ', 'Supplier Master Data Read Access', 'MM'),
('SUPPLIER_MASTER_WRITE', 'Supplier Master Data Write Access', 'MM')
ON CONFLICT (auth_object) DO NOTHING;

-- ========================================
-- PERIOD CONTROLS AUTHORIZATION
-- ========================================

INSERT INTO authorization_objects (auth_object, description, module_code) VALUES
('PERIOD_CONTROLS_READ', 'Period Controls Read Access', 'FI'),
('PERIOD_CONTROLS_WRITE', 'Period Controls Write Access', 'FI')
ON CONFLICT (auth_object) DO NOTHING;

-- ========================================
-- PROJECT CONFIGURATION AUTHORIZATION
-- ========================================

INSERT INTO authorization_objects (auth_object, description, module_code) VALUES
('PROJECT_CONFIG_READ', 'Project Configuration Read Access', 'PS'),
('PROJECT_CONFIG_WRITE', 'Project Configuration Write Access', 'PS')
ON CONFLICT (auth_object) DO NOTHING;

-- ========================================
-- ROLE ASSIGNMENTS
-- ========================================

-- CONSULTANT Role (Configuration Level)
INSERT INTO role_authorization_objects (role_name, auth_object, permission_level) VALUES
('CONSULTANT', 'MATERIAL_MASTER_READ', 'FULL'),
('CONSULTANT', 'MATERIAL_MASTER_WRITE', 'FULL'),
('CONSULTANT', 'SUPPLIER_MASTER_READ', 'FULL'),
('CONSULTANT', 'SUPPLIER_MASTER_WRITE', 'FULL'),
('CONSULTANT', 'PERIOD_CONTROLS_READ', 'FULL'),
('CONSULTANT', 'PERIOD_CONTROLS_WRITE', 'FULL'),
('CONSULTANT', 'PROJECT_CONFIG_READ', 'FULL'),
('CONSULTANT', 'PROJECT_CONFIG_WRITE', 'FULL')
ON CONFLICT (role_name, auth_object) DO NOTHING;

-- END_USER Role (Operational Level)
INSERT INTO role_authorization_objects (role_name, auth_object, permission_level) VALUES
('END_USER', 'MATERIAL_MASTER_READ', 'READ'),
('END_USER', 'SUPPLIER_MASTER_READ', 'READ'),
('END_USER', 'PROJECT_CONFIG_READ', 'READ')
ON CONFLICT (role_name, auth_object) DO NOTHING;

-- ADMIN Role (Full Access)
INSERT INTO role_authorization_objects (role_name, auth_object, permission_level) VALUES
('ADMIN', 'MATERIAL_MASTER_READ', 'FULL'),
('ADMIN', 'MATERIAL_MASTER_WRITE', 'FULL'),
('ADMIN', 'SUPPLIER_MASTER_READ', 'FULL'),
('ADMIN', 'SUPPLIER_MASTER_WRITE', 'FULL'),
('ADMIN', 'PERIOD_CONTROLS_READ', 'FULL'),
('ADMIN', 'PERIOD_CONTROLS_WRITE', 'FULL'),
('ADMIN', 'PROJECT_CONFIG_READ', 'FULL'),
('ADMIN', 'PROJECT_CONFIG_WRITE', 'FULL')
ON CONFLICT (role_name, auth_object) DO NOTHING;

-- ========================================
-- VERIFICATION
-- ========================================

SELECT 'AUTHORIZATION OBJECTS CREATED' as status;
SELECT auth_object, description, module_code FROM authorization_objects 
WHERE auth_object IN (
  'MATERIAL_MASTER_READ', 'MATERIAL_MASTER_WRITE',
  'SUPPLIER_MASTER_READ', 'SUPPLIER_MASTER_WRITE', 
  'PERIOD_CONTROLS_READ', 'PERIOD_CONTROLS_WRITE',
  'PROJECT_CONFIG_READ', 'PROJECT_CONFIG_WRITE'
);