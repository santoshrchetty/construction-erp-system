-- =====================================================
-- EXTERNAL ACCESS - PHASE 1 IMPLEMENTATION
-- =====================================================
-- Migration Script: Create and Update Tables
-- Run Order: Execute in sequence
-- =====================================================

-- =====================================================
-- STEP 1: CREATE CORE TABLES
-- =====================================================

-- 1.1 Organizations (if not exists)
CREATE TABLE IF NOT EXISTS organizations (
  organization_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  org_code VARCHAR(20) NOT NULL,
  org_name VARCHAR(100) NOT NULL,
  is_internal BOOLEAN DEFAULT true,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(tenant_id, org_code)
);

CREATE INDEX IF NOT EXISTS idx_organizations_tenant ON organizations(tenant_id);
CREATE INDEX IF NOT EXISTS idx_organizations_internal ON organizations(is_internal);

ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'organizations' AND policyname = 'organizations_tenant_isolation') THEN
    CREATE POLICY organizations_tenant_isolation ON organizations
      USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_organizations_updated_at') THEN
    CREATE TRIGGER update_organizations_updated_at 
      BEFORE UPDATE ON organizations
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- 1.2 Organization Relationships (if not exists)
CREATE TABLE IF NOT EXISTS organization_relationships (
  relationship_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  source_org_id UUID NOT NULL REFERENCES organizations(organization_id),
  target_org_id UUID NOT NULL REFERENCES organizations(organization_id),
  relationship_type VARCHAR(20) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(tenant_id, source_org_id, target_org_id, relationship_type),
  CHECK (source_org_id != target_org_id),
  CHECK (relationship_type IN ('CUSTOMER', 'VENDOR', 'PARTNER'))
);

CREATE INDEX IF NOT EXISTS idx_org_relationships_source ON organization_relationships(source_org_id);
CREATE INDEX IF NOT EXISTS idx_org_relationships_target ON organization_relationships(target_org_id);

ALTER TABLE organization_relationships ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'organization_relationships' AND policyname = 'org_relationships_tenant_isolation') THEN
    CREATE POLICY org_relationships_tenant_isolation ON organization_relationships
      USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
  END IF;
END $$;

-- =====================================================
-- STEP 2: CREATE NEW TABLES
-- =====================================================

-- 2.1 Organization Users
CREATE TABLE IF NOT EXISTS organization_users (
  org_user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  user_id UUID NOT NULL REFERENCES users(id),
  position_title VARCHAR(255),
  is_primary_contact BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(organization_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_org_users_org ON organization_users(organization_id);
CREATE INDEX IF NOT EXISTS idx_org_users_user ON organization_users(user_id);
CREATE INDEX IF NOT EXISTS idx_org_users_tenant ON organization_users(tenant_id);

ALTER TABLE organization_users ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'organization_users' AND policyname = 'org_users_tenant_isolation') THEN
    CREATE POLICY org_users_tenant_isolation ON organization_users
      USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_org_users_updated_at') THEN
    CREATE TRIGGER update_org_users_updated_at BEFORE UPDATE ON organization_users
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- 2.2 Resource Access (Core Access Control)
CREATE TABLE IF NOT EXISTS resource_access (
  access_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  
  resource_type VARCHAR(50) NOT NULL,
  resource_id UUID NOT NULL,
  project_id UUID REFERENCES projects(id),
  
  access_purpose VARCHAR(50),
  access_level VARCHAR(20) DEFAULT 'READ',
  allowed_actions TEXT[],
  
  access_start_date DATE NOT NULL,
  access_end_date DATE,
  is_active BOOLEAN DEFAULT true,
  
  notes TEXT,
  granted_by UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CHECK (resource_type IN ('PROJECT', 'DRAWING', 'DOCUMENT', 'EQUIPMENT', 'FACILITY', 'WORK_PACKAGE', 'MATERIAL')),
  CHECK (access_level IN ('READ', 'WRITE', 'COMMENT')),
  CHECK (access_purpose IN ('APPROVAL', 'PRODUCTION', 'MAINTENANCE', 'REFERENCE', 'COLLABORATION', 'SUPPLY')),
  CHECK (access_end_date IS NULL OR access_end_date >= access_start_date)
);

CREATE INDEX IF NOT EXISTS idx_resource_access_org ON resource_access(organization_id);
CREATE INDEX IF NOT EXISTS idx_resource_access_resource ON resource_access(resource_type, resource_id);
CREATE INDEX IF NOT EXISTS idx_resource_access_project ON resource_access(project_id);
CREATE INDEX IF NOT EXISTS idx_resource_access_tenant ON resource_access(tenant_id);
CREATE INDEX IF NOT EXISTS idx_resource_access_active ON resource_access(is_active, access_end_date);

ALTER TABLE resource_access ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'resource_access' AND policyname = 'resource_access_tenant_isolation') THEN
    CREATE POLICY resource_access_tenant_isolation ON resource_access
      USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_resource_access_updated_at') THEN
    CREATE TRIGGER update_resource_access_updated_at BEFORE UPDATE ON resource_access
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- 2.3 Facilities
CREATE TABLE IF NOT EXISTS facilities (
  facility_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  facility_code VARCHAR(50) NOT NULL,
  facility_name VARCHAR(255) NOT NULL,
  facility_type VARCHAR(50) NOT NULL,
  address TEXT,
  city VARCHAR(100),
  country VARCHAR(100),
  operational_status VARCHAR(20) DEFAULT 'OPERATIONAL',
  commissioned_date DATE,
  description TEXT,
  total_area_sqm DECIMAL(10,2),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(tenant_id, facility_code),
  CHECK (facility_type IN ('FACTORY', 'BUILDING', 'WAREHOUSE', 'PLANT', 'SITE')),
  CHECK (operational_status IN ('OPERATIONAL', 'UNDER_CONSTRUCTION', 'MAINTENANCE', 'DECOMMISSIONED'))
);

