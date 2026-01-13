-- Check all WBS tiles in database
-- ================================

SELECT id, title, tile_category, auth_object, subtitle, construction_action, is_active
FROM tiles 
WHERE (title ILIKE '%WBS%' OR title ILIKE '%work breakdown%')
ORDER BY title, auth_object;

-- Also check if there are duplicate tiles with same title
SELECT title, COUNT(*) as count
FROM tiles 
WHERE title ILIKE '%WBS%'
GROUP BY title
HAVING COUNT(*) > 1;