-- Fix engineer@nttdemo.com user record to match actual auth user ID
-- The auth user ID is: d724846e-28a6-43ed-86b8-479d5e99ed8f

DO $$
DECLARE
    engineer_role_id UUID;
    auth_user_id UUID := 'd724846e-28a6-43ed-86b8-479d5e99ed8f';
BEGIN
    -- Get Engineer role ID
    SELECT id INTO engineer_role_id FROM roles WHERE name = 'Engineer' LIMIT 1;
    
    -- Delete any existing record with wrong ID
    DELETE FROM users WHERE email = 'engineer@nttdemo.com';
    
    -- Insert with correct auth user ID
    INSERT INTO users (
        id,
        email,
        first_name,
        last_name,
        role_id,
        employee_code,
        department,
        is_active
    ) VALUES (
        auth_user_id,
        'engineer@nttdemo.com',
        'Site',
        'Engineer',
        engineer_role_id,
        'ENG-001',
        'Engineering',
        true
    );
    
    RAISE NOTICE 'Engineer user record created with correct auth ID';
END $$;

-- Verify the fix
SELECT 
    u.id,
    u.email,
    u.first_name,
    u.last_name,
    r.name as role_name,
    u.employee_code,
    u.department
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.email = 'engineer@nttdemo.com';