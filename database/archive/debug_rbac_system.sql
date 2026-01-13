-- Debug RBAC System
-- ==================

-- Check if tables exist
SELECT 'TABLES CHECK' as status;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('construction_tiles', 'construction_authorization_objects', 'user_authorizations')
ORDER BY table_name;

-- Check if functions exist
SELECT 'FUNCTIONS CHECK' as status;
SELECT routine_name FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('get_user_authorized_tiles', 'assign_role_authorizations', 'check_construction_authorization')
ORDER BY routine_name;

-- Check tiles data
SELECT 'TILES DATA' as status;
SELECT COUNT(*) as total_tiles FROM construction_tiles;

-- Check auth objects
SELECT 'AUTH OBJECTS' as status;
SELECT COUNT(*) as total_auth_objects FROM construction_authorization_objects;

-- Check user authorizations
SELECT 'USER AUTHS' as status;
SELECT COUNT(*) as total_user_auths FROM user_authorizations;