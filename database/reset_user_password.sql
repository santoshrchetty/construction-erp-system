-- =====================================================
-- CHECK AND RESET PASSWORD FOR INTERNALUSER@ABC.COM
-- =====================================================

-- Check if user exists in auth.users
SELECT 
  id,
  email,
  created_at,
  confirmed_at,
  email_confirmed_at
FROM auth.users
WHERE email = 'internaluser@abc.com';

-- To reset password, you need to:
-- 1. Go to Supabase Dashboard > Authentication > Users
-- 2. Find internaluser@abc.com
-- 3. Click "..." menu > Reset Password
-- 4. Or set a new password directly

-- Alternative: Delete and recreate user
-- WARNING: Only run this if you want to start fresh

/*
-- Delete from public.users first
DELETE FROM users WHERE email = 'internaluser@abc.com';

-- Delete from auth.users
DELETE FROM auth.users WHERE email = 'internaluser@abc.com';

-- Then recreate via Supabase Dashboard with known password
*/

-- Check current user status
SELECT 
  au.email,
  au.id as auth_id,
  u.id as user_id,
  u.tenant_id,
  r.name as role_name
FROM auth.users au
LEFT JOIN users u ON au.id = u.id
LEFT JOIN roles r ON u.role_id = r.id
WHERE au.email = 'internaluser@abc.com';
