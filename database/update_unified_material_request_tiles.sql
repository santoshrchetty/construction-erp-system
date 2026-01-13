-- Update Material Reservations tile to Unified Material Requests
UPDATE tiles SET 
  title = 'Material Requests',
  subtitle = 'Unified reservations, purchase requisitions, and material requests',
  construction_action = 'unified-material-request',
  auth_object = 'MM_REQ_UNIFIED'
WHERE construction_action = 'material-reservations';

-- Add new tiles for specific request types if needed
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
('Purchase Requisitions', 'Create and manage purchase requisitions', 'shopping-cart', 'MM', 'purchase-requisitions', '/materials/pr', 'Procurement', 'MM_PR_CREATE'),
('Material Reservations', 'Reserve materials for projects', 'bookmark', 'MM', 'material-reservations-only', '/materials/reservations', 'Materials', 'MM_RES_CREATE')
ON CONFLICT (construction_action) DO NOTHING;

-- Verify updates
SELECT 'Updated Unified Material Request Tile:' as info;
SELECT title, subtitle, construction_action, auth_object
FROM tiles 
WHERE construction_action = 'unified-material-request';

-- Show all material-related tiles
SELECT 'All Material Request Tiles:' as info;
SELECT title, subtitle, construction_action, auth_object, tile_category
FROM tiles 
WHERE construction_action LIKE '%material%' OR construction_action LIKE '%reserv%' OR construction_action LIKE '%requisition%'
ORDER BY tile_category, construction_action;