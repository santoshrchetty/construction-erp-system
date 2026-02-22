-- =====================================================
-- MAINTENANCE DRAWINGS - MINIMAL ADDITIONS
-- =====================================================
-- Reuse existing drawings table for maintenance drawings
-- Add minimal fields for factory/building context
-- Same release control applies
-- =====================================================

-- 1. ADD MAINTENANCE CONTEXT TO DRAWINGS
-- =====================================================

-- Add fields to existing drawings table
ALTER TABLE drawings ADD COLUMN drawing_category VARCHAR(50) DEFAULT 'CONSTRUCTION';
ALTER TABLE drawings ADD COLUMN facility_id UUID; -- Link to factory/building
ALTER TABLE drawings ADD COLUMN equipment_id UUID; -- Link to specific equipment
ALTER TABLE drawings ADD COLUMN system_tag VARCHAR(50); -- HVAC, ELECTRICAL, PLUMBING, etc.
ALTER TABLE drawings ADD COLUMN location_reference VARCHAR(255); -- Building A, Floor 2, Room 201

-- Update constraint to include new category
ALTER TABLE drawings DROP CONSTRAINT IF EXISTS drawings_status_check;
ALTER TABLE drawings ADD CONSTRAINT drawings_status_check 
  CHECK (status IN ('DRAFT', 'UNDER_REVIEW', 'APPROVED', 'RELEASED', 'REJECTED', 'SUPERSEDED', 'OBSOLETE'));

ALTER TABLE drawings ADD CONSTRAINT drawings_category_check
  CHECK (drawing_category IN ('CONSTRUCTION', 'MAINTENANCE', 'AS_BUILT', 'OPERATIONS'));

-- Indexes
CREATE INDEX idx_drawings_category ON drawings(drawing_category);
CREATE INDEX idx_drawings_facility ON drawings(facility_id);
CREATE INDEX idx_drawings_equipment ON drawings(equipment_id);
CREATE INDEX idx_drawings_system ON drawings(system_tag);

-- =====================================================
-- 2. FACILITIES TABLE (Factories/Buildings)
-- =====================================================

CREATE TABLE facilities (
  facility_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  
  -- Facility Info
  facility_code VARCHAR(50) NOT NULL,
  facility_name VARCHAR(255) NOT NULL,
  facility_type VARCHAR(50) NOT NULL, -- FACTORY, BUILDING, WAREHOUSE, PLANT
  
  -- Location
  address TEXT,
  city VARCHAR(100),
  country VARCHAR(100),
  
  -- Status
  operational_status VARCHAR(20) DEFAULT 'OPERATIONAL', -- OPERATIONAL, UNDER_CONSTRUCTION, MAINTENANCE, DECOMMISSIONED
  commissioned_date DATE,
  
  -- Metadata
  description TEXT,
  total_area_sqm DECIMAL(10,2),
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(tenant_id, facility_code),
  CHECK (facility_type IN ('FACTORY', 'BUILDING', 'WAREHOUSE', 'PLANT', 'SITE')),
  CHECK (operational_status IN ('OPERATIONAL', 'UNDER_CONSTRUCTION', 'MAINTENANCE', 'DECOMMISSIONED'))
);

CREATE INDEX idx_facilities_tenant ON facilities(tenant_id);
CREATE INDEX idx_facilities_type ON facilities(facility_type);
CREATE INDEX idx_facilities_status ON facilities(operational_status);

ALTER TABLE facilities ENABLE ROW LEVEL SECURITY;
CREATE POLICY facilities_tenant_isolation ON facilities
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

CREATE TRIGGER update_facilities_updated_at BEFORE UPDATE ON facilities
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Add foreign key to drawings
ALTER TABLE drawings ADD CONSTRAINT fk_drawings_facility 
  FOREIGN KEY (facility_id) REFERENCES facilities(facility_id);

-- =====================================================
-- 3. EQUIPMENT REGISTER (Optional - for equipment-specific drawings)
-- =====================================================

CREATE TABLE equipment_register (
  equipment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  facility_id UUID REFERENCES facilities(facility_id),
  
  -- Equipment Info
  equipment_tag VARCHAR(50) NOT NULL, -- P-101, HX-201, etc.
  equipment_name VARCHAR(255) NOT NULL,
  equipment_type VARCHAR(100), -- PUMP, HEAT_EXCHANGER, MOTOR, VALVE, etc.
  
  -- Classification
  system_tag VARCHAR(50), -- HVAC-01, ELEC-02, etc.
  location_reference VARCHAR(255),
  
  -- Technical
  manufacturer VARCHAR(255),
  model_number VARCHAR(100),
  serial_number VARCHAR(100),
  
  -- Status
  operational_status VARCHAR(20) DEFAULT 'OPERATIONAL',
  installed_date DATE,
  warranty_expiry_date DATE,
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(tenant_id, equipment_tag)
);

