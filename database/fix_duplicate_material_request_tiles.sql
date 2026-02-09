-- Find all Material Request List tiles
SELECT 
  id,
  title,
  module_code,
  tile_category,
  auth_object,
  route,
  is_active
FROM tiles
WHERE title ILIKE '%material request%list%'
ORDER BY created_at;

-- Delete duplicate Material Request List tile (keep only one)
DELETE FROM tiles
WHERE title = 'Material Request List'
  AND id NOT IN (
    SELECT id FROM tiles
    WHERE title = 'Material Request List'
    ORDER BY created_at DESC
    LIMIT 1
  );

-- Fix any tiles with NULL module_code
UPDATE tiles
SET module_code = 'materials'
WHERE module_code IS NULL
  AND tile_category = 'MATERIALS';

-- Verify no duplicate tiles
SELECT 
  title,
  COUNT(*) as count
FROM tiles
WHERE title = 'Material Request List'
GROUP BY title;

-- Show final state
SELECT 
  id,
  title,
  module_code,
  tile_category,
  auth_object,
  route
FROM tiles
WHERE title = 'Material Request List';
