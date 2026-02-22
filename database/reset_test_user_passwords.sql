-- Reset passwords for test users using proper Supabase auth
-- Password will be: password123

UPDATE auth.users
SET 
  encrypted_password = crypt('password123', gen_salt('bf')),
  email_confirmed_at = NOW(),
  confirmation_token = '',
  recovery_token = '',
  email_change_token_new = '',
  updated_at = NOW()
WHERE email IN ('john.engineer@example.com', 'jane.manager@example.com', 'bob.director@example.com');

-- Verify update
SELECT 
  email,
  encrypted_password IS NOT NULL as has_password,
  email_confirmed_at IS NOT NULL as confirmed,
  LENGTH(encrypted_password) as password_length
FROM auth.users
WHERE email IN ('john.engineer@example.com', 'jane.manager@example.com', 'bob.director@example.com')
ORDER BY email;