CREATE INDEX idx_equipment_tenant ON equipment_register(tenant_id);
CREATE INDEX idx_equipment_facility ON equipment_register(facility_id);
CREATE INDEX idx_equipment_type ON equipment_register(equipment_type);
CREATE INDEX idx_equipment_system ON equipment_register(system_tag);
CREATE INDEX idx_equipment_tag ON equipment_register(equipment_tag);

ALTER TABLE equipment_register ENABLE ROW LEVEL SECURITY;
CREATE POLICY equipment_tenant_isolation ON equipment_register
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

CREATE TRIGGER update_equipment_updated_at BEFORE UPDATE ON equipment_register
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Add foreign key to drawings
ALTER TABLE drawings ADD CONSTRAINT fk_drawings_equipment 
  FOREIGN KEY (equipment_id) REFERENCES equipment_register(equipment_id);

-- =====================================================
-- 4. MAINTENANCE DRAWING TYPES (Extend existing)
-- =====================================================

-- Update drawing_type to include maintenance types
-- Existing: GA, DETAIL, ASSEMBLY, SCHEMATIC, LAYOUT, ISOMETRIC
-- Add maintenance types via application logic or:

/*
Maintenance Drawing Types:
- AS_BUILT: As-built drawings
- P&ID: Piping & Instrumentation Diagram
- ELECTRICAL_SINGLE_LINE: Electrical single line diagram
- HVAC_LAYOUT: HVAC system layout
- FIRE_PROTECTION: Fire protection system
- PLUMBING: Plumbing layout
- EQUIPMENT_LAYOUT: Equipment arrangement
- MAINTENANCE_MANUAL: Maintenance procedure drawings
*/

-- =====================================================
-- 5. VIEWS FOR MAINTENANCE DRAWINGS
-- =====================================================

-- View: All maintenance drawings for a facility
CREATE VIEW facility_maintenance_drawings AS
SELECT 
  d.id as drawing_id,
  d.drawing_number,
  d.title,
  d.revision,
  d.drawing_category,
  d.drawing_type,
  d.system_tag,
  d.location_reference,
  d.status,
  d.is_released,
  f.facility_code,
  f.facility_name,
  f.facility_type,
  e.equipment_tag,
  e.equipment_name
FROM drawings d
LEFT JOIN facilities f ON d.facility_id = f.facility_id
LEFT JOIN equipment_register e ON d.equipment_id = e.equipment_id
WHERE d.drawing_category IN ('MAINTENANCE', 'AS_BUILT', 'OPERATIONS');

-- View: Released maintenance drawings (for external contractors)
CREATE VIEW released_maintenance_drawings AS
SELECT 
  d.id as drawing_id,
  d.drawing_number,
  d.title,
  d.revision,
  d.drawing_type,
  d.system_tag,
  d.location_reference,
  d.file_path,
  d.released_at,
  f.facility_code,
  f.facility_name,
  e.equipment_tag
FROM drawings d
LEFT JOIN facilities f ON d.facility_id = f.facility_id
LEFT JOIN equipment_register e ON d.equipment_id = e.equipment_id
WHERE d.drawing_category IN ('MAINTENANCE', 'AS_BUILT', 'OPERATIONS')
AND d.is_released = true
AND d.status = 'RELEASED';

-- View: Equipment drawings (all drawings for specific equipment)
CREATE VIEW equipment_drawings AS
SELECT 
  e.equipment_tag,
  e.equipment_name,
  e.equipment_type,
  e.system_tag,
  d.drawing_number,
  d.title,
  d.revision,
  d.drawing_type,
  d.status,
  d.is_released
FROM equipment_register e
LEFT JOIN drawings d ON e.equipment_id = d.equipment_id
WHERE d.is_active = true;

-- =====================================================
-- 6. RESOURCE ACCESS FOR MAINTENANCE CONTRACTORS
-- =====================================================

-- Extend resource_access to support facility-level access
-- (Already supports DRAWING, PROJECT, EQUIPMENT, DOCUMENT)

/*
Example: Grant maintenance contractor access to facility drawings

INSERT INTO resource_access (
  tenant_id, 
  organization_id, 
  resource_type, 
  resource_id, 
  access_purpose, 
  access_level, 
  allowed_actions, 
  access_start_date
)
VALUES (
  'tenant-1',
  'contractor-org-id',
  'FACILITY', -- New resource type
  'facility-123-id',
  'MAINTENANCE',
  'READ',
  ARRAY['VIEW', 'DOWNLOAD'],
  CURRENT_DATE
);
*/

-- Update resource_access constraint to include FACILITY
ALTER TABLE resource_access DROP CONSTRAINT IF EXISTS resource_access_resource_type_check;
ALTER TABLE resource_access ADD CONSTRAINT resource_access_resource_type_check
  CHECK (resource_type IN ('PROJECT', 'DRAWING', 'DOCUMENT', 'EQUIPMENT', 'WORK_PACKAGE', 'MATERIAL', 'FACILITY'));

