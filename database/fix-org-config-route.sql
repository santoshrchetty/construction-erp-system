-- Fix Organisation Configuration tile route
UPDATE tiles 
SET route = '/sap-config'
WHERE construction_action = 'sap-config';

-- Verify the route is correct
SELECT title, construction_action, route, tile_category
FROM tiles 
WHERE construction_action = 'sap-config';