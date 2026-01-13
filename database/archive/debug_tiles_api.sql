-- Debug Tiles API Response
-- =========================

-- Check what the tiles API should return
SELECT 'Finance Tiles in Database' as check_type;
SELECT id, title, tile_category, auth_object, is_active, sequence_order
FROM tiles 
WHERE tile_category = 'Finance' 
ORDER BY sequence_order;

-- Test authorization for each Finance tile
SELECT 'Authorization Test per Tile' as check_type;
SELECT t.title, t.auth_object,
       check_construction_authorization(
           (SELECT id FROM users WHERE email = 'engineer1@nttdemo.com'),
           t.auth_object,
           'DISPLAY'
       ) as has_access
FROM tiles t
WHERE t.tile_category = 'Finance'
ORDER BY t.sequence_order;

-- Check if tiles are active
SELECT 'Tile Status Check' as check_type;
SELECT tile_category, COUNT(*) as total_tiles, 
       COUNT(CASE WHEN is_active THEN 1 END) as active_tiles
FROM tiles 
GROUP BY tile_category
ORDER BY tile_category;

-- Simulate what the API should return
SELECT 'Simulated API Response' as check_type;
SELECT t.id, t.title, t.subtitle, t.icon, t.color, t.route, 
       t.module_code, t.tile_category, t.construction_action, t.auth_object
FROM tiles t
WHERE t.tile_category = 'Finance' 
  AND t.is_active = true
  AND check_construction_authorization(
      (SELECT id FROM users WHERE email = 'engineer1@nttdemo.com'),
      t.auth_object,
      'DISPLAY'
  ) = true
ORDER BY t.sequence_order;