-- =====================================================
-- 7. RLS POLICY - FACILITY-BASED ACCESS
-- =====================================================

-- Update drawings RLS to include facility-based access
DROP POLICY IF EXISTS drawings_external_user_access ON drawings;

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
        -- Via facility access (NEW)
        EXISTS (
          SELECT 1 FROM organization_users ou
          JOIN resource_access ra ON ou.organization_id = ra.organization_id
          WHERE ou.user_id = auth.uid()
          AND ra.resource_type = 'FACILITY'
          AND ra.resource_id = drawings.facility_id
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
        -- Via equipment access (NEW)
        EXISTS (
          SELECT 1 FROM organization_users ou
          JOIN resource_access ra ON ou.organization_id = ra.organization_id
          WHERE ou.user_id = auth.uid()
          AND ra.resource_type = 'EQUIPMENT'
          AND ra.resource_id = drawings.equipment_id
          AND ra.is_active = true
          AND CURRENT_DATE BETWEEN ra.access_start_date 
              AND COALESCE(ra.access_end_date, '2099-12-31')
        )
      )
    )
  );

-- =====================================================
-- 8. USAGE EXAMPLES
-- =====================================================

/*
-- Example 1: Create a factory
INSERT INTO facilities (tenant_id, facility_code, facility_name, facility_type)
VALUES ('tenant-1', 'FAC-001', 'Main Production Plant', 'FACTORY');

-- Example 2: Register equipment
INSERT INTO equipment_register (tenant_id, facility_id, equipment_tag, equipment_name, equipment_type, system_tag)
VALUES ('tenant-1', 'facility-id', 'P-101', 'Cooling Water Pump', 'PUMP', 'COOLING-01');

-- Example 3: Create maintenance drawing
INSERT INTO drawings (
  tenant_id, drawing_number, title, revision, 
  drawing_category, drawing_type, discipline,
  facility_id, equipment_id, system_tag,
  file_path, file_name, file_type,
  status, created_by
)
VALUES (
  'tenant-1', 'MNT-P-101-001', 'Cooling Water Pump - Maintenance Drawing', 'A',
  'MAINTENANCE', 'EQUIPMENT_LAYOUT', 'MECHANICAL',
  'facility-id', 'equipment-id', 'COOLING-01',
  '/drawings/mnt-p-101-001.pdf', 'mnt-p-101-001.pdf', 'PDF',
  'DRAFT', 'user-id'
);

-- Example 4: Release maintenance drawing
SELECT release_drawing('drawing-id', 'admin-user-id');

-- Example 5: Grant contractor access to facility maintenance drawings
INSERT INTO resource_access (
  tenant_id, organization_id, resource_type, resource_id,
  access_purpose, access_level, allowed_actions, access_start_date
)
VALUES (
  'tenant-1', 'contractor-org-id', 'FACILITY', 'facility-id',
  'MAINTENANCE', 'READ', ARRAY['VIEW', 'DOWNLOAD'], CURRENT_DATE
);

-- Example 6: Get all maintenance drawings for a facility
SELECT * FROM facility_maintenance_drawings 
WHERE facility_code = 'FAC-001';

-- Example 7: Get released drawings for external contractor
SELECT * FROM released_maintenance_drawings;
*/

-- =====================================================
-- SUMMARY
-- =====================================================
/*
MAINTENANCE DRAWINGS - MINIMAL APPROACH:

1. REUSE EXISTING:
   ✅ drawings table (add 5 fields)
   ✅ drawing_revisions (no changes)
   ✅ drawing_comments (no changes)
   ✅ drawing_attachments (no changes)
   ✅ Same release control
   ✅ Same RACI system
   ✅ Same RLS policies

2. NEW TABLES (2 only):
   ✅ facilities (factories/buildings)
   ✅ equipment_register (optional)

3. NEW FIELDS ON DRAWINGS:
   - drawing_category: CONSTRUCTION, MAINTENANCE, AS_BUILT, OPERATIONS
   - facility_id: Link to factory/building
   - equipment_id: Link to specific equipment
   - system_tag: HVAC, ELECTRICAL, PLUMBING
   - location_reference: Building A, Floor 2

4. ACCESS CONTROL:
   ✅ Same resource_access table
   ✅ Add FACILITY resource type
   ✅ Add EQUIPMENT resource type
   ✅ External users see only RELEASED
   ✅ Grant access by facility, equipment, or specific drawing

5. USE CASES SUPPORTED:
   ✅ Factory maintenance drawings
   ✅ Building as-built drawings
   ✅ Equipment-specific drawings
   ✅ System drawings (HVAC, Electrical, etc.)
   ✅ Contractor access to maintenance docs
   ✅ Location-based drawing access

NO SEPARATE SYSTEM NEEDED:
  ❌ No duplicate tables
  ❌ No separate workflow
  ❌ No separate release process
  ✅ One unified drawing system
  ✅ Works for construction AND maintenance
  ✅ Same security model
  ✅ Same user experience
*/
