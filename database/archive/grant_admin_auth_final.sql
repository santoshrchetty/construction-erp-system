-- Grant all authorizations to admin users (final corrected version)

-- 1. Check current admin authorization count
SELECT 
    u.email,
    COUNT(ua.id) as current_auth_count
FROM auth.users u
LEFT JOIN user_authorizations ua ON u.id = ua.user_id
WHERE u.email IN ('admin@demo.com', 'admin@nttdemo.com')
GROUP BY u.id, u.email;

-- 2. Grant all authorization objects to both admin users
DO $$
DECLARE
    admin1_id UUID;
    admin2_id UUID;
    auth_obj_uuid UUID;
BEGIN
    -- Get admin user IDs
    SELECT id INTO admin1_id FROM auth.users WHERE email = 'admin@demo.com';
    SELECT id INTO admin2_id FROM auth.users WHERE email = 'admin@nttdemo.com';
    
    -- Grant all authorization objects to both admins
    FOR auth_obj_uuid IN 
        SELECT DISTINCT ao.id
        FROM tiles t
        JOIN authorization_objects ao ON t.auth_object = ao.object_name
        WHERE t.auth_object IS NOT NULL
    LOOP
        -- Insert for admin1
        INSERT INTO user_authorizations (user_id, auth_object_id, field_values, valid_from)
        VALUES (admin1_id, auth_obj_uuid, '{"COMP_CODE":["*"],"DEPT":["*"],"ACTION":["*"],"COST_CTR":["*"],"PROJ_CAT":["*"],"STOR_LOC":["*"],"PROC_UNIT":["*"],"CONST_SITE":["*"]}', CURRENT_DATE)
        ON CONFLICT (user_id, auth_object_id) DO NOTHING;
        
        -- Insert for admin2  
        INSERT INTO user_authorizations (user_id, auth_object_id, field_values, valid_from)
        VALUES (admin2_id, auth_obj_uuid, '{"COMP_CODE":["*"],"DEPT":["*"],"ACTION":["*"],"COST_CTR":["*"],"PROJ_CAT":["*"],"STOR_LOC":["*"],"PROC_UNIT":["*"],"CONST_SITE":["*"]}', CURRENT_DATE)
        ON CONFLICT (user_id, auth_object_id) DO NOTHING;
    END LOOP;
END $$;

-- 3. Verify admin authorizations after granting
SELECT 
    u.email,
    COUNT(ua.id) as new_auth_count
FROM auth.users u
LEFT JOIN user_authorizations ua ON u.id = ua.user_id
WHERE u.email IN ('admin@demo.com', 'admin@nttdemo.com')
GROUP BY u.id, u.email;

-- 4. Show sample of granted authorizations
SELECT 
    u.email,
    ao.object_name,
    ua.field_values
FROM auth.users u
JOIN user_authorizations ua ON u.id = ua.user_id
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE u.email IN ('admin@demo.com', 'admin@nttdemo.com')
ORDER BY u.email, ao.object_name
LIMIT 10;