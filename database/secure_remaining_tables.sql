-- =====================================================
-- SECURE REMAINING TABLES
-- =====================================================

-- Enable RLS on remaining tables
ALTER TABLE vendor_progress_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE field_service_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE drawing_raci ENABLE ROW LEVEL SECURITY;
ALTER TABLE external_access_audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE external_org_relationships ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- VENDOR_PROGRESS_UPDATES
-- =====================================================

DROP POLICY IF EXISTS vendor_progress_select ON vendor_progress_updates;
DROP POLICY IF EXISTS vendor_progress_insert ON vendor_progress_updates;
DROP POLICY IF EXISTS vendor_progress_update ON vendor_progress_updates;

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
-- FIELD_SERVICE_TICKETS
-- =====================================================

DROP POLICY IF EXISTS tickets_select ON field_service_tickets;
DROP POLICY IF EXISTS tickets_insert ON field_service_tickets;
DROP POLICY IF EXISTS tickets_update ON field_service_tickets;

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
-- DRAWING_RACI
-- =====================================================

DROP POLICY IF EXISTS drawing_raci_select ON drawing_raci;
DROP POLICY IF EXISTS drawing_raci_insert ON drawing_raci;
DROP POLICY IF EXISTS drawing_raci_update ON drawing_raci;

CREATE POLICY drawing_raci_select ON drawing_raci
  FOR SELECT
  USING (
    user_id = current_setting('app.current_user_id', true)::uuid
    OR external_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
  );

CREATE POLICY drawing_raci_insert ON drawing_raci
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY drawing_raci_update ON drawing_raci
  FOR UPDATE
  USING (
    user_id = current_setting('app.current_user_id', true)::uuid
    OR external_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
  );

-- =====================================================
-- EXTERNAL_ACCESS_AUDIT_LOG
-- =====================================================

DROP POLICY IF EXISTS audit_log_select ON external_access_audit_log;
DROP POLICY IF EXISTS audit_log_insert ON external_access_audit_log;

CREATE POLICY audit_log_select ON external_access_audit_log
  FOR SELECT
  USING (
    user_id = current_setting('app.current_user_id', true)::uuid
  );

CREATE POLICY audit_log_insert ON external_access_audit_log
  FOR INSERT
  WITH CHECK (true);

-- =====================================================
-- EXTERNAL_ORG_RELATIONSHIPS
-- =====================================================

DROP POLICY IF EXISTS org_relationships_select ON external_org_relationships;
DROP POLICY IF EXISTS org_relationships_insert ON external_org_relationships;

CREATE POLICY org_relationships_select ON external_org_relationships
  FOR SELECT
  USING (
    parent_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
    OR child_org_id IN (SELECT get_user_orgs(current_setting('app.current_user_id', true)::uuid))
  );

CREATE POLICY org_relationships_insert ON external_org_relationships
  FOR INSERT
  WITH CHECK (true);

-- =====================================================
-- VERIFICATION
-- =====================================================

SELECT 
  'All Tables Secured' AS status,
  COUNT(DISTINCT tablename) AS tables_secured,
  COUNT(*) AS total_policies
FROM pg_policies
WHERE schemaname = 'public'
  AND (tablename LIKE 'external%' OR tablename = 'field_service_tickets');
