-- Check all WBS Management tiles
SELECT 
    id,
    title,
    subtitle,
    icon,
    route,
    tile_category,
    construction_action,
    is_active,
    created_at
FROM tiles 
WHERE title ILIKE '%WBS%'
ORDER BY created_at DESC;
