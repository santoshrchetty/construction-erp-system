-- ADD TILES FOR NEW COMPONENTS
-- Following 4-layer architecture and SAP responsibility split

-- ========================================
-- SUPPLIER MASTER TILE
-- ========================================

INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
('Supplier Master', 'Manage supplier master data with state mapping for GST calculation', '🏢', 'MM', 'supplier-master', '/supplier-master', 'Master Data', 'SUPPLIER_MASTER')
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
-- PERIOD CONTROLS TILE
-- ========================================

INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
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
-- AUTHORIZATION OBJECTS FOR NEW TILES
-- ========================================

-- Supplier Master Authorization
INSERT INTO authorization_objects (auth_object, description, module_code) VALUES
('SUPPLIER_MASTER', 'Supplier Master Data Management', 'MM')
ON CONFLICT (auth_object) DO NOTHING;

-- Period Controls Authorization  
INSERT INTO authorization_objects (auth_object, description, module_code) VALUES
('PERIOD_CONTROLS', 'Financial Period Controls Management', 'FI')
ON CONFLICT (auth_object) DO NOTHING;

-- ========================================
-- ROLE ASSIGNMENTS (CONSULTANT LEVEL)
-- ========================================

-- Assign to CONSULTANT role (can configure master data)
INSERT INTO role_authorization_objects (role_name, auth_object, permission_level) VALUES
('CONSULTANT', 'SUPPLIER_MASTER', 'FULL'),
('CONSULTANT', 'PERIOD_CONTROLS', 'FULL')
ON CONFLICT (role_name, auth_object) DO NOTHING;

-- Assign to ADMIN role (full access)
INSERT INTO role_authorization_objects (role_name, auth_object, permission_level) VALUES
('ADMIN', 'SUPPLIER_MASTER', 'FULL'),
('ADMIN', 'PERIOD_CONTROLS', 'FULL')
ON CONFLICT (role_name, auth_object) DO NOTHING;

-- ========================================
-- VERIFICATION
-- ========================================

SELECT 'NEW TILES ADDED SUCCESSFULLY' as status;
SELECT title, construction_action, auth_object FROM tiles WHERE construction_action IN ('supplier-master', 'period-controls');
SELECT auth_object, description FROM authorization_objects WHERE auth_object IN ('SUPPLIER_MASTER', 'PERIOD_CONTROLS');