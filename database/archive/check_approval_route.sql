-- CHECK APPROVAL CONFIGURATION TILE ROUTE
SELECT 'APPROVAL CONFIG TILE DETAILS:' as info;
SELECT title, route, construction_action FROM tiles 
WHERE title = 'Approval Configuration';

-- Check if there are multiple approval config tiles
SELECT 'ALL APPROVAL CONFIG TILES:' as info;
SELECT id, title, route, construction_action FROM tiles 
WHERE title ILIKE '%approval%config%' OR route ILIKE '%approval%config%';