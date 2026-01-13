-- Add engineer@nttdemo.com user to authentication and users table
-- This script should be run in Supabase SQL editor

-- First, insert into auth.users (this creates the authentication record)
INSERT INTO auth.users (
    id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    role
) VALUES (
    '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid,
    'engineer@nttdemo.com',
    crypt('demo123', gen_salt('bf')), -- Password: demo123
    NOW(),
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"first_name": "Site", "last_name": "Engineer"}',
    false,
    'authenticated'
);

-- Get the Engineer role ID
DO $$
DECLARE
    engineer_role_id UUID;
BEGIN
    SELECT id INTO engineer_role_id FROM roles WHERE name = 'Engineer' LIMIT 1;
    
    -- Update users table (trigger should have created the record)
    UPDATE users SET
        role_id = engineer_role_id,
        first_name = 'Site',
        last_name = 'Engineer',
        employee_code = 'ENG-001',
        department = 'Engineering'
    WHERE email = 'engineer@nttdemo.com';
    
    -- If trigger didn't create the record, insert it
    IF NOT FOUND THEN
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
            '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid,
            'engineer@nttdemo.com',
            'Site',
            'Engineer',
            engineer_role_id,
            'ENG-001',
            'Engineering',
            true
        );
    END IF;
END $$;

-- Verify the user was created
SELECT 
    u.email,
    u.first_name,
    u.last_name,
    r.name as role_name,
    u.employee_code,
    u.department
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.email = 'engineer@nttdemo.com';