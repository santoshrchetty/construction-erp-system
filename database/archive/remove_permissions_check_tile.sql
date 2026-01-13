-- Check what permission-related tiles exist
SELECT id, title, tile_category 
FROM tiles 
WHERE title ILIKE '%permission%' 
   OR title ILIKE '%check%';

-- Remove the specific tile (update title as needed)
-- DELETE FROM tiles WHERE title = 'exact_title_from_above';