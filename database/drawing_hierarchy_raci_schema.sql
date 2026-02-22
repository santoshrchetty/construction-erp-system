-- =====================================================
-- DRAWING HIERARCHY & RACI - SIMPLIFIED APPROACH
-- =====================================================
-- Design Philosophy:
-- 1. Simple parent-child hierarchy (like WBS)
-- 2. RACI at drawing level (not per revision - too complex)
-- 3. Revisions inherit RACI from parent drawing
-- 4. User-friendly: Assign roles, not complex matrices
-- =====================================================

-- =====================================================
-- 1. ENHANCED DRAWINGS TABLE (Add hierarchy support)
-- =====================================================

-- Add to existing drawings table:
ALTER TABLE drawings ADD COLUMN parent_drawing_id UUID REFERENCES drawings(id);
ALTER TABLE drawings ADD COLUMN drawing_level INT DEFAULT 1; -- 1=main, 2=sub, 3=child
ALTER TABLE drawings ADD COLUMN drawing_path VARCHAR(500); -- e.g., "DWG-001/DWG-001-A/DWG-001-A-1"
ALTER TABLE drawings ADD COLUMN is_assembly BOOLEAN DEFAULT false; -- Main assembly drawing

CREATE INDEX idx_drawings_parent ON drawings(parent_drawing_id);
CREATE INDEX idx_drawings_level ON drawings(drawing_level);
CREATE INDEX idx_drawings_path ON drawings(drawing_path);

-- Constraint: Prevent deep nesting (max 5 levels)
ALTER TABLE drawings ADD CONSTRAINT check_drawing_level 
  CHECK (drawing_level >= 1 AND drawing_level <= 5);

-- =====================================================
-- 2. DRAWING_RACI (Simple RACI Assignment)
-- =====================================================

CREATE TABLE drawing_raci (
  raci_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  drawing_id UUID NOT NULL REFERENCES drawings(id) ON DELETE CASCADE,
  
  -- User or Organization (flexible)
  user_id UUID REFERENCES users(user_id),
  organization_id UUID REFERENCES organizations(organization_id),
  
  -- RACI Role (simple, clear)
  raci_role VARCHAR(20) NOT NULL, -- RESPONSIBLE, ACCOUNTABLE, CONSULTED, INFORMED
  
  -- Optional: Specific responsibility
  responsibility_area VARCHAR(100), -- e.g., "Design", "Review", "Approval", "Fabrication"
  
  -- Active status
  is_active BOOLEAN DEFAULT true,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Either user OR organization, not both
  CHECK ((user_id IS NOT NULL AND organization_id IS NULL) OR 
         (user_id IS NULL AND organization_id IS NOT NULL)),
  CHECK (raci_role IN ('RESPONSIBLE', 'ACCOUNTABLE', 'CONSULTED', 'INFORMED'))
);

CREATE INDEX idx_drawing_raci_drawing ON drawing_raci(drawing_id);
CREATE INDEX idx_drawing_raci_user ON drawing_raci(user_id);
CREATE INDEX idx_drawing_raci_org ON drawing_raci(organization_id);
CREATE INDEX idx_drawing_raci_role ON drawing_raci(raci_role);
CREATE INDEX idx_drawing_raci_tenant ON drawing_raci(tenant_id);

ALTER TABLE drawing_raci ENABLE ROW LEVEL SECURITY;
CREATE POLICY drawing_raci_tenant_isolation ON drawing_raci
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

CREATE TRIGGER update_drawing_raci_updated_at BEFORE UPDATE ON drawing_raci
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 3. HELPER FUNCTIONS
-- =====================================================

-- Get full drawing hierarchy path
CREATE OR REPLACE FUNCTION get_drawing_hierarchy(p_drawing_id UUID)
RETURNS TABLE(
  drawing_id UUID,
  drawing_number VARCHAR(50),
  title VARCHAR(255),
  level INT,
  path VARCHAR(500)
) AS $$
BEGIN
  RETURN QUERY
  WITH RECURSIVE drawing_tree AS (
    -- Base case: start with the given drawing
    SELECT 
      d.id,
      d.drawing_number,
      d.title,
      d.drawing_level,
      d.drawing_path,
      d.parent_drawing_id
    FROM drawings d
    WHERE d.id = p_drawing_id
    
    UNION ALL
    
    -- Recursive case: get children
    SELECT 
      d.id,
      d.drawing_number,
      d.title,
      d.drawing_level,
      d.drawing_path,
      d.parent_drawing_id
    FROM drawings d
    INNER JOIN drawing_tree dt ON d.parent_drawing_id = dt.id
  )
  SELECT 
    dt.id,
    dt.drawing_number,
    dt.title,
    dt.drawing_level,
    dt.drawing_path
  FROM drawing_tree dt
  ORDER BY dt.drawing_level, dt.drawing_number;
