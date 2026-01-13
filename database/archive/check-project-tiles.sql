-- Check Project Management category tiles
SELECT 
    title,
    subtitle,
    tile_category,
    route,
    icon,
    module_code
FROM tiles 
WHERE tile_category = 'Project Management'
ORDER BY title;