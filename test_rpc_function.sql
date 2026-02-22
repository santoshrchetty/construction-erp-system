-- Test the RPC function directly to see what's wrong

-- 1. Get user ID for admin@nttdemo.com
SELECT 'USER ID' as check_type, id, email
FROM users 
WHERE email = 'admin@nttdemo.com'
AND tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

-- 2. Test RPC function with the user ID (replace with actual ID from step 1)
SELECT 'RPC FUNCTION TEST' as check_type, *
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f');

-- 3. Check if our tiles are in the RPC results (filter for our new tiles)
SELECT 'RPC DG TILES' as check_type, tile_id, title
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f') rpc
JOIN tiles t ON rpc.tile_id = t.id
WHERE t.title IN ('Find Document', 'Create Document', 'Change Document');

-- 4. Alternative: Remove auth_object requirement temporarily to test
UPDATE tiles 
SET auth_object = NULL
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title IN ('Find Document', 'Create Document', 'Change Document');

-- 5. Verify tiles without auth objects
SELECT 'TILES WITHOUT AUTH' as check_type, title, auth_object, is_active
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND title IN ('Find Document', 'Create Document', 'Change Document');