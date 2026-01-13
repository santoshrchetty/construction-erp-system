-- AUTHORIZATION OBJECTS - CORRECT COLUMN NAMES
-- Uses object_name and module instead of auth_object and module_code

-- ========================================
-- INSERT AUTHORIZATION OBJECTS
-- ========================================

INSERT INTO authorization_objects (object_name, description, module, is_active) VALUES
('MAT_READ', 'Material Master Data Read Access', 'MM', true),
('MAT_WRITE', 'Material Master Data Write Access', 'MM', true),
('SUP_READ', 'Supplier Master Data Read Access', 'MM', true),
('SUP_WRITE', 'Supplier Master Data Write Access', 'MM', true),
('PER_READ', 'Period Controls Read Access', 'FI', true),
('PER_WRITE', 'Period Controls Write Access', 'FI', true),
('PRJ_READ', 'Project Configuration Read Access', 'PS', true),
('PRJ_WRITE', 'Project Configuration Write Access', 'PS', true),
('WBS_MGMT', 'WBS Management Access', 'PS', true)
ON CONFLICT (object_name) DO NOTHING;

SELECT 'AUTHORIZATION OBJECTS CREATED SUCCESSFULLY' as status;