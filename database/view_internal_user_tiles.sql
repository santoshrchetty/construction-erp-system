-- =====================================================
-- VIEW INTERNAL USER TILES AND MODULES
-- =====================================================

-- Check all available tiles in the system
SELECT 
  'All System Tiles' AS section,
  id,
  title,
  subtitle,
  tile_category,
  module_code,
  construction_action,
  route,
  is_active,
  sequence_order
FROM tiles
WHERE is_active = true
ORDER BY tile_category, sequence_order;

-- Check tiles by category
SELECT 
  'Tiles by Category' AS section,
  tile_category,
  COUNT(*) AS tile_count,
  STRING_AGG(title, ', ' ORDER BY sequence_order) AS tiles
FROM tiles
WHERE is_active = true
GROUP BY tile_category
ORDER BY tile_category;

-- Check authorization objects for tiles
SELECT 
  'Tile Authorization Objects' AS section,
  t.title,
  t.tile_category,
  t.auth_object
FROM tiles t
WHERE t.is_active = true
ORDER BY t.tile_category, t.title;

-- Check which roles have access to which tiles (simplified)
SELECT 
  'All Tiles Summary' AS section,
  tile_category,
  COUNT(*) AS tile_count
FROM tiles
WHERE is_active = true
GROUP BY tile_category
ORDER BY tile_category;

-- Check internal user's accessible tiles (using RPC function)
SELECT 
  'Internal User Accessible Tiles' AS section,
  u.email,
  r.name AS role_name,
  u.id AS user_id
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.email = 'internaluser@abc.com';

-- Summary of tile categories
SELECT 
  'Tile Category Summary' AS section,
  tile_category,
  COUNT(*) AS total_tiles,
  COUNT(CASE WHEN auth_object IS NOT NULL THEN 1 END) AS protected_tiles,
  COUNT(CASE WHEN auth_object IS NULL THEN 1 END) AS public_tiles
FROM tiles
WHERE is_active = true
GROUP BY tile_category
ORDER BY tile_category;