END;
$$ LANGUAGE plpgsql;

-- Get RACI for a drawing (with inheritance from parent)
CREATE OR REPLACE FUNCTION get_drawing_raci_with_inheritance(p_drawing_id UUID)
RETURNS TABLE(
  user_id UUID,
  organization_id UUID,
  raci_role VARCHAR(20),
  responsibility_area VARCHAR(100),
  inherited_from UUID
) AS $$
BEGIN
  RETURN QUERY
  WITH RECURSIVE parent_chain AS (
    -- Start with current drawing
    SELECT 
      d.id,
      d.parent_drawing_id,
      1 as level
    FROM drawings d
    WHERE d.id = p_drawing_id
    
    UNION ALL
    
    -- Get parent drawings
    SELECT 
      d.id,
      d.parent_drawing_id,
      pc.level + 1
    FROM drawings d
    INNER JOIN parent_chain pc ON d.id = pc.parent_drawing_id
    WHERE pc.level < 5 -- Prevent infinite loops
  )
  SELECT DISTINCT ON (COALESCE(dr.user_id::text, dr.organization_id::text), dr.raci_role)
    dr.user_id,
    dr.organization_id,
    dr.raci_role,
    dr.responsibility_area,
    pc.id as inherited_from
  FROM parent_chain pc
  JOIN drawing_raci dr ON dr.drawing_id = pc.id
  WHERE dr.is_active = true
  ORDER BY COALESCE(dr.user_id::text, dr.organization_id::text), dr.raci_role, pc.level;
END;
$$ LANGUAGE plpgsql;

-- Check if user has RACI role for drawing
CREATE OR REPLACE FUNCTION user_has_raci_role(
  p_user_id UUID,
  p_drawing_id UUID,
  p_raci_role VARCHAR(20)
) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM get_drawing_raci_with_inheritance(p_drawing_id) r
    WHERE r.user_id = p_user_id
    AND r.raci_role = p_raci_role
  );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. VIEWS FOR USER-FRIENDLY ACCESS
-- =====================================================

-- View: Drawing hierarchy with RACI summary
CREATE VIEW drawing_hierarchy_with_raci AS
SELECT 
  d.id as drawing_id,
  d.drawing_number,
  d.title,
  d.drawing_level,
  d.parent_drawing_id,
  d.is_assembly,
  d.status,
  d.revision,
  -- Count RACI assignments
  COUNT(DISTINCT CASE WHEN dr.raci_role = 'RESPONSIBLE' THEN dr.raci_id END) as responsible_count,
  COUNT(DISTINCT CASE WHEN dr.raci_role = 'ACCOUNTABLE' THEN dr.raci_id END) as accountable_count,
  COUNT(DISTINCT CASE WHEN dr.raci_role = 'CONSULTED' THEN dr.raci_id END) as consulted_count,
  COUNT(DISTINCT CASE WHEN dr.raci_role = 'INFORMED' THEN dr.raci_id END) as informed_count,
  -- Get names
  STRING_AGG(DISTINCT CASE WHEN dr.raci_role = 'RESPONSIBLE' THEN u.full_name END, ', ') as responsible_users,
  STRING_AGG(DISTINCT CASE WHEN dr.raci_role = 'ACCOUNTABLE' THEN u.full_name END, ', ') as accountable_users
FROM drawings d
LEFT JOIN drawing_raci dr ON d.id = dr.drawing_id AND dr.is_active = true
LEFT JOIN users u ON dr.user_id = u.user_id
GROUP BY d.id, d.drawing_number, d.title, d.drawing_level, d.parent_drawing_id, 
         d.is_assembly, d.status, d.revision;

-- View: My drawings (where I have RACI role)
CREATE VIEW my_drawings_raci AS
SELECT 
  d.id as drawing_id,
  d.drawing_number,
  d.title,
  d.status,
  d.revision,
  dr.raci_role,
  dr.responsibility_area,
  d.project_id,
  d.created_at,
  d.updated_at
FROM drawings d
JOIN drawing_raci dr ON d.id = dr.drawing_id
WHERE dr.user_id = auth.uid()
AND dr.is_active = true;

-- =====================================================
-- 5. SIMPLE RACI RULES (Application Logic)
-- =====================================================

/*
RACI RULES (Keep it simple):

RESPONSIBLE (R):
- Does the work
- Can edit drawing
- Can upload revisions
- Can add comments
- Multiple people can be Responsible

ACCOUNTABLE (A):
- Approves the work
- Final decision maker
- Can approve/reject
- ONLY ONE person should be Accountable (enforced in app, not DB)

CONSULTED (C):
- Provides input
- Can view and comment
- Two-way communication
- Multiple people can be Consulted

INFORMED (I):
- Kept in the loop
- Can view only
- One-way communication
- Multiple people can be Informed

INHERITANCE:
- Child drawings inherit RACI from parent by default
- Can override at child level
- Use get_drawing_raci_with_inheritance() function
*/

