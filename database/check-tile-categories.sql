-- Check current tile categories
SELECT DISTINCT tile_category, COUNT(*) as tile_count
FROM tiles 
WHERE is_active = true
GROUP BY tile_category
ORDER BY tile_category;

-- Check approval configuration tile specifically
SELECT title, tile_category, auth_object
FROM tiles 
WHERE title ILIKE '%approval%config%' OR title ILIKE '%config%approval%'
ORDER BY title;