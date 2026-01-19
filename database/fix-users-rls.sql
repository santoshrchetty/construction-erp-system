-- Check current RLS policies on users table
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'users';

-- Check if RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'users' AND schemaname = 'public';

-- Fix: Add RLS policy to allow users to read their own profile
CREATE POLICY IF NOT EXISTS "Users can read own profile"
ON users
FOR SELECT
USING (auth.uid() = id);

-- Verify the policy was created
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'users' AND policyname = 'Users can read own profile';
