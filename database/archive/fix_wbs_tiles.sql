-- Fix WBS Management tiles to have different auth objects
-- ========================================================

-- Update one WBS tile to PS_WBS_UPDATE for editing
UPDATE tiles 
SET auth_object = 'PS_WBS_UPDATE'
WHERE id = (
  SELECT id FROM tiles 
  WHERE title = 'WBS Management' 
  AND tile_category = 'Project Management'
  AND auth_object = 'PS_WBS_CREATE'
  LIMIT 1
);

-- Verify the fix
SELECT title, tile_category, auth_object, subtitle
FROM tiles 
WHERE tile_category = 'Project Management' 
AND title LIKE '%WBS%'
ORDER BY title;