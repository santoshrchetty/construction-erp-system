-- Check Finance Tiles Status
-- ==========================

-- Check if Finance tiles exist
SELECT 'Finance Tiles Check' as check_type;
SELECT title, tile_category, auth_object, is_active 
FROM tiles 
WHERE tile_category = 'Finance' 
ORDER BY sequence_order;

-- Check authorization objects
SELECT 'Authorization Objects Check' as check_type;
SELECT object_name, description, module, is_active 
FROM authorization_objects 
WHERE module IN ('FI', 'CO') 
ORDER BY object_name;

-- Check if tiles are properly authorized
SELECT 'Tile Authorization Check' as check_type;
SELECT t.title, t.auth_object, ao.object_name, ao.is_active
FROM tiles t
LEFT JOIN authorization_objects ao ON t.auth_object = ao.object_name
WHERE t.tile_category = 'Finance'
ORDER BY t.sequence_order;