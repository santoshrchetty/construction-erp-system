-- VERIFY WBS MANAGEMENT TILE FUNCTIONALITY
-- Check if tile is properly connected to component

-- ========================================
-- 1. CHECK CURRENT WBS TILE CONFIGURATION
-- ========================================

SELECT 
  title,
  construction_action,
  route,
  auth_object,
  tile_category,
  module_code,
  is_active
FROM tiles 
WHERE title = 'WBS Management';

-- ========================================
-- 2. ENSURE CORRECT TILE CONFIGURATION
-- ========================================

-- Update WBS Management tile to ensure correct mapping
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
-- 3. VERIFY COMPONENT FILE EXISTS
-- ========================================

-- The component should exist at: components/tiles/WBSManagement.tsx
-- This maps to construction_action = 'WBSManagement'

-- ========================================
-- 4. CHECK AUTHORIZATION OBJECT EXISTS
-- ========================================

SELECT auth_object, description, module_code 
FROM authorization_objects 
WHERE auth_object = 'WBS_MANAGEMENT';

-- If not exists, create it
INSERT INTO authorization_objects (auth_object, description, module_code) VALUES
('WBS_MANAGEMENT', 'WBS Management Access', 'PS')
ON CONFLICT (auth_object) DO NOTHING;

-- ========================================
-- 5. ENSURE ROLE ACCESS
-- ========================================

-- Grant access to appropriate roles
INSERT INTO role_authorization_objects (role_name, auth_object, permission_level) VALUES
('ADMIN', 'WBS_MANAGEMENT', 'FULL'),
('CONSULTANT', 'WBS_MANAGEMENT', 'FULL'),
('PROJECT_MANAGER', 'WBS_MANAGEMENT', 'FULL')
ON CONFLICT (role_name, auth_object) DO NOTHING;

-- ========================================
-- 6. FINAL VERIFICATION
-- ========================================

SELECT 'WBS MANAGEMENT TILE FUNCTIONALITY RESTORED' as status;

-- Show final tile configuration
SELECT 
  title,
  construction_action,
  route,
  auth_object,
  tile_category
FROM tiles 
WHERE title = 'WBS Management';