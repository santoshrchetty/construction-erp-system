-- =====================================================
-- DRAWING GOVERNANCE - CHANGES TO EXISTING TABLES
-- =====================================================

-- =====================================================
-- 1. PROJECTS TABLE (Add drawing-related fields)
-- =====================================================
ALTER TABLE projects
ADD COLUMN IF NOT EXISTS drawing_prefix VARCHAR(20), -- Prefix for drawing numbers (e.g., "DRG-MECH")
ADD COLUMN IF NOT EXISTS drawing_count INT DEFAULT 0; -- Track number of drawings

COMMENT ON COLUMN projects.drawing_prefix IS 'Prefix used for auto-generating drawing numbers for this project';
COMMENT ON COLUMN projects.drawing_count IS 'Total number of drawings associated with this project';

-- =====================================================
-- 2. WORKFLOW_DEFINITIONS (Add drawing workflow)
-- =====================================================
-- No schema changes needed, just insert new workflow definition:

INSERT INTO workflow_definitions (
  workflow_code,
  workflow_name,
  object_type,
  description,
  activation_conditions,
  is_active,
  tenant_id
) VALUES (
  'DRAWING_APPROVAL',
  'Drawing Approval Workflow',
  'DRAWING',
  'Standard approval workflow for engineering drawings',
  '{}'::jsonb,
  true,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
);

-- =====================================================
-- 3. TILES TABLE (Add Drawing Governance tiles)
-- =====================================================
-- No schema changes needed, just insert new tiles:

INSERT INTO tiles (
  title,
  subtitle,
  icon,
  module_code,
  construction_action,
  route,
  tile_category,
  auth_object,
  is_active,
  sequence_order
) VALUES 
  ('Create Drawing', 'Upload and submit engineering drawings', 'file-plus', 'DRAWINGS', 'create_drawing', '/drawings/create', 'Drawings', 'DRAWING_CREATE', true, 1),
  ('My Drawings', 'View and manage your drawings', 'folder', 'DRAWINGS', 'my_drawings', '/drawings/my-drawings', 'Drawings', 'DRAWING_VIEW', true, 2),
  ('Drawing Approvals', 'Approve pending drawings', 'check-circle', 'DRAWINGS', 'drawing_approvals', '/drawings/approvals', 'Drawings', 'DRAWING_APPROVE', true, 3),
  ('Search Drawings', 'Search and view approved drawings', 'search', 'DRAWINGS', 'search_drawings', '/drawings/search', 'Drawings', 'DRAWING_VIEW', true, 4),
  ('Drawing Reports', 'Drawing governance reports', 'bar-chart', 'DRAWINGS', 'drawing_reports', '/drawings/reports', 'Drawings', 'DRAWING_REPORTS', true, 5);

-- =====================================================
-- 4. AUTHORIZATION_OBJECTS (Add drawing permissions)
-- =====================================================
-- No schema changes needed, just insert new auth objects:

INSERT INTO authorization_objects (
  object_name,
  description,
  module,
  is_active,
  tenant_id
) VALUES 
  ('DRAWING_CREATE', 'Create and submit drawings', 'drawings', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'),
  ('DRAWING_VIEW', 'View drawings', 'drawings', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'),
  ('DRAWING_EDIT', 'Edit draft drawings', 'drawings', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'),
  ('DRAWING_APPROVE', 'Approve drawings', 'drawings', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'),
  ('DRAWING_REPORTS', 'View drawing reports', 'drawings', true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15');

-- =====================================================
-- 5. PERMISSIONS TYPES (Add DRAWINGS module)
-- =====================================================
-- Update lib/permissions/types.ts to add:
-- DRAWINGS = 'drawings' to Module enum

-- =====================================================
-- 6. MATERIALS TABLE (Optional enhancements for Master Data Governance)
-- =====================================================
ALTER TABLE materials
ADD COLUMN IF NOT EXISTS data_quality_score DECIMAL(5,2) DEFAULT 0, -- 0-100 score
ADD COLUMN IF NOT EXISTS approval_status VARCHAR(20) DEFAULT 'APPROVED', -- DRAFT, PENDING, APPROVED, REJECTED
ADD COLUMN IF NOT EXISTS approved_by UUID REFERENCES users(id),
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE;

COMMENT ON COLUMN materials.data_quality_score IS 'Data completeness score (0-100)';
COMMENT ON COLUMN materials.approval_status IS 'Approval status for new materials or changes';

-- =====================================================
-- SUMMARY OF CHANGES
-- =====================================================
-- NEW TABLES: 6
--   1. drawings
--   2. drawing_revisions
--   3. drawing_comments
--   4. drawing_attachments
--   5. drawing_links
--   6. drawing_access_log
--
-- MODIFIED TABLES: 2
--   1. projects (added drawing_prefix, drawing_count)
--   2. materials (added data_quality_score, approval_status)
--
-- NEW DATA INSERTS:
--   - workflow_definitions (1 row)
--   - tiles (5 rows)
--   - authorization_objects (5 rows)
--
-- CODE CHANGES:
--   - lib/permissions/types.ts (add DRAWINGS module)
-- =====================================================
