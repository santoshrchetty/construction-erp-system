-- Find the Unified Material Request tile
SELECT id, title, subtitle, route, module_code, tile_category, construction_action
FROM tiles 
WHERE title LIKE '%Unified%' OR subtitle LIKE '%Unified%';

-- Update the tile to point to the correct route
UPDATE tiles 
SET route = '/materials'
WHERE (title LIKE '%Unified%' OR subtitle LIKE '%Unified%')
  AND tile_category = 'Materials';

-- Verify the update
SELECT id, title, subtitle, route, module_code, tile_category
FROM tiles 
WHERE title LIKE '%Unified%' OR subtitle LIKE '%Unified%';
