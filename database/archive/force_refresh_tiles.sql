-- Force Refresh Tiles Cache
-- =========================

-- Update tiles timestamp to force cache refresh
UPDATE tiles 
SET updated_at = NOW() 
WHERE tile_category = 'Finance';

-- Verify Finance tiles are active and properly configured
SELECT 'Finance Tiles Final Check' as check_type;
SELECT 
    t.id,
    t.title, 
    t.tile_category, 
    t.auth_object, 
    t.is_active,
    t.sequence_order,
    ao.is_active as auth_object_active,
    CASE 
        WHEN ao.id IS NULL THEN 'Missing Auth Object'
        WHEN NOT ao.is_active THEN 'Auth Object Inactive'
        WHEN NOT t.is_active THEN 'Tile Inactive'
        ELSE 'OK'
    END as status
FROM tiles t
LEFT JOIN authorization_objects ao ON t.auth_object = ao.object_name
WHERE t.tile_category = 'Finance'
ORDER BY t.sequence_order;

-- Check user authorization one more time
SELECT 'User Authorization Final Check' as check_type;
SELECT 
    u.email,
    COUNT(ua.id) as total_finance_auths,
    STRING_AGG(ao.object_name, ', ') as auth_objects
FROM users u
LEFT JOIN user_authorizations ua ON u.id = ua.user_id
LEFT JOIN authorization_objects ao ON ua.auth_object_id = ao.id AND ao.module IN ('FI', 'CO')
WHERE u.email LIKE '%@%'
GROUP BY u.id, u.email
ORDER BY u.created_at DESC;