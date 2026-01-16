-- Advanced Industry-Grade RLS Policies with Role-Based Access Control
-- Implements multi-tenant security with project team membership

-- ============================================================================
-- PREREQUISITE: Ensure users table has proper structure
-- ============================================================================

-- Add user metadata if not exists
ALTER TABLE auth.users ADD COLUMN IF NOT EXISTS raw_user_meta_data JSONB;

-- ============================================================================
-- CREATE PROJECT TEAM MEMBERSHIP TABLE (if not exists)
-- ============================================================================

CREATE TABLE IF NOT EXISTS project_team_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'member', -- admin, manager, member, viewer
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    UNIQUE(project_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_project_team_project ON project_team_members(project_id);
CREATE INDEX IF NOT EXISTS idx_project_team_user ON project_team_members(user_id);

-- Enable RLS on project_team_members
ALTER TABLE project_team_members ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Check if user is system admin
CREATE OR REPLACE FUNCTION is_system_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM auth.users
        WHERE id = auth.uid()
        AND (raw_user_meta_data->>'role' = 'admin' OR raw_user_meta_data->>'is_admin' = 'true')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is project team member
CREATE OR REPLACE FUNCTION is_project_member(p_project_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM project_team_members
        WHERE project_id = p_project_id
        AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user has project role
CREATE OR REPLACE FUNCTION has_project_role(p_project_id UUID, p_role TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM project_team_members
        WHERE project_id = p_project_id
        AND user_id = auth.uid()
        AND role = p_role
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- DROP EXISTING POLICIES (clean slate)
-- ============================================================================

DROP POLICY IF EXISTS "authenticated_read_projects" ON projects;
DROP POLICY IF EXISTS "authenticated_create_projects" ON projects;
DROP POLICY IF EXISTS "authenticated_update_projects" ON projects;
DROP POLICY IF EXISTS "authenticated_read_wbs_nodes" ON wbs_nodes;
DROP POLICY IF EXISTS "authenticated_create_wbs_nodes" ON wbs_nodes;
DROP POLICY IF EXISTS "authenticated_update_wbs_nodes" ON wbs_nodes;
DROP POLICY IF EXISTS "authenticated_delete_wbs_nodes" ON wbs_nodes;
DROP POLICY IF EXISTS "authenticated_read_activities" ON activities;
DROP POLICY IF EXISTS "authenticated_create_activities" ON activities;
DROP POLICY IF EXISTS "authenticated_update_activities" ON activities;
DROP POLICY IF EXISTS "authenticated_delete_activities" ON activities;
DROP POLICY IF EXISTS "authenticated_read_tasks" ON tasks;
DROP POLICY IF EXISTS "authenticated_create_tasks" ON tasks;
DROP POLICY IF EXISTS "authenticated_update_tasks" ON tasks;
DROP POLICY IF EXISTS "authenticated_delete_tasks" ON tasks;

-- ============================================================================
-- PROJECTS TABLE POLICIES (Role-Based)
-- ============================================================================

-- Read: All authenticated users can see all projects (or restrict to team members)
CREATE POLICY "projects_select_policy"
ON projects FOR SELECT
TO authenticated
USING (
    is_system_admin() OR 
    is_project_member(id) OR
    true -- Remove this line to restrict to team members only
);

-- Create: All authenticated users can create projects
CREATE POLICY "projects_insert_policy"
ON projects FOR INSERT
TO authenticated
WITH CHECK (true);

-- Update: Only admins and project managers
CREATE POLICY "projects_update_policy"
ON projects FOR UPDATE
TO authenticated
USING (
    is_system_admin() OR 
    has_project_role(id, 'admin') OR 
    has_project_role(id, 'manager')
)
WITH CHECK (
    is_system_admin() OR 
    has_project_role(id, 'admin') OR 
    has_project_role(id, 'manager')
);

-- Delete: Only system admins
CREATE POLICY "projects_delete_policy"
ON projects FOR DELETE
TO authenticated
USING (is_system_admin());

-- ============================================================================
-- WBS_NODES TABLE POLICIES
-- ============================================================================

CREATE POLICY "wbs_nodes_select_policy"
ON wbs_nodes FOR SELECT
TO authenticated
USING (
    is_system_admin() OR 
    is_project_member(project_id) OR
    true -- Remove to restrict to team members
);

CREATE POLICY "wbs_nodes_insert_policy"
ON wbs_nodes FOR INSERT
TO authenticated
WITH CHECK (
    is_system_admin() OR 
    is_project_member(project_id)
);

CREATE POLICY "wbs_nodes_update_policy"
ON wbs_nodes FOR UPDATE
TO authenticated
USING (
    is_system_admin() OR 
    is_project_member(project_id)
)
WITH CHECK (
    is_system_admin() OR 
    is_project_member(project_id)
);

CREATE POLICY "wbs_nodes_delete_policy"
ON wbs_nodes FOR DELETE
TO authenticated
USING (
    is_system_admin() OR 
    has_project_role(project_id, 'admin') OR 
    has_project_role(project_id, 'manager')
);

-- ============================================================================
-- ACTIVITIES TABLE POLICIES
-- ============================================================================

CREATE POLICY "activities_select_policy"
ON activities FOR SELECT
TO authenticated
USING (
    is_system_admin() OR 
    is_project_member(project_id) OR
    true -- Remove to restrict to team members
);

CREATE POLICY "activities_insert_policy"
ON activities FOR INSERT
TO authenticated
WITH CHECK (
    is_system_admin() OR 
    is_project_member(project_id)
);

CREATE POLICY "activities_update_policy"
ON activities FOR UPDATE
TO authenticated
USING (
    is_system_admin() OR 
    is_project_member(project_id)
)
WITH CHECK (
    is_system_admin() OR 
    is_project_member(project_id)
);

CREATE POLICY "activities_delete_policy"
ON activities FOR DELETE
TO authenticated
USING (
    is_system_admin() OR 
    has_project_role(project_id, 'admin') OR 
    has_project_role(project_id, 'manager')
);

-- ============================================================================
-- TASKS TABLE POLICIES
-- ============================================================================

CREATE POLICY "tasks_select_policy"
ON tasks FOR SELECT
TO authenticated
USING (
    is_system_admin() OR 
    is_project_member(project_id) OR
    true -- Remove to restrict to team members
);

CREATE POLICY "tasks_insert_policy"
ON tasks FOR INSERT
TO authenticated
WITH CHECK (
    is_system_admin() OR 
    is_project_member(project_id)
);

CREATE POLICY "tasks_update_policy"
ON tasks FOR UPDATE
TO authenticated
USING (
    is_system_admin() OR 
    is_project_member(project_id)
)
WITH CHECK (
    is_system_admin() OR 
    is_project_member(project_id)
);

CREATE POLICY "tasks_delete_policy"
ON tasks FOR DELETE
TO authenticated
USING (
    is_system_admin() OR 
    is_project_member(project_id)
);

-- ============================================================================
-- PROJECT TEAM MEMBERS POLICIES
-- ============================================================================

CREATE POLICY "team_members_select_policy"
ON project_team_members FOR SELECT
TO authenticated
USING (
    is_system_admin() OR 
    user_id = auth.uid() OR
    is_project_member(project_id)
);

CREATE POLICY "team_members_insert_policy"
ON project_team_members FOR INSERT
TO authenticated
WITH CHECK (
    is_system_admin() OR 
    has_project_role(project_id, 'admin') OR 
    has_project_role(project_id, 'manager')
);

CREATE POLICY "team_members_delete_policy"
ON project_team_members FOR DELETE
TO authenticated
USING (
    is_system_admin() OR 
    has_project_role(project_id, 'admin')
);

-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON project_team_members TO authenticated;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

SELECT 'Advanced RLS policies with role-based access control created!' as status;

-- Show all policies
SELECT tablename, policyname, cmd, roles
FROM pg_policies
WHERE tablename IN ('projects', 'wbs_nodes', 'activities', 'tasks', 'project_team_members')
ORDER BY tablename, policyname;
