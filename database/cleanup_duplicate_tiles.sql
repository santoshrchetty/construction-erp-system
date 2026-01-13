-- Remove Duplicate Material Plant Tiles
-- Clean up duplicate entries and keep only the latest ERP-standard tiles

-- 1. First, identify and backup duplicates
CREATE TEMP TABLE duplicate_tiles_backup AS
SELECT * FROM tiles 
WHERE title IN ('Extend Material to Plant', 'Material Plant Parameters', 'Material Pricing');

-- 2. Delete all instances of these tiles
DELETE FROM tiles 
WHERE title IN ('Extend Material to Plant', 'Material Plant Parameters', 'Material Pricing');

-- 3. Delete any tiles with conflicting construction_action
DELETE FROM tiles 
WHERE construction_action IN ('extend-material-plant', 'material-plant-params', 'material-pricing');

-- 4. Insert clean, single instances of the new tiles
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
-- Plant Extension Tile (Single Instance)
('Extend Material to Plant', 'Make global materials available in specific plants', 'git-branch', 'MM', 'extend-material-plant', '/materials/extend-plant', 'Materials', 'MM_MAT_EXTEND'),

-- Material Plant Parameters Tile (Single Instance)
('Material Plant Parameters', 'Manage plant-specific material parameters', 'settings', 'MM', 'material-plant-params', '/materials/plant-params', 'Materials', 'MM_PLANT_PARAM'),

-- Material Pricing Tile (Single Instance)
('Material Pricing', 'Manage material pricing by company and plant', 'tag', 'MM', 'material-pricing', '/materials/pricing', 'Materials', 'MM_PRICING');

-- 5. Verify cleanup
SELECT 'Cleaned Material Plant Tiles:' as info;
SELECT title, subtitle, construction_action, auth_object
FROM tiles 
WHERE construction_action IN ('extend-material-plant', 'material-plant-params', 'material-pricing')
ORDER BY construction_action;

-- 6. Check for any remaining duplicates
SELECT 'Remaining duplicates (should be empty):' as info;
SELECT title, COUNT(*) as count
FROM tiles 
WHERE title IN ('Extend Material to Plant', 'Material Plant Parameters', 'Material Pricing')
GROUP BY title
HAVING COUNT(*) > 1;