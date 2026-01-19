-- Check current tile organization
SELECT 
  tile_category,
  title,
  module_code,
  sequence_order,
  construction_action
FROM tiles
WHERE is_active = true
ORDER BY tile_category, sequence_order, title;

-- Count tiles per category
SELECT 
  tile_category,
  COUNT(*) as tile_count
FROM tiles
WHERE is_active = true
GROUP BY tile_category
ORDER BY tile_category;
