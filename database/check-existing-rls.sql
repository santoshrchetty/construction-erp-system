-- Check Existing RLS Policies and Status
-- Run this to diagnose current security configuration

-- ============================================================================
-- 1. CHECK RLS STATUS ON TABLES
-- ============================================================================
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public'
  AND tablename IN ('projects', 'wbs_nodes', 'activities', 'tasks')
ORDER BY tablename;

-- ============================================================================
-- 2. CHECK EXISTING POLICIES
-- ============================================================================
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd as operation,
    qual as using_expression,
    with_check as with_check_expression
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('projects', 'wbs_nodes', 'activities', 'tasks')
ORDER BY tablename, policyname;

-- ============================================================================
-- 3. CHECK ALL TABLES WITH RLS ENABLED
-- ============================================================================
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public'
  AND rowsecurity = true
ORDER BY tablename;

-- ============================================================================
-- 4. COUNT POLICIES PER TABLE
-- ============================================================================
SELECT 
    tablename,
    COUNT(*) as policy_count
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY policy_count DESC, tablename;

-- ============================================================================
-- 5. CHECK IF PROJECT_TEAM_MEMBERS TABLE EXISTS
-- ============================================================================
SELECT EXISTS (
    SELECT FROM pg_tables 
    WHERE schemaname = 'public' 
    AND tablename = 'project_team_members'
) as team_table_exists;

-- ============================================================================
-- 6. CHECK HELPER FUNCTIONS
-- ============================================================================
SELECT 
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('is_system_admin', 'is_project_member', 'has_project_role')
ORDER BY routine_name;
