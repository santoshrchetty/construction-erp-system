-- =====================================================
-- EXTERNAL ACCESS MODULE - DATABASE SCHEMA
-- =====================================================
-- Purpose: Manage external organizations (customers, vendors, contractors)
-- and their access to projects and modules
--
-- NOTE: organizations table already exists with structure:
--   organization_id, tenant_id, org_code, org_name, is_internal, is_active
-- =====================================================

-- 1. ORGANIZATION_METADATA (Extended organization info)
CREATE TABLE organization_metadata (
  metadata_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  
  organization_type VARCHAR(20), -- CUSTOMER, VENDOR, CONTRACTOR, CONSULTANT
  primary_contact_name VARCHAR(255),
  primary_contact_email VARCHAR(255),
  primary_contact_phone VARCHAR(50),
  address TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(organization_id),
  CHECK (organization_type IN ('CUSTOMER', 'VENDOR', 'CONTRACTOR', 'CONSULTANT'))
);

CREATE INDEX idx_org_metadata_org ON organization_metadata(organization_id);
CREATE INDEX idx_org_metadata_tenant ON organization_metadata(tenant_id);
CREATE INDEX idx_org_metadata_type ON organization_metadata(organization_type);

ALTER TABLE organization_metadata ENABLE ROW LEVEL SECURITY;

CREATE POLICY org_metadata_tenant_isolation ON organization_metadata
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

CREATE TRIGGER update_org_metadata_updated_at BEFORE UPDATE ON organization_metadata
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================

-- 2. ORGANIZATION_RELATIONSHIPS (Supply Chain Graph - Already exists)
-- Existing table structure:
--   relationship_id, tenant_id, source_org_id, target_org_id, relationship_type
--   CHECK: relationship_type IN ('CUSTOMER', 'VENDOR', 'PARTNER')

-- =====================================================
-- 3. ORGANIZATION_USERS (Link users to organizations)
CREATE TABLE organization_users (
  org_user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  user_id UUID NOT NULL REFERENCES users(user_id),
  position_title VARCHAR(255),
  is_primary_contact BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(organization_id, user_id)
);

CREATE INDEX idx_org_users_org ON organization_users(organization_id);
CREATE INDEX idx_org_users_user ON organization_users(user_id);
CREATE INDEX idx_org_users_tenant ON organization_users(tenant_id);

ALTER TABLE organization_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY org_users_tenant_isolation ON organization_users
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

CREATE TRIGGER update_org_users_updated_at BEFORE UPDATE ON organization_users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================

