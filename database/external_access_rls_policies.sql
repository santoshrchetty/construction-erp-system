-- =====================================================
-- EXTERNAL ACCESS - RLS POLICIES FOR EXTERNAL USERS
-- =====================================================
-- Purpose: Control what external users can see and do
-- Key Rules:
--   1. External users see only RELEASED drawings
--   2. External users see only resources they have access to
--   3. All external user actions are audited
-- =====================================================

-- =====================================================
-- 1. DRAWINGS - External users see only RELEASED
-- =====================================================

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'drawings' AND policyname = 'drawings_external_released_only') THEN
    CREATE POLICY drawings_external_released_only ON drawings
      FOR SELECT
      USING (
        -- Internal users see all
        (EXISTS (
          SELECT 1 FROM users u 
          JOIN external_organizations o ON u.id = current_setting('app.current_user_id')::uuid
          WHERE o.is_internal = true AND o.tenant_id = drawings.tenant_id
        ))
        OR
        -- External users see only released drawings they have access to
        (is_released = true AND EXISTS (
          SELECT 1 FROM resource_access ra
          JOIN external_org_users ou ON ra.external_org_id = ou.external_org_id
          WHERE ra.resource_type = 'DRAWING'
            AND ra.resource_id = drawings.id
            AND ou.user_id = current_setting('app.current_user_id')::uuid
            AND ra.is_active = true
            AND (ra.access_end_date IS NULL OR ra.access_end_date >= CURRENT_DATE)
        ))
      );
  END IF;
END $$;

-- =====================================================
-- 2. RESOURCE ACCESS - Users see only their org access
-- =====================================================

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'resource_access' AND policyname = 'resource_access_user_org_only') THEN
    CREATE POLICY resource_access_user_org_only ON resource_access
      FOR SELECT
      USING (
        -- Users see access for their organizations
        EXISTS (
          SELECT 1 FROM external_org_users ou
          WHERE ou.external_org_id = resource_access.external_org_id
            AND ou.user_id = current_setting('app.current_user_id')::uuid
            AND ou.is_active = true
        )
      );
  END IF;
END $$;

-- =====================================================
-- 3. EXTERNAL ORGANIZATIONS - Users see their own orgs
-- =====================================================

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'external_organizations' AND policyname = 'external_orgs_user_access') THEN
    CREATE POLICY external_orgs_user_access ON external_organizations
      FOR SELECT
      USING (
        -- Users see organizations they belong to
        EXISTS (
          SELECT 1 FROM external_org_users ou
          WHERE ou.external_org_id = external_organizations.external_org_id
            AND ou.user_id = current_setting('app.current_user_id')::uuid
            AND ou.is_active = true
        )
      );
  END IF;
END $$;

-- =====================================================
-- 4. FACILITIES - Based on resource access
-- =====================================================

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'facilities' AND policyname = 'facilities_resource_access') THEN
    CREATE POLICY facilities_resource_access ON facilities
      FOR SELECT
      USING (
        -- Users see facilities they have access to
        EXISTS (
          SELECT 1 FROM resource_access ra
          JOIN external_org_users ou ON ra.external_org_id = ou.external_org_id
          WHERE ra.resource_type = 'FACILITY'
            AND ra.resource_id = facilities.facility_id
            AND ou.user_id = current_setting('app.current_user_id')::uuid
            AND ra.is_active = true
            AND (ra.access_end_date IS NULL OR ra.access_end_date >= CURRENT_DATE)
        )
      );
  END IF;
END $$;

-- =====================================================
-- 5. EQUIPMENT - Based on resource access
-- =====================================================

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'equipment_register' AND policyname = 'equipment_resource_access') THEN
    CREATE POLICY equipment_resource_access ON equipment_register
      FOR SELECT
      USING (
        -- Users see equipment they have access to
        EXISTS (
          SELECT 1 FROM resource_access ra
          JOIN external_org_users ou ON ra.external_org_id = ou.external_org_id
          WHERE ra.resource_type = 'EQUIPMENT'
            AND ra.resource_id = equipment_register.equipment_id
            AND ou.user_id = current_setting('app.current_user_id')::uuid
            AND ra.is_active = true
            AND (ra.access_end_date IS NULL OR ra.access_end_date >= CURRENT_DATE)
        )
      );
  END IF;
END $$;

-- =====================================================
-- 6. DRAWING CUSTOMER APPROVALS - Own org only
-- =====================================================

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'drawing_customer_approvals' AND policyname = 'approvals_own_org') THEN
    CREATE POLICY approvals_own_org ON drawing_customer_approvals
      FOR ALL
      USING (
        -- Users manage approvals for their organization
        EXISTS (
          SELECT 1 FROM external_org_users ou
          WHERE ou.external_org_id = drawing_customer_approvals.external_org_id
            AND ou.user_id = current_setting('app.current_user_id')::uuid
            AND ou.is_active = true
        )
      );
  END IF;
END $$;

-- =====================================================
-- 7. VENDOR PROGRESS UPDATES - Own org only
-- =====================================================

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'vendor_progress_updates' AND policyname = 'vendor_progress_own_org') THEN
    CREATE POLICY vendor_progress_own_org ON vendor_progress_updates
      FOR ALL
      USING (
        -- Vendors manage their own progress updates
        EXISTS (
          SELECT 1 FROM external_org_users ou
          WHERE ou.external_org_id = vendor_progress_updates.external_org_id
            AND ou.user_id = current_setting('app.current_user_id')::uuid
            AND ou.is_active = true
        )
      );
  END IF;
END $$;

-- =====================================================
-- 8. FIELD SERVICE TICKETS - Assigned org only
-- =====================================================

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'field_service_tickets' AND policyname = 'tickets_assigned_org') THEN
    CREATE POLICY tickets_assigned_org ON field_service_tickets
      FOR ALL
      USING (
        -- Users see tickets assigned to their organization
        EXISTS (
          SELECT 1 FROM external_org_users ou
          WHERE ou.external_org_id = field_service_tickets.assigned_external_org_id
            AND ou.user_id = current_setting('app.current_user_id')::uuid
            AND ou.is_active = true
        )
      );
  END IF;
END $$;

-- =====================================================
-- 9. HELPER FUNCTIONS
-- =====================================================

-- Function to check if user has access to resource
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
      AND (ra.access_end_date IS NULL OR ra.access_end_date >= CURRENT_DATE)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user is external
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

-- =====================================================
-- VERIFICATION
-- =====================================================

-- List all RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN (
  'drawings', 'resource_access', 'external_organizations', 'facilities', 
  'equipment_register', 'drawing_customer_approvals', 
  'vendor_progress_updates', 'field_service_tickets'
)
ORDER BY tablename, policyname;
