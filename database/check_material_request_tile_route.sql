-- Check the tile route
SELECT 
  id,
  title,
  route,
  module_code,
  auth_object,
  construction_action
FROM tiles
WHERE title = 'Material Request List';
