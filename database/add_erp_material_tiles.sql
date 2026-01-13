-- Add New ERP-Standard Material Plant Operation Tiles
-- Step 4.2: Insert new tiles for plant extension and plant parameters

INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
-- Plant Extension Tile
('Extend Material to Plant', 'Make global materials available in specific plants', 'git-branch', 'MM', 'extend-material-plant', '/materials/extend-plant', 'Materials', 'MM_MAT_EXTEND'),

-- Material Plant Parameters Tile  
('Material Plant Parameters', 'Manage plant-specific material parameters', 'settings', 'MM', 'material-plant-params', '/materials/plant-params', 'Materials', 'MM_PLANT_PARAM'),

-- Material Pricing Tile
('Material Pricing', 'Manage material pricing by company and plant', 'tag', 'MM', 'material-pricing', '/materials/pricing', 'Materials', 'MM_PRICING');

-- Update existing Material Master tiles to reflect ERP standard approach
UPDATE tiles 
SET subtitle = 'Create global material master data (no plant dependency)'
WHERE construction_action = 'create-material';

UPDATE tiles 
SET subtitle = 'Maintain global material master data'
WHERE construction_action = 'maintain-material';

UPDATE tiles 
SET subtitle = 'Display global material master data and plant extensions'
WHERE construction_action = 'material-master';

-- Verify new tiles
SELECT 'New ERP Material Tiles Added:' as info;
SELECT title, subtitle, construction_action, auth_object 
FROM tiles 
WHERE construction_action IN ('extend-material-plant', 'material-plant-params', 'material-pricing')
ORDER BY construction_action;

-- Verify updated tiles
SELECT 'Updated Material Master Tiles:' as info;
SELECT title, subtitle, construction_action 
FROM tiles 
WHERE construction_action IN ('create-material', 'maintain-material', 'material-master')
ORDER BY construction_action;