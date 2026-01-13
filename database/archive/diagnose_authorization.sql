-- Diagnostic: Check Authorization Issues

-- 1. Check if admin user exists and has authorizations
SELECT 'Admin User Check' as test, u.email, count(ua.id) as auth_count
FROM auth.users u
LEFT JOIN user_authorizations ua ON u.id = ua.user_id
WHERE u.email LIKE '%admin%'
GROUP BY u.id, u.email;

-- 2. Check Finance tiles and their authorization objects
SELECT 'Finance Tiles' as test, title, auth_object
FROM tiles 
WHERE tile_category = 'Finance' 
ORDER BY title;

-- 3. Check authorization objects for Finance
SELECT 'Auth Objects' as test, auth_object_id, object_name, module_code
FROM authorization_objects 
WHERE module_code = 'FI'
ORDER BY auth_object_id;

-- 4. Check if tiles API is being called
SELECT 'API Endpoint Check' as test, 'Check browser network tab for /api/tiles calls' as message;