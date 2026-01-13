-- Change one WBS tile to PS_WBS_MODIFY
-- ====================================

UPDATE tiles 
SET auth_object = 'PS_WBS_MODIFY'
WHERE id = (
  SELECT id FROM tiles 
  WHERE title = 'WBS Management' 
  AND tile_category = 'Project Management'
  AND auth_object = 'PS_WBS_CREATE'
  ORDER BY id
  LIMIT 1
);

-- Verify both tiles now have different auth objects
SELECT id, title, tile_category, auth_object, subtitle
FROM tiles 
WHERE title = 'WBS Management' 
AND tile_category = 'Project Management'
ORDER BY auth_object;