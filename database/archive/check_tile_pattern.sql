-- CHECK STANDARD TILE PATTERN
SELECT 'STANDARD TILE STRUCTURE:' as info;
SELECT title, icon, color, route, category, description
FROM tiles 
WHERE category = 'Administration' 
   OR title ILIKE '%config%' 
   OR title ILIKE '%setup%'
LIMIT 5;

-- Check Approval Configuration tile current structure
SELECT 'APPROVAL CONFIG TILE:' as info;
SELECT * FROM tiles WHERE title = 'Approval Configuration';