-- Check test users
SELECT 
  id,
  email,
  encrypted_password IS NOT NULL as has_password,
  email_confirmed_at IS NOT NULL as email_confirmed,
  created_at
FROM auth.users
WHERE email IN ('john.engineer@example.com', 'jane.manager@example.com', 'bob.director@example.com')
ORDER BY email;