-- =====================================================
-- 6. EXAMPLE DATA STRUCTURE
-- =====================================================

/*
Example: Pump Assembly Drawing Structure

Level 1 (Main Assembly):
  DWG-001: Pump Assembly (is_assembly=true)
    RACI:
      - John (ACCOUNTABLE) - Chief Engineer
      - Mary (RESPONSIBLE) - Lead Designer
      - Acme Corp (CONSULTED) - Customer
      - Vendor A (INFORMED) - Manufacturer

Level 2 (Sub-assemblies):
  DWG-001-A: Pump Body
    RACI: Inherits from DWG-001 + Bob (RESPONSIBLE) - Body Designer
  
  DWG-001-B: Impeller Assembly
    RACI: Inherits from DWG-001 + Alice (RESPONSIBLE) - Impeller Designer

Level 3 (Detail parts):
  DWG-001-B-1: Impeller Blade
    RACI: Inherits from DWG-001-B
  
  DWG-001-B-2: Impeller Hub
    RACI: Inherits from DWG-001-B

Revisions:
  DWG-001 Rev A → Rev B (all children automatically reference new parent revision)
  DWG-001-B-1 Rev A → Rev B (independent revision of child part)
*/

-- =====================================================
-- 7. NOTIFICATION TRIGGERS (Simple)
-- =====================================================

-- Notify INFORMED users when drawing status changes
CREATE OR REPLACE FUNCTION notify_informed_users()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status != OLD.status THEN
    -- Insert notifications for INFORMED users
    INSERT INTO notifications (user_id, notification_type, title, message, resource_type, resource_id)
    SELECT 
      dr.user_id,
      'DRAWING_STATUS_CHANGE',
      'Drawing Status Updated',
      'Drawing ' || NEW.drawing_number || ' status changed to ' || NEW.status,
      'DRAWING',
      NEW.id
    FROM drawing_raci dr
    WHERE dr.drawing_id = NEW.id
    AND dr.raci_role = 'INFORMED'
    AND dr.user_id IS NOT NULL
    AND dr.is_active = true;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_on_drawing_status_change
  AFTER UPDATE ON drawings
  FOR EACH ROW
  WHEN (NEW.status IS DISTINCT FROM OLD.status)
  EXECUTE FUNCTION notify_informed_users();

-- =====================================================
-- 8. RLS POLICIES WITH RACI
-- =====================================================

-- Drawings: Can view if you have any RACI role
CREATE POLICY drawings_raci_access ON drawings
  FOR SELECT
  USING (
    -- Internal users see all
    NOT EXISTS (SELECT 1 FROM organization_users ou WHERE ou.user_id = auth.uid())
    OR
    -- Users with RACI role
    EXISTS (
      SELECT 1 FROM drawing_raci dr
      WHERE dr.drawing_id = drawings.id
      AND dr.user_id = auth.uid()
      AND dr.is_active = true
    )
    OR
    -- Users from organization with RACI role
    EXISTS (
      SELECT 1 FROM drawing_raci dr
      JOIN organization_users ou ON dr.organization_id = ou.organization_id
      WHERE dr.drawing_id = drawings.id
      AND ou.user_id = auth.uid()
      AND dr.is_active = true
    )
  );

-- Drawings: Can edit if RESPONSIBLE or ACCOUNTABLE
CREATE POLICY drawings_raci_edit ON drawings
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM drawing_raci dr
      WHERE dr.drawing_id = drawings.id
      AND dr.user_id = auth.uid()
      AND dr.raci_role IN ('RESPONSIBLE', 'ACCOUNTABLE')
      AND dr.is_active = true
    )
  );

-- =====================================================
-- SUMMARY
-- =====================================================
/*
SIMPLE HIERARCHY + RACI APPROACH:

1. HIERARCHY:
   - parent_drawing_id: Simple parent-child link
   - drawing_level: 1-5 levels deep
   - drawing_path: Breadcrumb trail
   - is_assembly: Flag for main assemblies

2. RACI:
   - One table: drawing_raci
   - Four roles: R, A, C, I
   - Assign to users OR organizations
   - Inheritance via function (not enforced in DB)

3. USER-FRIENDLY:
   - Views for common queries
   - Functions for RACI checks
   - Simple notification triggers
   - Clear RLS policies

4. AVOID OVER-ENGINEERING:
   ❌ No RACI per revision (too complex)
   ❌ No complex permission matrices
   ❌ No workflow state machines
   ❌ No deep inheritance rules
   ✅ Simple parent-child
   ✅ Clear RACI roles
   ✅ Flexible assignment
   ✅ Easy to understand

5. REVISIONS:
   - Revisions tracked in drawing_revisions table
   - RACI applies to drawing, not revision
   - New revision = same RACI
   - If RACI changes, update drawing_raci table
*/
