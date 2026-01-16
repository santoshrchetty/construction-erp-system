-- Fix RLS for activities and tasks tables
-- This disables RLS to allow client-side access

-- Disable RLS on activities table
ALTER TABLE activities DISABLE ROW LEVEL SECURITY;

-- Disable RLS on tasks table
ALTER TABLE tasks DISABLE ROW LEVEL SECURITY;

-- Disable RLS on wbs_nodes table (used by activities)
ALTER TABLE wbs_nodes DISABLE ROW LEVEL SECURITY;

-- Disable RLS on projects table (used by all components)
ALTER TABLE projects DISABLE ROW LEVEL SECURITY;

-- Verify RLS status
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename IN ('activities', 'tasks', 'wbs_nodes', 'projects')
ORDER BY tablename;

SELECT 'RLS disabled for activities, tasks, wbs_nodes, and projects tables' as status;
