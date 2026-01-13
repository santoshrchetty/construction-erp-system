-- Check admin authorization status

-- 1. Get admin user IDs and check their authorizations
SELECT 
    u.email,
    u.id as user_id,
    COUNT(ua.id) as authorization_count
FROM auth.users u
LEFT JOIN user_authorizations ua ON u.id = ua.user_id
WHERE u.email IN ('admin@demo.com', 'admin@nttdemo.com')
GROUP BY u.id, u.email;

-- 2. Check Finance tiles count
SELECT 'Finance Tiles Count' as check, COUNT(*) as count 
FROM tiles 
WHERE tile_category = 'Finance';

-- 3. Check total tiles count
SELECT 'Total Tiles Count' as check, COUNT(*) as count 
FROM tiles;

-- 4. Check if tiles have authorization requirements
SELECT tile_category, COUNT(*) as tile_count
FROM tiles 
GROUP BY tile_category
ORDER BY tile_category;