CREATE INDEX IF NOT EXISTS idx_facilities_tenant ON facilities(tenant_id);
CREATE INDEX IF NOT EXISTS idx_facilities_type ON facilities(facility_type);

ALTER TABLE facilities ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'facilities' AND policyname = 'facilities_tenant_isolation') THEN
    CREATE POLICY facilities_tenant_isolation ON facilities
      USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_facilities_updated_at') THEN
    CREATE TRIGGER update_facilities_updated_at BEFORE UPDATE ON facilities
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- 2.4 Equipment Register
CREATE TABLE IF NOT EXISTS equipment_register (
  equipment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  facility_id UUID REFERENCES facilities(facility_id),
  equipment_tag VARCHAR(50) NOT NULL,
  equipment_name VARCHAR(255) NOT NULL,
  equipment_type VARCHAR(100),
  system_tag VARCHAR(50),
  location_reference VARCHAR(255),
  manufacturer VARCHAR(255),
  model_number VARCHAR(100),
  serial_number VARCHAR(100),
  operational_status VARCHAR(20) DEFAULT 'OPERATIONAL',
  installed_date DATE,
  warranty_expiry_date DATE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(tenant_id, equipment_tag)
);

CREATE INDEX IF NOT EXISTS idx_equipment_tenant ON equipment_register(tenant_id);
CREATE INDEX IF NOT EXISTS idx_equipment_facility ON equipment_register(facility_id);
CREATE INDEX IF NOT EXISTS idx_equipment_tag ON equipment_register(equipment_tag);

