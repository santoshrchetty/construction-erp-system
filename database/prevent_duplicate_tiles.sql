-- Improved ERP Material Tiles with Duplicate Prevention
-- Uses INSERT ... ON CONFLICT to prevent duplicates

-- 1. Create unique constraint if not exists (prevents future duplicates)
ALTER TABLE tiles ADD CONSTRAINT unique_construction_action UNIQUE (construction_action);

-- 2. Insert or update tiles using UPSERT pattern
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
('Extend Material to Plant', 'Make global materials available in specific plants', 'git-branch', 'MM', 'extend-material-plant', '/materials/extend-plant', 'Materials', 'MM_MAT_EXTEND'),
('Material Plant Parameters', 'Manage plant-specific material parameters', 'settings', 'MM', 'material-plant-params', '/materials/plant-params', 'Materials', 'MM_PLANT_PARAM'),
('Material Pricing', 'Manage material pricing by company and plant', 'tag', 'MM', 'material-pricing', '/materials/pricing', 'Materials', 'MM_PRICING')
ON CONFLICT (construction_action) 
DO UPDATE SET 
  title = EXCLUDED.title,
  subtitle = EXCLUDED.subtitle,
  icon = EXCLUDED.icon,
  module_code = EXCLUDED.module_code,
  route = EXCLUDED.route,
  tile_category = EXCLUDED.tile_category,
  auth_object = EXCLUDED.auth_object;

-- 3. Verify final state
SELECT 'Final ERP Material Tiles:' as info;
SELECT title, subtitle, construction_action, auth_object
FROM tiles 
WHERE construction_action IN ('extend-material-plant', 'material-plant-params', 'material-pricing')
ORDER BY construction_action;