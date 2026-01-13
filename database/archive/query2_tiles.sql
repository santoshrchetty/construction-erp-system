-- Query 2: Check Finance tiles status
SELECT title, auth_object, is_active
FROM tiles 
WHERE tile_category = 'Finance'
ORDER BY title;