-- Remove Redundant Material Tiles
-- These tiles are redundant with existing ERP-standard functionality

-- Remove Material Search (redundant with Display Material Master search functionality)
DELETE FROM tiles WHERE construction_action = 'material-search';

-- Remove Material Classification (redundant with Create/Maintain Material Master category fields)
DELETE FROM tiles WHERE construction_action = 'material-classification';

-- Remove Material Pricing (redundant with new Material Pricing tile from ERP implementation)
DELETE FROM tiles WHERE construction_action = 'material-valuation';

-- Verify removals
SELECT 'Removed Tiles - Should show 0 results:' as info;
SELECT title, construction_action 
FROM tiles 
WHERE construction_action IN ('material-search', 'material-classification', 'material-valuation');

-- Show remaining Materials category tiles
SELECT 'Remaining Materials Tiles:' as info;
SELECT title, subtitle, construction_action, auth_object
FROM tiles 
WHERE tile_category = 'Materials'
ORDER BY construction_action;