-- =====================================================
-- EXTERNAL ACCESS - RLS POLICIES
-- =====================================================
-- Secures external access system with Row Level Security
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE external_organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE external_org_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE external_org_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE resource_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE drawing_customer_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_progress_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE drawing_raci ENABLE ROW LEVEL SECURITY;
ALTER TABLE field_service_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE external_access_audit_log ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Check if user has resource access
CREATE OR REPLACE FUNCTION has_resource_access(
  p_user_id UUID,
  p_resource_type VARCHAR,
  p_resource_id UUID
) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM resource_access ra
    JOIN external_org_users ou ON ra.external_org_id = ou.external_org_id
    WHERE ra.resource_type = p_resource_type
      AND ra.resource_id = p_resource_id
      AND ou.user_id = p_user_id
      AND ra.is_active = true
      AND ou.is_active = true
      AND (ra.access_end_date IS NULL OR ra.access_end_date >= CURRENT_DATE)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is external
CREATE OR REPLACE FUNCTION is_external_user(p_user_id UUID) 
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM external_org_users ou
    JOIN external_organizations o ON ou.external_org_id = o.external_org_id
    WHERE ou.user_id = p_user_id
      AND o.is_internal = false
      AND ou.is_active = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get user's organizations
CREATE OR REPLACE FUNCTION get_user_orgs(p_user_id UUID)
RETURNS TABLE(external_org_id UUID) AS $$
BEGIN
  RETURN QUERY
  SELECT ou.external_org_id
  FROM external_org_users ou
  WHERE ou.user_id = p_user_id
    AND ou.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 1. EXTERNAL_ORGANIZATIONS
-- =====================================================

CREATE POLICY external_orgs_select ON external_organizations
  FOR SELECT
  USING (
    external_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
  );

CREATE POLICY external_orgs_insert ON external_organizations
  FOR INSERT
  WITH CHECK (true); -- Internal users only via app logic

CREATE POLICY external_orgs_update ON external_organizations
  FOR UPDATE
  USING (true); -- Internal users only via app logic

-- =====================================================
-- 2. EXTERNAL_ORG_USERS
-- =====================================================

CREATE POLICY external_org_users_select ON external_org_users
  FOR SELECT
  USING (
    external_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
  );

CREATE POLICY external_org_users_insert ON external_org_users
  FOR INSERT
  WITH CHECK (true); -- Internal users only

-- =====================================================
-- 3. RESOURCE_ACCESS
-- =====================================================

CREATE POLICY resource_access_select ON resource_access
  FOR SELECT
  USING (
    external_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
  );

CREATE POLICY resource_access_insert ON resource_access
  FOR INSERT
  WITH CHECK (true); -- Internal users only

CREATE POLICY resource_access_update ON resource_access
  FOR UPDATE
  USING (true); -- Internal users only

-- =====================================================
-- 4. DRAWING_CUSTOMER_APPROVALS
-- =====================================================

CREATE POLICY drawing_approvals_select ON drawing_customer_approvals
  FOR SELECT
  USING (
    external_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
  );

CREATE POLICY drawing_approvals_insert ON drawing_customer_approvals
  FOR INSERT
  WITH CHECK (
    external_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
  );

CREATE POLICY drawing_approvals_update ON drawing_customer_approvals
  FOR UPDATE
  USING (
    external_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
  );

-- =====================================================
-- 5. VENDOR_PROGRESS_UPDATES
-- =====================================================

CREATE POLICY vendor_progress_select ON vendor_progress_updates
  FOR SELECT
  USING (
    external_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
  );

CREATE POLICY vendor_progress_insert ON vendor_progress_updates
  FOR INSERT
  WITH CHECK (
    external_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
  );

CREATE POLICY vendor_progress_update ON vendor_progress_updates
  FOR UPDATE
  USING (
    external_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
  );

-- =====================================================
-- 6. FIELD_SERVICE_TICKETS
-- =====================================================

CREATE POLICY tickets_select ON field_service_tickets
  FOR SELECT
  USING (
    assigned_external_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
    OR assigned_external_org_id IS NULL
  );

CREATE POLICY tickets_insert ON field_service_tickets
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY tickets_update ON field_service_tickets
  FOR UPDATE
  USING (
    assigned_external_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
    OR assigned_external_org_id IS NULL
  );

-- =====================================================
-- 7. DRAWING_RACI
-- =====================================================

CREATE POLICY drawing_raci_select ON drawing_raci
  FOR SELECT
  USING (
    user_id = current_setting('app.current_user_id', true)::uuid
    OR external_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
  );

-- =====================================================
-- 8. AUDIT_LOG (Read-only for users)
-- =====================================================

CREATE POLICY audit_log_select ON external_access_audit_log
  FOR SELECT
  USING (
    user_id = current_setting('app.current_user_id', true)::uuid
  );

CREATE POLICY audit_log_insert ON external_access_audit_log
  FOR INSERT
  WITH CHECK (true); -- System only

-- =====================================================
-- VERIFICATION
-- =====================================================

SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  cmd
FROM pg_policies
WHERE tablename IN (
  'external_organizations',
  'external_org_users',
  'resource_access',
  'drawing_customer_approvals',
  'vendor_progress_updates',
  'field_service_tickets',
  'drawing_raci',
  'external_access_audit_log'
)
ORDER BY tablename, policyname;
