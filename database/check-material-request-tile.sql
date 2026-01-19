-- Check Material Request tile configuration
SELECT id, title, subtitle, route, auth_object 
FROM tiles 
WHERE title ILIKE '%material%request%' 
   OR route ILIKE '%material%request%'
ORDER BY title;
