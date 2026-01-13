-- Check RLS status and policies for account_determination table

-- 1. Check if RLS is enabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'account_determination';

-- 2. Check existing policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'account_determination';

-- 3. Test direct query (should show data count)
SELECT COUNT(*) as total_records FROM public.account_determination;

-- 4. Check if current user can access the data
SELECT 
  auth.uid() as current_user_id,
  COUNT(*) as accessible_records 
FROM public.account_determination;

-- 5. Check user role
SELECT u.email, r.name as role_name 
FROM public.users u 
LEFT JOIN public.roles r ON u.role_id = r.id 
WHERE u.id = auth.uid();