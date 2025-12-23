-- Simple version: Add engineer@demo.com user
-- Run this if you can't directly insert into auth.users

-- Method 1: If you have Supabase CLI access, use this command instead:
-- supabase auth users create engineer@demo.com --password demo123

-- Method 2: Manual signup through your app, then run this to assign role:
DO $$
DECLARE
    engineer_role_id UUID;
    user_exists BOOLEAN;
BEGIN
    -- Check if user exists in auth.users
    SELECT EXISTS(
        SELECT 1 FROM auth.users WHERE email = 'engineer@demo.com'
    ) INTO user_exists;
    
    IF NOT user_exists THEN
        RAISE NOTICE 'User engineer@demo.com does not exist in auth.users. Please create the user first through:';
        RAISE NOTICE '1. Supabase CLI: supabase auth users create engineer@demo.com --password demo123';
        RAISE NOTICE '2. Or sign up manually through your app';
        RETURN;
    END IF;
    
    -- Get Engineer role ID
    SELECT id INTO engineer_role_id FROM roles WHERE name = 'Engineer' LIMIT 1;
    
    -- Update user role
    UPDATE users 
    SET 
        role_id = engineer_role_id,
        first_name = 'Site',
        last_name = 'Engineer',
        employee_code = 'ENG-001',
        department = 'Engineering'
    WHERE email = 'engineer@demo.com';
    
    RAISE NOTICE 'Engineer role assigned successfully';
END $$;

-- Verify the user
SELECT 
    u.email,
    u.first_name,
    u.last_name,
    r.name as role_name,
    u.employee_code,
    u.department
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.email = 'engineer@demo.com';