-- 4. PROJECT_ORGANIZATION_ACCESS (Project-level access control)
CREATE TABLE project_organization_access (
  access_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  project_id UUID NOT NULL REFERENCES projects(project_id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  
  -- Access context
  access_granted_by_org_id UUID REFERENCES organizations(organization_id), -- NULL = direct from tenant
  role_in_project VARCHAR(20) NOT NULL, -- CUSTOMER, VENDOR, CONTRACTOR, CONSULTANT
  tier_level INT DEFAULT 1, -- 1=direct, 2=sub-vendor, 3=sub-sub-vendor
  
  -- Permissions
  allowed_modules TEXT[], -- ['DRAWINGS', 'VENDOR_PROGRESS', 'FIELD_SERVICE', 'WORKFLOW']
  access_level VARCHAR(20) DEFAULT 'READ', -- READ, WRITE, COMMENT
  can_invite_subcontractors BOOLEAN DEFAULT false,
  
  -- Time-bound access
  access_start_date DATE NOT NULL,
  access_end_date DATE,
  is_active BOOLEAN DEFAULT true,
  
  created_by UUID REFERENCES users(user_id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(project_id, organization_id),
  CHECK (role_in_project IN ('CUSTOMER', 'VENDOR', 'CONTRACTOR', 'CONSULTANT')),
  CHECK (access_level IN ('READ', 'WRITE', 'COMMENT')),
  CHECK (tier_level >= 1 AND tier_level <= 5)
);

CREATE INDEX idx_proj_org_access_project ON project_organization_access(project_id);
CREATE INDEX idx_proj_org_access_org ON project_organization_access(organization_id);
CREATE INDEX idx_proj_org_access_granted_by ON project_organization_access(access_granted_by_org_id);
CREATE INDEX idx_proj_org_access_tenant ON project_organization_access(tenant_id);
CREATE INDEX idx_proj_org_access_active ON project_organization_access(is_active, access_end_date);

-- Row Level Security
ALTER TABLE project_organization_access ENABLE ROW LEVEL SECURITY;

CREATE POLICY proj_org_access_tenant_isolation ON project_organization_access
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- =====================================================

-- 5. DRAWING_CUSTOMER_APPROVALS (Customer drawing confirmations)
CREATE TABLE drawing_customer_approvals (
  approval_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  drawing_id UUID NOT NULL REFERENCES drawings(id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  customer_user_id UUID NOT NULL REFERENCES users(user_id),
  
  approval_status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED, CLARIFICATION_NEEDED
  comments TEXT,
  attachments JSONB,
  
  approved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CHECK (approval_status IN ('PENDING', 'APPROVED', 'REJECTED', 'CLARIFICATION_NEEDED'))
);

CREATE INDEX idx_drawing_customer_approvals_drawing ON drawing_customer_approvals(drawing_id);
CREATE INDEX idx_drawing_customer_approvals_org ON drawing_customer_approvals(organization_id);
CREATE INDEX idx_drawing_customer_approvals_status ON drawing_customer_approvals(approval_status);
CREATE INDEX idx_drawing_customer_approvals_tenant ON drawing_customer_approvals(tenant_id);

-- Row Level Security
ALTER TABLE drawing_customer_approvals ENABLE ROW LEVEL SECURITY;

CREATE POLICY drawing_customer_approvals_tenant_isolation ON drawing_customer_approvals
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- =====================================================

-- 6. VENDOR_PROGRESS_UPDATES (Vendor progress tracking)
CREATE TABLE vendor_progress_updates (
  update_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  project_id UUID NOT NULL REFERENCES projects(project_id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  vendor_user_id UUID NOT NULL REFERENCES users(user_id),
  
  work_package_id UUID, -- Link to work packages (future)
  progress_percentage DECIMAL(5,2),
  status VARCHAR(50), -- ON_TRACK, DELAYED, AT_RISK, COMPLETED
  update_description TEXT NOT NULL,
  attachments JSONB,
  reported_date DATE NOT NULL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  CHECK (status IN ('ON_TRACK', 'DELAYED', 'AT_RISK', 'COMPLETED'))
);

CREATE INDEX idx_vendor_progress_project ON vendor_progress_updates(project_id);
CREATE INDEX idx_vendor_progress_org ON vendor_progress_updates(organization_id);
CREATE INDEX idx_vendor_progress_date ON vendor_progress_updates(reported_date DESC);
CREATE INDEX idx_vendor_progress_tenant ON vendor_progress_updates(tenant_id);

-- Row Level Security
ALTER TABLE vendor_progress_updates ENABLE ROW LEVEL SECURITY;

CREATE POLICY vendor_progress_tenant_isolation ON vendor_progress_updates
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- =====================================================

-- 7. FIELD_SERVICE_TICKETS (Contractor field service management)
CREATE TABLE field_service_tickets (
  ticket_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  project_id UUID NOT NULL REFERENCES projects(project_id),
  ticket_number VARCHAR(50) NOT NULL,
  
  assigned_organization_id UUID REFERENCES organizations(organization_id),
  assigned_contractor_id UUID REFERENCES users(user_id),
  
  service_type VARCHAR(50), -- INSPECTION, MAINTENANCE, INSTALLATION, REPAIR
  priority VARCHAR(20), -- LOW, MEDIUM, HIGH, CRITICAL
  status VARCHAR(20) DEFAULT 'OPEN', -- OPEN, IN_PROGRESS, COMPLETED, CLOSED, CANCELLED
  
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  location VARCHAR(255),
  
  scheduled_date DATE,
  completed_date DATE,
  
  created_by UUID REFERENCES users(user_id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(tenant_id, ticket_number),
  CHECK (service_type IN ('INSPECTION', 'MAINTENANCE', 'INSTALLATION', 'REPAIR')),
  CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
  CHECK (status IN ('OPEN', 'IN_PROGRESS', 'COMPLETED', 'CLOSED', 'CANCELLED'))
);

CREATE INDEX idx_field_service_project ON field_service_tickets(project_id);
CREATE INDEX idx_field_service_org ON field_service_tickets(assigned_organization_id);
CREATE INDEX idx_field_service_status ON field_service_tickets(status);
CREATE INDEX idx_field_service_priority ON field_service_tickets(priority);
CREATE INDEX idx_field_service_tenant ON field_service_tickets(tenant_id);

-- Row Level Security
ALTER TABLE field_service_tickets ENABLE ROW LEVEL SECURITY;

CREATE POLICY field_service_tenant_isolation ON field_service_tickets
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- =====================================================

-- 8. EXTERNAL_WORKFLOW_NOTIFICATIONS (Track external user notifications)
CREATE TABLE external_workflow_notifications (
  notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  step_instance_id UUID NOT NULL REFERENCES step_instances(id),
  external_user_id UUID NOT NULL REFERENCES users(user_id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  
  notification_type VARCHAR(50), -- EMAIL, SMS, PORTAL
  notification_subject VARCHAR(255),
  notification_body TEXT,
  
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  opened_at TIMESTAMP WITH TIME ZONE,
  actioned_at TIMESTAMP WITH TIME ZONE,
  
  CHECK (notification_type IN ('EMAIL', 'SMS', 'PORTAL'))
);

CREATE INDEX idx_external_notif_step ON external_workflow_notifications(step_instance_id);
CREATE INDEX idx_external_notif_user ON external_workflow_notifications(external_user_id);
CREATE INDEX idx_external_notif_org ON external_workflow_notifications(organization_id);
CREATE INDEX idx_external_notif_tenant ON external_workflow_notifications(tenant_id);

-- Row Level Security
ALTER TABLE external_workflow_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY external_notif_tenant_isolation ON external_workflow_notifications
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- =====================================================

-- 9. EXTERNAL_ACCESS_AUDIT_LOG (Comprehensive audit trail)
CREATE TABLE external_access_audit_log (
  log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  user_id UUID NOT NULL REFERENCES users(user_id),
  organization_id UUID REFERENCES organizations(organization_id),
  
  action_type VARCHAR(50) NOT NULL, -- VIEW, DOWNLOAD, UPLOAD, COMMENT, APPROVE, REJECT
  resource_type VARCHAR(50) NOT NULL, -- DRAWING, PROGRESS_UPDATE, TICKET, WORKFLOW
  resource_id UUID NOT NULL,
  project_id UUID REFERENCES projects(project_id),
  
  ip_address VARCHAR(45),
  user_agent TEXT,
  action_details JSONB,
  
  accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_external_audit_user ON external_access_audit_log(user_id);
CREATE INDEX idx_external_audit_org ON external_access_audit_log(organization_id);
CREATE INDEX idx_external_audit_resource ON external_access_audit_log(resource_type, resource_id);
CREATE INDEX idx_external_audit_project ON external_access_audit_log(project_id);
CREATE INDEX idx_external_audit_date ON external_access_audit_log(accessed_at DESC);
CREATE INDEX idx_external_audit_tenant ON external_access_audit_log(tenant_id);

-- Row Level Security
ALTER TABLE external_access_audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY external_audit_tenant_isolation ON external_access_audit_log
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function: Get organization tier level for a project
CREATE OR REPLACE FUNCTION get_organization_tier_level(
  p_organization_id UUID,
  p_project_id UUID
) RETURNS INT AS $$
BEGIN
  RETURN (
    SELECT tier_level 
    FROM project_organization_access
    WHERE organization_id = p_organization_id
    AND project_id = p_project_id
    AND is_active = true
    AND CURRENT_DATE BETWEEN access_start_date AND COALESCE(access_end_date, '2099-12-31')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Check if user has module access
CREATE OR REPLACE FUNCTION user_has_module_access(
  p_user_id UUID,
  p_project_id UUID,
  p_module_name TEXT
) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM organization_users ou
    JOIN project_organization_access poa ON ou.organization_id = poa.organization_id
    WHERE ou.user_id = p_user_id
    AND poa.project_id = p_project_id
    AND poa.is_active = true
    AND p_module_name = ANY(poa.allowed_modules)
    AND CURRENT_DATE BETWEEN poa.access_start_date AND COALESCE(poa.access_end_date, '2099-12-31')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- SUMMARY
-- =====================================================
-- Tables Created: 8
-- 1. organization_metadata - Extended organization info (organizations table already exists)
-- 2. organization_relationships - Already exists (supply chain graph)
-- 3. organization_users - Link users to organizations
-- 4. project_organization_access - Project-level tiered access control
-- 5. drawing_customer_approvals - Customer drawing confirmations
-- 6. vendor_progress_updates - Vendor progress tracking
-- 7. field_service_tickets - Contractor field service management
-- 8. external_workflow_notifications - External user workflow notifications
-- 9. external_access_audit_log - Comprehensive audit trail
--
-- Key Features:
-- - Multi-role organizations (can be both customer AND vendor)
-- - Supply chain relationships (vendor's vendor access)
-- - Tiered access control (1=direct, 2=sub-vendor, 3=sub-sub-vendor)
-- - Project-based access with time bounds
-- - Module-level permissions
-- - Complete audit trail
