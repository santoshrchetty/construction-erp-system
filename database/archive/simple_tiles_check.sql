-- CHECK TILES TABLE STRUCTURE AND APPROVAL TILES
-- Find out what columns exist and check for approval tiles

-- Check tiles table structure
SELECT 'TILES TABLE STRUCTURE:' as info;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tiles' 
ORDER BY ordinal_position;

-- Check if tiles table exists
SELECT 'TILES TABLE EXISTS:' as info;
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tiles')
        THEN '✅ tiles table EXISTS'
        ELSE '❌ tiles table MISSING'
    END as table_status;

-- Check all tiles (without category filter)
SELECT 'ALL TILES:' as info;
SELECT 
    title,
    route
FROM tiles 
WHERE title ILIKE '%approval%' 
   OR route ILIKE '%approval%'
ORDER BY title;

-- Simple tile count
SELECT 'TOTAL TILES COUNT:' as info;
SELECT COUNT(*) as total_tiles FROM tiles;

-- Check first few tiles to see structure
SELECT 'SAMPLE TILES:' as info;
SELECT * FROM tiles LIMIT 3;

SELECT 'TILES STRUCTURE CHECK COMPLETE' as result;