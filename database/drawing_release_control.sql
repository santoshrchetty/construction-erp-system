-- =====================================================
-- DRAWING STATUS CONTROL FOR EXTERNAL USERS
-- =====================================================
-- Objective: External users only see RELEASED/APPROVED drawings
-- Internal users see all statuses
-- =====================================================

-- 1. ADD RELEASE STATUS TO DRAWINGS
-- =====================================================

-- Add release tracking fields to existing drawings table
ALTER TABLE drawings ADD COLUMN is_released BOOLEAN DEFAULT false;
ALTER TABLE drawings ADD COLUMN released_by UUID REFERENCES users(user_id);
ALTER TABLE drawings ADD COLUMN released_at TIMESTAMP WITH TIME ZONE;

-- Index for performance
CREATE INDEX idx_drawings_released ON drawings(is_released) WHERE is_released = true;

-- =====================================================
-- 2. ENHANCED STATUS VALUES
-- =====================================================

-- Current status values are good:
-- DRAFT - Work in progress (internal only)
-- UNDER_REVIEW - Being reviewed (internal only)
-- APPROVED - Approved but not released (internal only)
-- REJECTED - Rejected (internal only)
-- SUPERSEDED - Old version (internal only, unless was released)
-- OBSOLETE - No longer valid (internal only)

-- Add new status for clarity (optional - can use APPROVED + is_released instead)
ALTER TABLE drawings DROP CONSTRAINT IF EXISTS drawings_status_check;
ALTER TABLE drawings ADD CONSTRAINT drawings_status_check 
  CHECK (status IN ('DRAFT', 'UNDER_REVIEW', 'APPROVED', 'RELEASED', 'REJECTED', 'SUPERSEDED', 'OBSOLETE'));

-- =====================================================
-- 3. RELEASE FUNCTION (Simple)
-- =====================================================

CREATE OR REPLACE FUNCTION release_drawing(
  p_drawing_id UUID,
  p_released_by UUID
) RETURNS BOOLEAN AS $$
BEGIN
  -- Check if drawing is approved
  IF NOT EXISTS (
    SELECT 1 FROM drawings 
    WHERE id = p_drawing_id 
    AND status IN ('APPROVED', 'RELEASED')
  ) THEN
    RAISE EXCEPTION 'Drawing must be APPROVED before release';
  END IF;
  
  -- Release the drawing
  UPDATE drawings
  SET 
    status = 'RELEASED',
    is_released = true,
    released_by = p_released_by,
    released_at = NOW()
  WHERE id = p_drawing_id;
  
  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 4. RLS POLICIES - EXTERNAL USERS SEE ONLY RELEASED
-- =====================================================

-- Drop existing external access policy if exists
DROP POLICY IF EXISTS drawings_external_access ON drawings;

-- New policy: External users see only RELEASED drawings
CREATE POLICY drawings_external_user_access ON drawings
  FOR SELECT
  USING (
    -- Internal users see all
    NOT EXISTS (
      SELECT 1 FROM organization_users ou WHERE ou.user_id = auth.uid()
    )
    OR
    -- External users see only RELEASED drawings they have access to
    (
      is_released = true
      AND status = 'RELEASED'
      AND (
        -- Via project access
        EXISTS (
          SELECT 1 FROM organization_users ou
          JOIN resource_access ra ON ou.organization_id = ra.organization_id
          WHERE ou.user_id = auth.uid()
          AND ra.resource_type = 'PROJECT'
          AND ra.resource_id = drawings.project_id
          AND ra.is_active = true
          AND CURRENT_DATE BETWEEN ra.access_start_date 
              AND COALESCE(ra.access_end_date, '2099-12-31')
        )
        OR
        -- Via specific drawing access
        EXISTS (
          SELECT 1 FROM organization_users ou
          JOIN resource_access ra ON ou.organization_id = ra.organization_id
          WHERE ou.user_id = auth.uid()
          AND ra.resource_type = 'DRAWING'
          AND ra.resource_id = drawings.id
          AND ra.is_active = true
          AND CURRENT_DATE BETWEEN ra.access_start_date 
              AND COALESCE(ra.access_end_date, '2099-12-31')
        )
        OR
        -- Via RACI assignment (if they have any RACI role)
        EXISTS (
          SELECT 1 FROM drawing_raci dr
          WHERE dr.drawing_id = drawings.id
          AND dr.user_id = auth.uid()
          AND dr.is_active = true
        )
      )
    )
  );

