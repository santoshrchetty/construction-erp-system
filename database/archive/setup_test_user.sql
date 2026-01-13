-- Setup test user for Construction Management SaaS
-- Run this in your Supabase SQL Editor

-- Create a test user (this will be in auth.users table)
-- You need to run this in Supabase dashboard SQL editor
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'admin@construction.com',
  crypt('admin123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '{"provider": "email", "providers": ["email"]}',
  '{"role": "admin", "name": "Admin User"}',
  false,
  '',
  '',
  '',
  ''
);

-- Alternative: Use Supabase Auth API to create user
-- Go to Authentication > Users in Supabase dashboard
-- Click "Add user" and create:
-- Email: admin@construction.com
-- Password: admin123
-- User Metadata: {"role": "admin", "name": "Admin User"}