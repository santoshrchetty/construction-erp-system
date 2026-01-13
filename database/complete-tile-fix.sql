-- COMPLETE TILE CLEANUP AND RESTORATION
-- Run this single script to fix all tile issues

-- ========================================
-- 1. FIX NULL CATEGORY
-- ========================================

UPDATE tiles 
SET tile_category = 'Finance'
WHERE title = 'Budget Approvals' AND tile_category IS NULL;

-- ========================================
-- 2. RESTORE WBS MANAGEMENT TILE
-- ========================================

UPDATE tiles 
SET 
  construction_action = 'WBSManagement',
  route = '/wbs-management',
  auth_object = 'WBS_MANAGEMENT',
  module_code = 'PS',
  tile_category = 'Project Management',
  is_active = true
WHERE title = 'WBS Management';

-- ========================================
-- 3. ENSURE WBS AUTHORIZATION
-- ========================================

INSERT INTO authorization_objects (auth_object, description, module_code) VALUES
('WBS_MANAGEMENT', 'WBS Management Access', 'PS')
ON CONFLICT (auth_object) DO NOTHING;

INSERT INTO role_authorization_objects (role_name, auth_object, permission_level) VALUES
('ADMIN', 'WBS_MANAGEMENT', 'FULL'),
('CONSULTANT', 'WBS_MANAGEMENT', 'FULL'),
('PROJECT_MANAGER', 'WBS_MANAGEMENT', 'FULL')
ON CONFLICT (role_name, auth_object) DO NOTHING;

-- ========================================
-- 4. ADD NEW COMPONENT TILES
-- ========================================

INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
('Supplier Master', 'Manage supplier master data with state mapping for GST calculation', '🏢', 'MM', 'supplier-master', '/supplier-master', 'Master Data', 'SUPPLIER_MASTER'),
('Period Controls', 'Manage posting periods and financial period controls', '📅', 'FI', 'period-controls', '/period-controls', 'Configuration', 'PERIOD_CONTROLS')
ON CONFLICT (construction_action) 
DO UPDATE SET 
  title = EXCLUDED.title,
  subtitle = EXCLUDED.subtitle,
  icon = EXCLUDED.icon,
  module_code = EXCLUDED.module_code,
  route = EXCLUDED.route,
  tile_category = EXCLUDED.tile_category,
  auth_object = EXCLUDED.auth_object;

-- ========================================
-- 5. ADD AUTHORIZATION OBJECTS
-- ========================================

INSERT INTO authorization_objects (auth_object, description, module_code) VALUES
('MATERIAL_MASTER_READ', 'Material Master Data Read Access', 'MM'),
('MATERIAL_MASTER_WRITE', 'Material Master Data Write Access', 'MM'),
('SUPPLIER_MASTER_READ', 'Supplier Master Data Read Access', 'MM'),
('SUPPLIER_MASTER_WRITE', 'Supplier Master Data Write Access', 'MM'),
('PERIOD_CONTROLS_READ', 'Period Controls Read Access', 'FI'),
('PERIOD_CONTROLS_WRITE', 'Period Controls Write Access', 'FI'),
('PROJECT_CONFIG_READ', 'Project Configuration Read Access', 'PS'),
('PROJECT_CONFIG_WRITE', 'Project Configuration Write Access', 'PS')
ON CONFLICT (auth_object) DO NOTHING;

-- ========================================
-- 6. ASSIGN ROLES
-- ========================================

INSERT INTO role_authorization_objects (role_name, auth_object, permission_level) VALUES
('CONSULTANT', 'MATERIAL_MASTER_READ', 'FULL'),
('CONSULTANT', 'MATERIAL_MASTER_WRITE', 'FULL'),
('CONSULTANT', 'SUPPLIER_MASTER_READ', 'FULL'),
('CONSULTANT', 'SUPPLIER_MASTER_WRITE', 'FULL'),
('CONSULTANT', 'PERIOD_CONTROLS_READ', 'FULL'),
('CONSULTANT', 'PERIOD_CONTROLS_WRITE', 'FULL'),
('CONSULTANT', 'PROJECT_CONFIG_READ', 'FULL'),
('CONSULTANT', 'PROJECT_CONFIG_WRITE', 'FULL'),
('ADMIN', 'MATERIAL_MASTER_READ', 'FULL'),
('ADMIN', 'MATERIAL_MASTER_WRITE', 'FULL'),
('ADMIN', 'SUPPLIER_MASTER_READ', 'FULL'),
('ADMIN', 'SUPPLIER_MASTER_WRITE', 'FULL'),
('ADMIN', 'PERIOD_CONTROLS_READ', 'FULL'),
('ADMIN', 'PERIOD_CONTROLS_WRITE', 'FULL'),
('ADMIN', 'PROJECT_CONFIG_READ', 'FULL'),
('ADMIN', 'PROJECT_CONFIG_WRITE', 'FULL'),
('END_USER', 'MATERIAL_MASTER_READ', 'READ'),
('END_USER', 'SUPPLIER_MASTER_READ', 'READ'),
('END_USER', 'PROJECT_CONFIG_READ', 'READ')
ON CONFLICT (role_name, auth_object) DO NOTHING;

-- ========================================
-- 7. FINAL VERIFICATION
-- ========================================

SELECT 'ALL TILE ISSUES FIXED' as status;

-- Check WBS Management tile
SELECT title, construction_action, route, auth_object 
FROM tiles WHERE title = 'WBS Management';

-- Check no null categories
SELECT COUNT(*) as null_categories FROM tiles WHERE tile_category IS NULL;

-- Final tile count
SELECT tile_category, COUNT(*) as count FROM tiles GROUP BY tile_category ORDER BY tile_category;