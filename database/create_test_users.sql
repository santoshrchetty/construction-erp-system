-- Create 3 test users for workflow testing
-- Run this BEFORE insert_sample_workflow_data.sql if you don't have users yet

-- Check if users already exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'john.engineer@example.com') THEN
    INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, role)
    VALUES (gen_random_uuid(), 'john.engineer@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{"full_name":"John Engineer"}', false, 'authenticated');
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'jane.manager@example.com') THEN
    INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, role)
    VALUES (gen_random_uuid(), 'jane.manager@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{"full_name":"Jane Manager"}', false, 'authenticated');
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'bob.director@example.com') THEN
    INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, role)
    VALUES (gen_random_uuid(), 'bob.director@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{"full_name":"Bob Director"}', false, 'authenticated');
  END IF;
END $$;

-- Verify users created
SELECT id, email, raw_user_meta_data->>'full_name' as full_name, created_at
FROM auth.users
WHERE email IN ('john.engineer@example.com', 'jane.manager@example.com', 'bob.director@example.com')
ORDER BY email;
