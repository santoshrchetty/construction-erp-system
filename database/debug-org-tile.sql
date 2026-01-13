-- Check current Organisation Configuration tile setup
SELECT 
    title,
    construction_action,
    route,
    tile_category,
    auth_object
FROM tiles 
WHERE construction_action = 'sap-config' OR title LIKE '%Organisation%' OR title LIKE '%SAP%';

-- Check all Configuration category tiles
SELECT title, construction_action, route, auth_object
FROM tiles 
WHERE tile_category = 'Configuration'
ORDER BY title;