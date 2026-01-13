-- CHECK APPROVAL CONFIGURATION TILE STRUCTURE
SELECT 'CURRENT APPROVAL CONFIG TILE:' as info;
SELECT * FROM tiles WHERE title = 'Approval Configuration';

-- Check what columns exist in tiles table
SELECT 'TILES TABLE COLUMNS:' as info;
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'tiles' 
ORDER BY ordinal_position;

-- Check standard Administration tiles pattern
SELECT 'ADMINISTRATION TILES PATTERN:' as info;
SELECT title, icon, route FROM tiles 
WHERE route LIKE '/admin%' OR title ILIKE '%admin%' OR title ILIKE '%config%'
LIMIT 3;