-- =====================================================
-- EXTERNAL ACCESS MODULE - SIMPLIFIED SCHEMA
-- =====================================================
-- Purpose: Simple, direct access for external organizations
-- No tier complexity - just project-based access control
-- =====================================================

-- 1. ORGANIZATIONS (Already exists - reference only)
-- Structure: organization_id, tenant_id, org_code, org_name, is_internal, is_active

-- 2. ORGANIZATION_RELATIONSHIPS (Already exists - reference only)
-- Structure: relationship_id, tenant_id, source_org_id, target_org_id, relationship_type

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

-- 4. PROJECT_ORGANIZATION_ACCESS (Simple project-based access)
CREATE TABLE project_organization_access (
  access_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  project_id UUID NOT NULL REFERENCES projects(project_id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  
  -- Simple role
  role_in_project VARCHAR(20) NOT NULL, -- CUSTOMER, VENDOR, CONTRACTOR, CONSULTANT
  
  -- Module permissions (array of allowed modules)
  allowed_modules TEXT[], -- ['DRAWINGS', 'VENDOR_PROGRESS', 'FIELD_SERVICE', 'WORKFLOW']
  
  -- Simple access level
  access_level VARCHAR(20) DEFAULT 'READ', -- READ, WRITE, COMMENT
  
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
  CHECK (access_end_date IS NULL OR access_end_date >= access_start_date)
);

CREATE INDEX idx_proj_org_access_project ON project_organization_access(project_id);
CREATE INDEX idx_proj_org_access_org ON project_organization_access(organization_id);
CREATE INDEX idx_proj_org_access_tenant ON project_organization_access(tenant_id);
CREATE INDEX idx_proj_org_access_active ON project_organization_access(is_active, access_end_date);

ALTER TABLE project_organization_access ENABLE ROW LEVEL SECURITY;
CREATE POLICY proj_org_access_tenant_isolation ON project_organization_access
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

CREATE TRIGGER update_proj_org_access_updated_at BEFORE UPDATE ON project_organization_access
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================

-- 5. DRAWING_ASSIGNMENTS (Assign drawings to external orgs)
CREATE TABLE drawing_assignments (
  assignment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  drawing_id UUID NOT NULL REFERENCES drawings(id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  assigned_by UUID NOT NULL REFERENCES users(user_id),
  
  due_date DATE,
  is_mandatory BOOLEAN DEFAULT true,
  assignment_status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, IN_REVIEW, COMPLETED
  
  assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  
  UNIQUE(drawing_id, organization_id),
  CHECK (assignment_status IN ('PENDING', 'IN_REVIEW', 'COMPLETED'))
);

CREATE INDEX idx_drawing_assignments_drawing ON drawing_assignments(drawing_id);
CREATE INDEX idx_drawing_assignments_org ON drawing_assignments(organization_id);
CREATE INDEX idx_drawing_assignments_status ON drawing_assignments(assignment_status);
CREATE INDEX idx_drawing_assignments_tenant ON drawing_assignments(tenant_id);

ALTER TABLE drawing_assignments ENABLE ROW LEVEL SECURITY;
CREATE POLICY drawing_assignments_tenant_isolation ON drawing_assignments
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- =====================================================

-- 6. DRAWING_CUSTOMER_APPROVALS (Customer drawing confirmations)
CREATE TABLE drawing_customer_approvals (
  approval_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  drawing_id UUID NOT NULL REFERENCES drawings(id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  customer_user_id UUID NOT NULL REFERENCES users(user_id),
  
  approval_status VARCHAR(20) DEFAULT 'PENDING',
  comments TEXT,
  attachments JSONB,
  
  approved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CHECK (approval_status IN ('PENDING', 'APPROVED', 'REJECTED', 'CLARIFICATION_NEEDED'))
);

CREATE INDEX idx_drawing_approvals_drawing ON drawing_customer_approvals(drawing_id);
CREATE INDEX idx_drawing_approvals_org ON drawing_customer_approvals(organization_id);
CREATE INDEX idx_drawing_approvals_status ON drawing_customer_approvals(approval_status);
CREATE INDEX idx_drawing_approvals_tenant ON drawing_customer_approvals(tenant_id);

ALTER TABLE drawing_customer_approvals ENABLE ROW LEVEL SECURITY;
CREATE POLICY drawing_approvals_tenant_isolation ON drawing_customer_approvals
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

CREATE TRIGGER update_drawing_approvals_updated_at BEFORE UPDATE ON drawing_customer_approvals
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================

-- 7. VENDOR_PROGRESS_UPDATES (Vendor progress tracking)
CREATE TABLE vendor_progress_updates (
  update_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  project_id UUID NOT NULL REFERENCES projects(project_id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  vendor_user_id UUID NOT NULL REFERENCES users(user_id),
  
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

CREATE INDEX idx_vendor_progress_project ON vendor_progress_updates(project_id);
CREATE INDEX idx_vendor_progress_org ON vendor_progress_updates(organization_id);
CREATE INDEX idx_vendor_progress_date ON vendor_progress_updates(reported_date DESC);
CREATE INDEX idx_vendor_progress_tenant ON vendor_progress_updates(tenant_id);

ALTER TABLE vendor_progress_updates ENABLE ROW LEVEL SECURITY;
CREATE POLICY vendor_progress_tenant_isolation ON vendor_progress_updates
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

CREATE TRIGGER update_vendor_progress_updated_at BEFORE UPDATE ON vendor_progress_updates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================

-- 8. FIELD_SERVICE_TICKETS (Contractor field service)
CREATE TABLE field_service_tickets (
  ticket_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  project_id UUID NOT NULL REFERENCES projects(project_id),
  ticket_number VARCHAR(50) NOT NULL,
  
  assigned_organization_id UUID REFERENCES organizations(organization_id),
  assigned_contractor_id UUID REFERENCES users(user_id),
  
  service_type VARCHAR(50),
  priority VARCHAR(20),
  status VARCHAR(20) DEFAULT 'OPEN',
  
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
CREATE INDEX idx_field_service_tenant ON field_service_tickets(tenant_id);

ALTER TABLE field_service_tickets ENABLE ROW LEVEL SECURITY;
CREATE POLICY field_service_tenant_isolation ON field_service_tickets
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

CREATE TRIGGER update_field_service_updated_at BEFORE UPDATE ON field_service_tickets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================

-- 9. EXTERNAL_ACCESS_AUDIT_LOG (Audit trail)
CREATE TABLE external_access_audit_log (
  log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  user_id UUID NOT NULL REFERENCES users(user_id),
  organization_id UUID REFERENCES organizations(organization_id),
  
  action_type VARCHAR(50) NOT NULL,
  resource_type VARCHAR(50) NOT NULL,
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
CREATE INDEX idx_external_audit_date ON external_access_audit_log(accessed_at DESC);
CREATE INDEX idx_external_audit_tenant ON external_access_audit_log(tenant_id);

ALTER TABLE external_access_audit_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY external_audit_tenant_isolation ON external_access_audit_log
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Check if user has module access
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
    AND CURRENT_DATE BETWEEN poa.access_start_date 
        AND COALESCE(poa.access_end_date, '2099-12-31')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get user's organization for a project
CREATE OR REPLACE FUNCTION get_user_organization(
  p_user_id UUID,
  p_project_id UUID
) RETURNS UUID AS $$
BEGIN
  RETURN (
    SELECT ou.organization_id
    FROM organization_users ou
    JOIN project_organization_access poa ON ou.organization_id = poa.organization_id
    WHERE ou.user_id = p_user_id
    AND poa.project_id = p_project_id
    AND poa.is_active = true
    LIMIT 1
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- RLS POLICIES FOR EXTERNAL USERS
-- =====================================================

-- Drawings: External users see only assigned project drawings
CREATE POLICY drawings_external_access ON drawings
  FOR SELECT
  USING (
    -- Internal users see all
    NOT EXISTS (
      SELECT 1 FROM organization_users ou WHERE ou.user_id = auth.uid()
    )
    OR
    -- External users see project drawings they have access to
    EXISTS (
      SELECT 1 FROM organization_users ou
      JOIN project_organization_access poa ON ou.organization_id = poa.organization_id
      WHERE ou.user_id = auth.uid()
      AND poa.project_id = drawings.project_id
      AND poa.is_active = true
      AND 'DRAWINGS' = ANY(poa.allowed_modules)
      AND CURRENT_DATE BETWEEN poa.access_start_date 
          AND COALESCE(poa.access_end_date, '2099-12-31')
    )
  );

-- Drawing Comments: Can view/add comments based on access level
CREATE POLICY drawing_comments_external_access ON drawing_comments
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM drawings d
      JOIN organization_users ou ON true
      JOIN project_organization_access poa ON ou.organization_id = poa.organization_id
      WHERE d.id = drawing_comments.drawing_id
      AND ou.user_id = auth.uid()
      AND poa.project_id = d.project_id
      AND 'DRAWINGS' = ANY(poa.allowed_modules)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM drawings d
      JOIN organization_users ou ON true
      JOIN project_organization_access poa ON ou.organization_id = poa.organization_id
      WHERE d.id = drawing_comments.drawing_id
      AND ou.user_id = auth.uid()
      AND poa.project_id = d.project_id
      AND poa.access_level IN ('COMMENT', 'WRITE')
    )
  );

-- Vendor Progress: Can only see/edit own organization's updates
CREATE POLICY vendor_progress_own_org ON vendor_progress_updates
  FOR ALL
  USING (
    NOT EXISTS (SELECT 1 FROM organization_users ou WHERE ou.user_id = auth.uid())
    OR
    EXISTS (
      SELECT 1 FROM organization_users ou
      WHERE ou.user_id = auth.uid()
      AND ou.organization_id = vendor_progress_updates.organization_id
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM organization_users ou
      JOIN project_organization_access poa ON ou.organization_id = poa.organization_id
      WHERE ou.user_id = auth.uid()
      AND ou.organization_id = vendor_progress_updates.organization_id
      AND poa.project_id = vendor_progress_updates.project_id
      AND 'VENDOR_PROGRESS' = ANY(poa.allowed_modules)
      AND poa.access_level = 'WRITE'
    )
  );

-- Field Service Tickets: Can only see assigned tickets
CREATE POLICY field_service_external_access ON field_service_tickets
  FOR ALL
  USING (
    NOT EXISTS (SELECT 1 FROM organization_users ou WHERE ou.user_id = auth.uid())
    OR
    EXISTS (
      SELECT 1 FROM organization_users ou
      WHERE ou.user_id = auth.uid()
      AND ou.organization_id = field_service_tickets.assigned_organization_id
    )
  );

-- =====================================================
-- SUMMARY
-- =====================================================
-- Simplified Schema - No Tier Complexity
-- 
-- Tables: 7 new tables
-- 1. organization_users - Link users to organizations
-- 2. project_organization_access - Simple project-based access
-- 3. drawing_assignments - Assign drawings to external orgs
-- 4. drawing_customer_approvals - Customer approvals
-- 5. vendor_progress_updates - Vendor progress
-- 6. field_service_tickets - Field service
-- 7. external_access_audit_log - Audit trail
--
-- Key Simplifications:
-- ✅ No tier levels - just direct project access
-- ✅ No access_granted_by - simplified invitation
-- ✅ No can_invite_subcontractors - removed complexity
-- ✅ Simple role + module + access_level model
-- ✅ Straightforward RLS policies
--
-- Access Model:
-- 1. Organization is linked to project
-- 2. Users belong to organization
-- 3. Access controlled by: role + allowed_modules + access_level + dates
-- 4. RLS enforces data isolation automatically