ALTER TABLE equipment_register ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'equipment_register' AND policyname = 'equipment_tenant_isolation') THEN
    CREATE POLICY equipment_tenant_isolation ON equipment_register
      USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_equipment_updated_at') THEN
    CREATE TRIGGER update_equipment_updated_at BEFORE UPDATE ON equipment_register
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- 2.5 Drawing RACI
CREATE TABLE IF NOT EXISTS drawing_raci (
  raci_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  drawing_id UUID NOT NULL REFERENCES drawings(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  organization_id UUID REFERENCES organizations(organization_id),
  raci_role VARCHAR(20) NOT NULL,
  responsibility_area VARCHAR(100),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CHECK ((user_id IS NOT NULL AND organization_id IS NULL) OR (user_id IS NULL AND organization_id IS NOT NULL)),
  CHECK (raci_role IN ('RESPONSIBLE', 'ACCOUNTABLE', 'CONSULTED', 'INFORMED'))
);

CREATE INDEX IF NOT EXISTS idx_drawing_raci_drawing ON drawing_raci(drawing_id);
CREATE INDEX IF NOT EXISTS idx_drawing_raci_user ON drawing_raci(user_id);
CREATE INDEX IF NOT EXISTS idx_drawing_raci_org ON drawing_raci(organization_id);
CREATE INDEX IF NOT EXISTS idx_drawing_raci_tenant ON drawing_raci(tenant_id);

ALTER TABLE drawing_raci ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'drawing_raci' AND policyname = 'drawing_raci_tenant_isolation') THEN
    CREATE POLICY drawing_raci_tenant_isolation ON drawing_raci
      USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_drawing_raci_updated_at') THEN
    CREATE TRIGGER update_drawing_raci_updated_at BEFORE UPDATE ON drawing_raci
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- 2.6 Drawing Customer Approvals
CREATE TABLE IF NOT EXISTS drawing_customer_approvals (
  approval_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  drawing_id UUID NOT NULL REFERENCES drawings(id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  customer_user_id UUID NOT NULL REFERENCES users(id),
  approval_status VARCHAR(20) DEFAULT 'PENDING',
  comments TEXT,
  attachments JSONB,
  approved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CHECK (approval_status IN ('PENDING', 'APPROVED', 'REJECTED', 'CLARIFICATION_NEEDED'))
);

CREATE INDEX IF NOT EXISTS idx_drawing_approvals_drawing ON drawing_customer_approvals(drawing_id);
CREATE INDEX IF NOT EXISTS idx_drawing_approvals_org ON drawing_customer_approvals(organization_id);
CREATE INDEX IF NOT EXISTS idx_drawing_approvals_status ON drawing_customer_approvals(approval_status);
CREATE INDEX IF NOT EXISTS idx_drawing_approvals_tenant ON drawing_customer_approvals(tenant_id);

ALTER TABLE drawing_customer_approvals ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'drawing_customer_approvals' AND policyname = 'drawing_approvals_tenant_isolation') THEN
    CREATE POLICY drawing_approvals_tenant_isolation ON drawing_customer_approvals
      USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_drawing_approvals_updated_at') THEN
    CREATE TRIGGER update_drawing_approvals_updated_at BEFORE UPDATE ON drawing_customer_approvals
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- 2.7 Vendor Progress Updates
CREATE TABLE IF NOT EXISTS vendor_progress_updates (
  update_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  project_id UUID REFERENCES projects(id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  vendor_user_id UUID NOT NULL REFERENCES users(id),
  work_package_id UUID,
  progress_percentage DECIMAL(5,2),
  status VARCHAR(50),
  update_description TEXT NOT NULL,
  attachments JSONB,
  reported_date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  CHECK (status IN ('ON_TRACK', 'DELAYED', 'AT_RISK', 'COMPLETED'))
);

CREATE INDEX IF NOT EXISTS idx_vendor_progress_project ON vendor_progress_updates(project_id);
CREATE INDEX IF NOT EXISTS idx_vendor_progress_org ON vendor_progress_updates(organization_id);
CREATE INDEX IF NOT EXISTS idx_vendor_progress_date ON vendor_progress_updates(reported_date DESC);
CREATE INDEX IF NOT EXISTS idx_vendor_progress_tenant ON vendor_progress_updates(tenant_id);

ALTER TABLE vendor_progress_updates ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'vendor_progress_updates' AND policyname = 'vendor_progress_tenant_isolation') THEN
    CREATE POLICY vendor_progress_tenant_isolation ON vendor_progress_updates
      USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_vendor_progress_updated_at') THEN
    CREATE TRIGGER update_vendor_progress_updated_at BEFORE UPDATE ON vendor_progress_updates
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- 2.8 Field Service Tickets
CREATE TABLE IF NOT EXISTS field_service_tickets (
  ticket_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  project_id UUID REFERENCES projects(id),
  ticket_number VARCHAR(50) NOT NULL,
  assigned_organization_id UUID REFERENCES organizations(organization_id),
  assigned_contractor_id UUID REFERENCES users(id),
  service_type VARCHAR(50),
  priority VARCHAR(20),
  status VARCHAR(20) DEFAULT 'OPEN',
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  location VARCHAR(255),
  equipment_tag VARCHAR(50),
  scheduled_date DATE,
  completed_date DATE,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(tenant_id, ticket_number),
  CHECK (service_type IN ('INSPECTION', 'MAINTENANCE', 'INSTALLATION', 'REPAIR')),
  CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
  CHECK (status IN ('OPEN', 'IN_PROGRESS', 'COMPLETED', 'CLOSED', 'CANCELLED'))
);

CREATE INDEX IF NOT EXISTS idx_field_service_project ON field_service_tickets(project_id);
CREATE INDEX IF NOT EXISTS idx_field_service_org ON field_service_tickets(assigned_organization_id);
CREATE INDEX IF NOT EXISTS idx_field_service_status ON field_service_tickets(status);
CREATE INDEX IF NOT EXISTS idx_field_service_tenant ON field_service_tickets(tenant_id);

ALTER TABLE field_service_tickets ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'field_service_tickets' AND policyname = 'field_service_tenant_isolation') THEN
    CREATE POLICY field_service_tenant_isolation ON field_service_tickets
      USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_field_service_updated_at') THEN
    CREATE TRIGGER update_field_service_updated_at BEFORE UPDATE ON field_service_tickets
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- 2.9 External Access Audit Log
CREATE TABLE IF NOT EXISTS external_access_audit_log (
  log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  user_id UUID NOT NULL REFERENCES users(id),
  organization_id UUID REFERENCES organizations(organization_id),
  action_type VARCHAR(50) NOT NULL,
  resource_type VARCHAR(50) NOT NULL,
  resource_id UUID NOT NULL,
  project_id UUID REFERENCES projects(id),
  ip_address VARCHAR(45),
  user_agent TEXT,
  action_details JSONB,
  accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_external_audit_user ON external_access_audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_external_audit_org ON external_access_audit_log(organization_id);
CREATE INDEX IF NOT EXISTS idx_external_audit_resource ON external_access_audit_log(resource_type, resource_id);
CREATE INDEX IF NOT EXISTS idx_external_audit_date ON external_access_audit_log(accessed_at DESC);
CREATE INDEX IF NOT EXISTS idx_external_audit_tenant ON external_access_audit_log(tenant_id);

ALTER TABLE external_access_audit_log ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'external_access_audit_log' AND policyname = 'external_audit_tenant_isolation') THEN
    CREATE POLICY external_audit_tenant_isolation ON external_access_audit_log
      USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
  END IF;
