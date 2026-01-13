-- Simple cleanup and verification
-- ===============================

-- Remove duplicate tiles
DELETE FROM tiles a
USING tiles b
WHERE a.tile_category = 'Administration' 
AND b.tile_category = 'Administration'
AND a.title = b.title 
AND a.created_at > b.created_at;

-- Check what admin tiles exist
SELECT title, tile_category, auth_object, construction_action
FROM tiles 
WHERE tile_category = 'Administration'
ORDER BY sequence_order;

-- Check table structure
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'user_authorizations';

-- Simple count of admin tiles
SELECT COUNT(*) as admin_tile_count 
FROM tiles 
WHERE tile_category = 'Administration';