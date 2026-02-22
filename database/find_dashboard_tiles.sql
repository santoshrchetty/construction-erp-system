-- Find tiles that route to /dashboard
SELECT id, title, subtitle, route, tile_category, module_code
FROM tiles 
WHERE route = '/dashboard'
ORDER BY tile_category, title;
