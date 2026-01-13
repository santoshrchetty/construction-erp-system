-- FIND DUPLICATE TILE TITLES

-- Check for exact duplicate titles
SELECT title, COUNT(*) as count
FROM tiles 
GROUP BY title 
HAVING COUNT(*) > 1
ORDER BY count DESC, title;

-- Check for similar titles that might be duplicates
SELECT t1.title as title1, t2.title as title2, t1.route as route1, t2.route as route2
FROM tiles t1, tiles t2 
WHERE t1.id < t2.id 
  AND (
    LOWER(t1.title) = LOWER(t2.title) OR
    t1.title ILIKE '%' || SPLIT_PART(t2.title, ' ', 1) || '%' OR
    t2.title ILIKE '%' || SPLIT_PART(t1.title, ' ', 1) || '%'
  )
ORDER BY t1.title;

-- List all tiles for manual review
SELECT id, title, route, icon, roles
FROM tiles 
ORDER BY title;