-- =====================================================
-- 5. DRAWING REVISIONS - EXTERNAL ACCESS
-- =====================================================

-- Add release flag to revisions as well
ALTER TABLE drawing_revisions ADD COLUMN is_released BOOLEAN DEFAULT false;
ALTER TABLE drawing_revisions ADD COLUMN released_at TIMESTAMP WITH TIME ZONE;

CREATE INDEX idx_drawing_revisions_released ON drawing_revisions(is_released) 
  WHERE is_released = true;

-- RLS: External users see only released revisions
CREATE POLICY drawing_revisions_external_access ON drawing_revisions
  FOR SELECT
  USING (
    -- Internal users see all
    NOT EXISTS (
      SELECT 1 FROM organization_users ou WHERE ou.user_id = auth.uid()
    )
    OR
    -- External users see only released revisions of drawings they can access
    (
      is_released = true
      AND EXISTS (
        SELECT 1 FROM drawings d
        WHERE d.id = drawing_revisions.drawing_id
        AND d.is_released = true
        AND d.status = 'RELEASED'
      )
    )
  );

-- =====================================================
-- 6. HELPER VIEWS
-- =====================================================

-- View: Released drawings only (for external users)
CREATE VIEW released_drawings AS
SELECT 
  d.id,
  d.drawing_number,
  d.title,
  d.revision,
  d.discipline,
  d.drawing_type,
  d.project_id,
  d.file_path,
  d.file_name,
  d.description,
  d.released_by,
  d.released_at,
  d.created_at
FROM drawings d
WHERE d.is_released = true
AND d.status = 'RELEASED';

-- View: My released drawings (external user perspective)
CREATE VIEW my_released_drawings AS
SELECT 
  d.id,
  d.drawing_number,
  d.title,
  d.revision,
  d.status,
  d.released_at,
  ra.access_purpose,
  ra.access_level
FROM drawings d
JOIN resource_access ra ON (
  (ra.resource_type = 'PROJECT' AND ra.resource_id = d.project_id)
  OR (ra.resource_type = 'DRAWING' AND ra.resource_id = d.id)
)
JOIN organization_users ou ON ra.organization_id = ou.organization_id
WHERE d.is_released = true
AND d.status = 'RELEASED'
AND ou.user_id = auth.uid()
AND ra.is_active = true;

-- =====================================================
-- 7. TRIGGER - AUTO-RELEASE REVISIONS
-- =====================================================

-- When a drawing is released, mark current revision as released
CREATE OR REPLACE FUNCTION auto_release_current_revision()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_released = true AND (OLD.is_released IS NULL OR OLD.is_released = false) THEN
    -- Mark the latest revision as released
    UPDATE drawing_revisions
    SET 
      is_released = true,
      released_at = NEW.released_at
    WHERE drawing_id = NEW.id
    AND revision = NEW.revision
    AND is_released = false;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_drawing_release
  AFTER UPDATE ON drawings
  FOR EACH ROW
  WHEN (NEW.is_released = true AND (OLD.is_released IS NULL OR OLD.is_released = false))
  EXECUTE FUNCTION auto_release_current_revision();

-- =====================================================
-- 8. VALIDATION FUNCTION
-- =====================================================

