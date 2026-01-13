-- Debug Tiles System
-- ==================

-- Check tiles table structure
SELECT 'TILES TABLE STRUCTURE' as status;
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'tiles' 
ORDER BY ordinal_position;

-- Check if tiles exist
SELECT 'TILES COUNT' as status;
SELECT COUNT(*) as total_tiles FROM tiles;

-- Check sample tiles
SELECT 'SAMPLE TILES' as status;
SELECT id, title, auth_object, construction_action, module_code 
FROM tiles 
LIMIT 5;

-- Test function directly
SELECT 'FUNCTION TEST' as status;
SELECT * FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f') 
LIMIT 5;

-- Check if construction_tiles table exists (might be wrong table name)
SELECT 'CONSTRUCTION_TILES CHECK' as status;
SELECT table_name FROM information_schema.tables 
WHERE table_name LIKE '%tile%';