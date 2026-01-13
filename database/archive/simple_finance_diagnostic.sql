-- Simple Finance Tiles Diagnostic
-- ================================

-- 1. Count Finance tiles
SELECT 'Finance Tiles Count' as check_type, COUNT(*) as count
FROM tiles WHERE tile_category = 'Finance';

-- 2. Check Finance tiles status
SELECT 'Finance Tiles Status' as check_type;
SELECT title, auth_object, is_active
FROM tiles 
WHERE tile_category = 'Finance'
ORDER BY title;

-- 3. Test one specific Finance tile authorization
SELECT 'Chart of Accounts Test' as check_type;
SELECT 
    t.title,
    t.auth_object,
    t.is_active,
    check_construction_authorization(
        (SELECT id FROM users WHERE email = 'admin@nttdemo.com'),
        t.auth_object,
        'DISPLAY'
    ) as has_access
FROM tiles t
WHERE t.title = 'Chart of Accounts' AND t.tile_category = 'Finance';

-- 4. Check if admin user exists
SELECT 'Admin User Check' as check_type;
SELECT id, email FROM users WHERE email = 'admin@nttdemo.com';