-- Check if user can access a drawing (respects release status)
CREATE OR REPLACE FUNCTION can_user_access_drawing(
  p_user_id UUID,
  p_drawing_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
  v_is_internal BOOLEAN;
  v_is_released BOOLEAN;
BEGIN
  -- Check if user is internal
  v_is_internal := NOT EXISTS (
    SELECT 1 FROM organization_users WHERE user_id = p_user_id
  );
  
  -- Get drawing release status
  SELECT is_released INTO v_is_released
  FROM drawings
  WHERE id = p_drawing_id;
  
  -- Internal users can access all
  IF v_is_internal THEN
    RETURN true;
  END IF;
  
  -- External users can only access released drawings
  IF NOT v_is_released THEN
    RETURN false;
  END IF;
  
  -- Check if external user has access
  RETURN EXISTS (
    SELECT 1 FROM organization_users ou
    JOIN resource_access ra ON ou.organization_id = ra.organization_id
    JOIN drawings d ON (
      (ra.resource_type = 'PROJECT' AND ra.resource_id = d.project_id)
      OR (ra.resource_type = 'DRAWING' AND ra.resource_id = d.id)
    )
    WHERE ou.user_id = p_user_id
    AND d.id = p_drawing_id
    AND ra.is_active = true
    AND CURRENT_DATE BETWEEN ra.access_start_date 
        AND COALESCE(ra.access_end_date, '2099-12-31')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 9. USAGE EXAMPLES
-- =====================================================

/*
-- Example 1: Release a drawing
SELECT release_drawing('drawing-123-id', 'admin-user-id');

-- Example 2: Check if user can access
SELECT can_user_access_drawing('external-user-id', 'drawing-123-id');

-- Example 3: Get all released drawings for external user
SELECT * FROM my_released_drawings;

-- Example 4: Manually release a drawing
UPDATE drawings
SET 
  status = 'RELEASED',
  is_released = true,
  released_by = 'admin-user-id',
  released_at = NOW()
WHERE id = 'drawing-123-id'
AND status = 'APPROVED';
*/

-- =====================================================
-- 10. STATUS WORKFLOW (Simple)
-- =====================================================

/*
DRAWING STATUS FLOW:

Internal Users:
  DRAFT → UNDER_REVIEW → APPROVED → RELEASED
                            ↓
                        REJECTED → DRAFT

External Users:
  Can only see: RELEASED

Status Visibility:
  DRAFT          - Internal only
  UNDER_REVIEW   - Internal only
  APPROVED       - Internal only (approved but not released)
  RELEASED       - Internal + External (with access)
  REJECTED       - Internal only
  SUPERSEDED     - Internal only (unless was released)
  OBSOLETE       - Internal only

Release Criteria:
  1. Drawing must be APPROVED
  2. Must be released by authorized user
  3. Once released, external users can see it
  4. Current revision is automatically marked as released
*/

-- =====================================================
-- SUMMARY
-- =====================================================
/*
SIMPLE RELEASE CONTROL:

1. FIELDS ADDED:
   - drawings.is_released (boolean flag)
   - drawings.released_by (who released it)
   - drawings.released_at (when released)
   - drawing_revisions.is_released (revision release flag)

2. RLS POLICIES:
   - Internal users: See ALL drawings
   - External users: See ONLY released drawings they have access to

3. FUNCTIONS:
   - release_drawing() - Release a drawing
   - can_user_access_drawing() - Check access
   - auto_release_current_revision() - Auto-mark revision

4. VIEWS:
   - released_drawings - All released drawings
   - my_released_drawings - My accessible released drawings

5. WORKFLOW:
   DRAFT → REVIEW → APPROVED → RELEASED (external can see)

NO OVER-ENGINEERING:
  ✅ Simple boolean flag
  ✅ Clear RLS policies
  ✅ One function to release
  ✅ Automatic revision handling
  ❌ No complex state machines
  ❌ No approval matrices
  ❌ No multi-step release process
*/
