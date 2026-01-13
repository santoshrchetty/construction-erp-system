-- Check all tile categories in the database
SELECT 
    category,
    COUNT(*) as tile_count,
    STRING_AGG(name, ', ' ORDER BY name) as tile_names
FROM tiles 
WHERE is_active = true
GROUP BY category
ORDER BY category;

-- Show sample tiles from each category
SELECT category, name, auth_object
FROM tiles 
WHERE is_active = true
ORDER BY category, name
LIMIT 20;