END $$;

-- =====================================================
-- STEP 3: UPDATE EXISTING TABLES
-- =====================================================

-- 3.1 Update drawings table
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS parent_drawing_id UUID REFERENCES drawings(id);
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS drawing_level INT DEFAULT 1;
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS drawing_path VARCHAR(500);
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS is_assembly BOOLEAN DEFAULT false;
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS drawing_category VARCHAR(50) DEFAULT 'CONSTRUCTION';
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS facility_id UUID REFERENCES facilities(facility_id);
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS equipment_id UUID REFERENCES equipment_register(equipment_id);
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS system_tag VARCHAR(50);
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS location_reference VARCHAR(255);
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS is_released BOOLEAN DEFAULT false;
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS released_by UUID REFERENCES users(id);
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS released_at TIMESTAMP WITH TIME ZONE;

-- Update status constraint
ALTER TABLE drawings DROP CONSTRAINT IF EXISTS drawings_status_check;
ALTER TABLE drawings ADD CONSTRAINT drawings_status_check 
  CHECK (status IN ('DRAFT', 'UNDER_REVIEW', 'APPROVED', 'RELEASED', 'REJECTED', 'SUPERSEDED', 'OBSOLETE'));

-- Add new constraints
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'check_drawing_level') THEN
    ALTER TABLE drawings ADD CONSTRAINT check_drawing_level 
      CHECK (drawing_level >= 1 AND drawing_level <= 5);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'drawings_category_check') THEN
    ALTER TABLE drawings ADD CONSTRAINT drawings_category_check
      CHECK (drawing_category IN ('CONSTRUCTION', 'MAINTENANCE', 'AS_BUILT', 'OPERATIONS'));
  END IF;
END $$;

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_drawings_parent ON drawings(parent_drawing_id);
CREATE INDEX IF NOT EXISTS idx_drawings_level ON drawings(drawing_level);
CREATE INDEX IF NOT EXISTS idx_drawings_category ON drawings(drawing_category);
CREATE INDEX IF NOT EXISTS idx_drawings_facility ON drawings(facility_id);
CREATE INDEX IF NOT EXISTS idx_drawings_equipment ON drawings(equipment_id);
CREATE INDEX IF NOT EXISTS idx_drawings_released ON drawings(is_released) WHERE is_released = true;

-- 3.2 Update drawing_revisions table
ALTER TABLE drawing_revisions ADD COLUMN IF NOT EXISTS is_released BOOLEAN DEFAULT false;
ALTER TABLE drawing_revisions ADD COLUMN IF NOT EXISTS released_at TIMESTAMP WITH TIME ZONE;

CREATE INDEX IF NOT EXISTS idx_drawing_revisions_released ON drawing_revisions(is_released) WHERE is_released = true;

-- =====================================================
-- STEP 4: VERIFICATION
-- =====================================================

-- Verify all tables exist
DO $$
BEGIN
  ASSERT (SELECT COUNT(*) FROM information_schema.tables 
          WHERE table_schema = 'public' 
          AND table_name IN (
            'organizations',
            'organization_relationships',
            'organization_users',
            'resource_access',
            'facilities',
            'equipment_register',
            'drawing_raci',
            'drawing_customer_approvals',
            'vendor_progress_updates',
            'field_service_tickets',
            'external_access_audit_log'
          )) = 11, 'Not all tables created';
  
  RAISE NOTICE 'All tables created successfully';
END $$;

-- =====================================================
-- SUMMARY
-- =====================================================
/*
TABLES CREATED: 11
1. organizations (if not exists)
2. organization_relationships (if not exists)
3. organization_users
4. resource_access
5. facilities
6. equipment_register
7. drawing_raci
8. drawing_customer_approvals
9. vendor_progress_updates
10. field_service_tickets
11. external_access_audit_log

TABLES UPDATED: 2
1. drawings (12 new fields)
2. drawing_revisions (2 new fields)

INDEXES CREATED: 50+
RLS POLICIES: 11
TRIGGERS: 9
*/
