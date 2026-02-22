-- Check all Administration tiles
SELECT id, title, subtitle, route, auth_object, is_active
FROM tiles
WHERE tile_category = 'Administration'
ORDER BY sequence_order;
