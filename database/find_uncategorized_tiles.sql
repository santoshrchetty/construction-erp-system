-- Find the uncategorized tiles
SELECT 
  id,
  title,
  subtitle,
  tile_category,
  module_code,
  construction_action,
  route,
  auth_object,
  is_active,
  sequence_order
FROM tiles
WHERE tile_category IS NULL
  AND is_active = true
ORDER BY sequence_order;
