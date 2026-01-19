-- Check current RLS policies on projects table
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'projects';

-- Check if RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'projects' AND schemaname = 'public';

-- Add RLS policy to allow authenticated users to read projects
DROP POLICY IF EXISTS "Authenticated users can read projects" ON projects;
CREATE POLICY "Authenticated users can read projects"
ON projects
FOR SELECT
USING (auth.role() = 'authenticated');

-- Verify the policy was created
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'projects' AND policyname = 'Authenticated users can read projects';
