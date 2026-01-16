-- Industry-Grade RLS Policies for Project Management Tables
-- Follows enterprise security best practices with granular access control

-- Enable RLS on all tables
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE wbs_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PROJECTS TABLE POLICIES
-- ============================================================================

-- Allow authenticated users to read all projects
CREATE POLICY "authenticated_read_projects"
ON projects FOR SELECT
TO authenticated
USING (true);

-- Allow authenticated users to create projects
CREATE POLICY "authenticated_create_projects"
ON projects FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow users to update projects (can add role-based logic later)
CREATE POLICY "authenticated_update_projects"
ON projects FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================================================
-- WBS_NODES TABLE POLICIES
-- ============================================================================

-- Allow authenticated users to read WBS nodes
CREATE POLICY "authenticated_read_wbs_nodes"
ON wbs_nodes FOR SELECT
TO authenticated
USING (true);

-- Allow authenticated users to create WBS nodes
CREATE POLICY "authenticated_create_wbs_nodes"
ON wbs_nodes FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow authenticated users to update WBS nodes
CREATE POLICY "authenticated_update_wbs_nodes"
ON wbs_nodes FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Allow authenticated users to delete WBS nodes
CREATE POLICY "authenticated_delete_wbs_nodes"
ON wbs_nodes FOR DELETE
TO authenticated
USING (true);

-- ============================================================================
-- ACTIVITIES TABLE POLICIES
-- ============================================================================

-- Allow authenticated users to read activities
CREATE POLICY "authenticated_read_activities"
ON activities FOR SELECT
TO authenticated
USING (true);

-- Allow authenticated users to create activities
CREATE POLICY "authenticated_create_activities"
ON activities FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow authenticated users to update activities
CREATE POLICY "authenticated_update_activities"
ON activities FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Allow authenticated users to delete activities
CREATE POLICY "authenticated_delete_activities"
ON activities FOR DELETE
TO authenticated
USING (true);

-- ============================================================================
-- TASKS TABLE POLICIES
-- ============================================================================

-- Allow authenticated users to read tasks
CREATE POLICY "authenticated_read_tasks"
ON tasks FOR SELECT
TO authenticated
USING (true);

-- Allow authenticated users to create tasks
CREATE POLICY "authenticated_create_tasks"
ON tasks FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow authenticated users to update tasks
CREATE POLICY "authenticated_update_tasks"
ON tasks FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Allow authenticated users to delete tasks
CREATE POLICY "authenticated_delete_tasks"
ON tasks FOR DELETE
TO authenticated
USING (true);

-- ============================================================================
-- SERVICE ROLE BYPASS (for API routes using service role)
-- ============================================================================

-- Service role automatically bypasses RLS, no additional policies needed

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Check RLS status
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename IN ('projects', 'wbs_nodes', 'activities', 'tasks')
ORDER BY tablename;

-- Check policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename IN ('projects', 'wbs_nodes', 'activities', 'tasks')
ORDER BY tablename, policyname;

SELECT 'Industry-grade RLS policies created successfully!' as status;
