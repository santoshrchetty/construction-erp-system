-- Grant all authorizations to admin users

-- 1. First, let's see current admin authorization count
SELECT 
    u.email,
    COUNT(ua.id) as current_auth_count
FROM auth.users u
LEFT JOIN user_authorizations ua ON u.id = ua.user_id
WHERE u.email IN ('admin@demo.com', 'admin@nttdemo.com')
GROUP BY u.id, u.email;

-- 2. Get all unique authorization objects from tiles
SELECT DISTINCT auth_object 
FROM tiles 
WHERE auth_object IS NOT NULL
ORDER BY auth_object;

-- 3. Grant all authorization objects to both admin users
DO $$
DECLARE
    admin1_id UUID;
    admin2_id UUID;
    auth_obj TEXT;
BEGIN
    -- Get admin user IDs
    SELECT id INTO admin1_id FROM auth.users WHERE email = 'admin@demo.com';
    SELECT id INTO admin2_id FROM auth.users WHERE email = 'admin@nttdemo.com';
    
    -- Grant all authorization objects to both admins
    FOR auth_obj IN 
        SELECT DISTINCT auth_object 
        FROM tiles 
        WHERE auth_object IS NOT NULL
    LOOP
        -- Insert for admin1
        INSERT INTO user_authorizations (user_id, auth_object_id, granted_at, granted_by)
        VALUES (admin1_id, auth_obj, NOW(), admin1_id)
        ON CONFLICT DO NOTHING;
        
        -- Insert for admin2  
        INSERT INTO user_authorizations (user_id, auth_object_id, granted_at, granted_by)
        VALUES (admin2_id, auth_obj, NOW(), admin2_id)
        ON CONFLICT DO NOTHING;
    END LOOP;
END $$;

-- 4. Verify admin authorizations after granting
SELECT 
    u.email,
    COUNT(ua.id) as new_auth_count
FROM auth.users u
LEFT JOIN user_authorizations ua ON u.id = ua.user_id
WHERE u.email IN ('admin@demo.com', 'admin@nttdemo.com')
GROUP BY u.id, u.email;