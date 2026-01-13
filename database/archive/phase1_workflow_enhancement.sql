-- Phase 1: Workflow Status and Context Enhancement
-- ================================================

-- Add workflow status table for tiles
CREATE TABLE IF NOT EXISTS tile_workflow_status (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  tile_id UUID NOT NULL REFERENCES tiles(id),
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  pending_count INTEGER DEFAULT 0,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  context_data JSONB,
  
  UNIQUE(user_id, tile_id)
);

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_tile_workflow_user ON tile_workflow_status(user_id);
CREATE INDEX IF NOT EXISTS idx_tile_workflow_status ON tile_workflow_status(status);

-- Add project context table for role-based project access
CREATE TABLE IF NOT EXISTS user_project_access (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  project_id UUID NOT NULL REFERENCES projects(id),
  access_level VARCHAR(20) NOT NULL DEFAULT 'read', -- read, write, admin
  assigned_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true,
  
  UNIQUE(user_id, project_id)
);

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_user_project_access ON user_project_access(user_id, is_active);

-- Enhanced authorization function with project context
CREATE OR REPLACE FUNCTION check_construction_authorization_with_context(
  p_user_id UUID,
  p_auth_object_name TEXT,
  p_project_id UUID DEFAULT NULL
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
AS $$
DECLARE
  user_role_name TEXT;
  has_basic_access BOOLEAN := FALSE;
  has_project_access BOOLEAN := TRUE; -- Default to true if no project context
BEGIN
  -- Get user role
  SELECT r.name INTO user_role_name
  FROM users u
  JOIN roles r ON u.role_id = r.id
  WHERE u.id = p_user_id 
  AND u.is_active = true 
  AND r.is_active = true
  LIMIT 1;
  
  -- Early exit if user not found
  IF user_role_name IS NULL THEN
    RETURN FALSE;
  END IF;
  
  -- Check basic authorization
  SELECT EXISTS (
    SELECT 1 
    FROM role_authorization_mapping ram
    WHERE ram.role_name = user_role_name
    AND ram.auth_object_name = p_auth_object_name
    LIMIT 1
  ) INTO has_basic_access;
  
  -- If no basic access, return false
  IF NOT has_basic_access THEN
    RETURN FALSE;
  END IF;
  
  -- Check project-specific access if project context provided
  IF p_project_id IS NOT NULL THEN
    SELECT EXISTS (
      SELECT 1
      FROM user_project_access upa
      WHERE upa.user_id = p_user_id
      AND upa.project_id = p_project_id
      AND upa.is_active = true
      LIMIT 1
    ) INTO has_project_access;
  END IF;
  
  RETURN has_basic_access AND has_project_access;
END;
$$;

-- Function to get user's authorized tiles with workflow status
CREATE OR REPLACE FUNCTION get_user_authorized_tiles_with_workflow(
  p_user_id UUID
) RETURNS TABLE (
  tile_id UUID,
  title TEXT,
  subtitle TEXT,
  icon TEXT,
  color TEXT,
  route TEXT,
  module_code TEXT,
  tile_category TEXT,
  construction_action TEXT,
  auth_object TEXT,
  sequence_order INTEGER,
  has_authorization BOOLEAN,
  workflow_status TEXT,
  pending_count INTEGER,
  context_data JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    t.id as tile_id,
    t.title,
    t.subtitle,
    t.icon,
    t.color,
    t.route,
    t.module_code,
    t.tile_category,
    t.construction_action,
    t.auth_object,
    t.sequence_order,
    CASE 
      WHEN t.auth_object IS NULL THEN true
      ELSE check_construction_authorization(p_user_id, t.auth_object)
    END as has_authorization,
    COALESCE(tws.status, 'active') as workflow_status,
    COALESCE(tws.pending_count, 0) as pending_count,
    tws.context_data
  FROM tiles t
  LEFT JOIN tile_workflow_status tws ON t.id = tws.tile_id AND tws.user_id = p_user_id
  WHERE t.is_active = true
  AND (
    t.auth_object IS NULL 
    OR check_construction_authorization(p_user_id, t.auth_object) = true
  )
  ORDER BY t.sequence_order, t.title;
END;
$$;

-- Sample workflow status data for demonstration
INSERT INTO tile_workflow_status (user_id, tile_id, status, pending_count, context_data)
SELECT 
  u.id,
  t.id,
  CASE 
    WHEN t.title LIKE '%Approval%' THEN 'pending'
    WHEN t.title LIKE '%Review%' THEN 'active'
    ELSE 'active'
  END,
  CASE 
    WHEN t.title LIKE '%Approval%' THEN FLOOR(RANDOM() * 5) + 1
    WHEN t.title LIKE '%Review%' THEN FLOOR(RANDOM() * 3)
    ELSE 0
  END,
  jsonb_build_object(
    'last_action', NOW() - (RANDOM() * INTERVAL '7 days'),
    'priority', CASE WHEN RANDOM() > 0.7 THEN 'high' ELSE 'normal' END
  )
FROM users u
CROSS JOIN tiles t
WHERE u.email IN ('admin@nttdemo.com', 'engineer@nttdemo.com', 'projectmanager@nttdemo.com')
AND t.is_active = true
AND RANDOM() > 0.7 -- Only add workflow status for some tiles
ON CONFLICT (user_id, tile_id) DO NOTHING;

-- Verify workflow enhancement
SELECT 'WORKFLOW STATUS SUMMARY' as status,
       COUNT(*) as total_workflow_items,
       COUNT(*) FILTER (WHERE status = 'pending') as pending_items,
       COUNT(*) FILTER (WHERE pending_count > 0) as items_with_pending_count
FROM tile_workflow_status;