-- =====================================================
-- EXTERNAL ACCESS MODULE - RESOURCE-BASED SCHEMA
-- =====================================================
-- Purpose: Flexible access control for any resource type
-- Access can be granted at: Project, Drawing, Document, Equipment level
-- Use cases: Production drawings, Maintenance manuals, Equipment specs
-- =====================================================

-- 1. ORGANIZATIONS (Already exists)
-- 2. ORGANIZATION_RELATIONSHIPS (Already exists)

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

-- 4. RESOURCE_ACCESS (Flexible resource-based access control)
CREATE TABLE resource_access (
  access_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  
  -- Flexible resource reference
  resource_type VARCHAR(50) NOT NULL, -- PROJECT, DRAWING, DOCUMENT, EQUIPMENT, WORK_PACKAGE
  resource_id UUID NOT NULL, -- ID of the resource
  
  -- Context (optional - for grouping/filtering)
  project_id UUID REFERENCES projects(project_id), -- Optional project context
  
  -- Access details
  access_purpose VARCHAR(50), -- APPROVAL, PRODUCTION, MAINTENANCE, REFERENCE, COLLABORATION
  access_level VARCHAR(20) DEFAULT 'READ', -- READ, WRITE, COMMENT
  allowed_actions TEXT[], -- ['VIEW', 'DOWNLOAD', 'COMMENT', 'APPROVE', 'EDIT']
  
  -- Time-bound access
  access_start_date DATE NOT NULL,
  access_end_date DATE,
  is_active BOOLEAN DEFAULT true,
  
  -- Metadata
  notes TEXT,
  granted_by UUID REFERENCES users(user_id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CHECK (resource_type IN ('PROJECT', 'DRAWING', 'DOCUMENT', 'EQUIPMENT', 'WORK_PACKAGE', 'MATERIAL')),
  CHECK (access_level IN ('READ', 'WRITE', 'COMMENT')),
  CHECK (access_purpose IN ('APPROVAL', 'PRODUCTION', 'MAINTENANCE', 'REFERENCE', 'COLLABORATION', 'SUPPLY')),
  CHECK (access_end_date IS NULL OR access_end_date >= access_start_date)
);

CREATE INDEX idx_resource_access_org ON resource_access(organization_id);
CREATE INDEX idx_resource_access_resource ON resource_access(resource_type, resource_id);
CREATE INDEX idx_resource_access_project ON resource_access(project_id);
CREATE INDEX idx_resource_access_tenant ON resource_access(tenant_id);
CREATE INDEX idx_resource_access_active ON resource_access(is_active, access_end_date);
CREATE INDEX idx_resource_access_purpose ON resource_access(access_purpose);

ALTER TABLE resource_access ENABLE ROW LEVEL SECURITY;
CREATE POLICY resource_access_tenant_isolation ON resource_access
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

CREATE TRIGGER update_resource_access_updated_at BEFORE UPDATE ON resource_access
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================

-- 5. DRAWING_CUSTOMER_APPROVALS (Customer drawing confirmations)
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

-- 6. VENDOR_PROGRESS_UPDATES (Vendor progress tracking)
CREATE TABLE vendor_progress_updates (
  update_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  project_id UUID REFERENCES projects(project_id), -- Optional - can be standalone
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

-- 7. FIELD_SERVICE_TICKETS (Contractor field service)
CREATE TABLE field_service_tickets (
  ticket_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  project_id UUID REFERENCES projects(project_id), -- Optional
  ticket_number VARCHAR(50) NOT NULL,
  
  assigned_organization_id UUID REFERENCES organizations(organization_id),
  assigned_contractor_id UUID REFERENCES users(user_id),
  
  service_type VARCHAR(50),
  priority VARCHAR(20),
  status VARCHAR(20) DEFAULT 'OPEN',
  
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  location VARCHAR(255),
  equipment_tag VARCHAR(50), -- Link to equipment
  
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
CREATE INDEX idx_field_service_equipment ON field_service_tickets(equipment_tag);
CREATE INDEX idx_field_service_tenant ON field_service_tickets(tenant_id);

ALTER TABLE field_service_tickets ENABLE ROW LEVEL SECURITY;
CREATE POLICY field_service_tenant_isolation ON field_service_tickets
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

CREATE TRIGGER update_field_service_updated_at BEFORE UPDATE ON field_service_tickets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================

-- 8. EXTERNAL_ACCESS_AUDIT_LOG (Audit trail)
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

-- Check if user has access to a specific resource
CREATE OR REPLACE FUNCTION user_has_resource_access(
  p_user_id UUID,
  p_resource_type VARCHAR(50),
  p_resource_id UUID,
  p_action VARCHAR(50) DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM organization_users ou
    JOIN resource_access ra ON ou.organization_id = ra.organization_id
    WHERE ou.user_id = p_user_id
    AND ra.resource_type = p_resource_type
    AND ra.resource_id = p_resource_id
    AND ra.is_active = true
    AND CURRENT_DATE BETWEEN ra.access_start_date 
        AND COALESCE(ra.access_end_date, '2099-12-31')
    AND (p_action IS NULL OR p_action = ANY(ra.allowed_actions))
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get user's organization
CREATE OR REPLACE FUNCTION get_user_organization(
  p_user_id UUID
) RETURNS UUID AS $$
BEGIN
  RETURN (
    SELECT organization_id
    FROM organization_users
    WHERE user_id = p_user_id
    AND is_active = true
    LIMIT 1
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user has project-level access
CREATE OR REPLACE FUNCTION user_has_project_access(
  p_user_id UUID,
  p_project_id UUID
) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM organization_users ou
    JOIN resource_access ra ON ou.organization_id = ra.organization_id
    WHERE ou.user_id = p_user_id
    AND ra.resource_type = 'PROJECT'
    AND ra.resource_id = p_project_id
    AND ra.is_active = true
    AND CURRENT_DATE BETWEEN ra.access_start_date 
        AND COALESCE(ra.access_end_date, '2099-12-31')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- RLS POLICIES FOR EXTERNAL USERS
-- =====================================================

-- Drawings: Access via project OR specific drawing access
CREATE POLICY drawings_external_access ON drawings
  FOR SELECT
  USING (
    -- Internal users see all
    NOT EXISTS (
      SELECT 1 FROM organization_users ou WHERE ou.user_id = auth.uid()
    )
    OR
    -- External users with project access
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
    -- External users with specific drawing access
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
  );

-- Drawing Comments: Can comment if they have access
CREATE POLICY drawing_comments_external_access ON drawing_comments
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM drawings d
      JOIN organization_users ou ON true
      JOIN resource_access ra ON ou.organization_id = ra.organization_id
      WHERE d.id = drawing_comments.drawing_id
      AND ou.user_id = auth.uid()
      AND (
        (ra.resource_type = 'PROJECT' AND ra.resource_id = d.project_id)
        OR (ra.resource_type = 'DRAWING' AND ra.resource_id = d.id)
      )
      AND ra.is_active = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM drawings d
      JOIN organization_users ou ON true
      JOIN resource_access ra ON ou.organization_id = ra.organization_id
      WHERE d.id = drawing_comments.drawing_id
      AND ou.user_id = auth.uid()
      AND (
        (ra.resource_type = 'PROJECT' AND ra.resource_id = d.project_id)
        OR (ra.resource_type = 'DRAWING' AND ra.resource_id = d.id)
      )
      AND ra.access_level IN ('COMMENT', 'WRITE')
      AND 'COMMENT' = ANY(ra.allowed_actions)
    )
  );

-- Vendor Progress: Own organization only
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
  );

-- Field Service Tickets: Assigned organization only
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
-- EXAMPLE USE CASES
-- =====================================================

-- Use Case 1: Grant project-level access to customer
-- INSERT INTO resource_access (tenant_id, organization_id, resource_type, resource_id, project_id, access_purpose, access_level, allowed_actions, access_start_date)
-- VALUES ('tenant-1', 'customer-org-1', 'PROJECT', 'project-a', 'project-a', 'APPROVAL', 'COMMENT', ARRAY['VIEW', 'DOWNLOAD', 'COMMENT', 'APPROVE'], '2024-01-01');

-- Use Case 2: Grant specific drawing access for production
-- INSERT INTO resource_access (tenant_id, organization_id, resource_type, resource_id, project_id, access_purpose, access_level, allowed_actions, access_start_date)
-- VALUES ('tenant-1', 'vendor-org-1', 'DRAWING', 'drawing-123', NULL, 'PRODUCTION', 'READ', ARRAY['VIEW', 'DOWNLOAD'], '2024-01-01');

-- Use Case 3: Grant maintenance manual access
-- INSERT INTO resource_access (tenant_id, organization_id, resource_type, resource_id, project_id, access_purpose, access_level, allowed_actions, access_start_date)
-- VALUES ('tenant-1', 'contractor-org-1', 'DOCUMENT', 'manual-456', NULL, 'MAINTENANCE', 'READ', ARRAY['VIEW', 'DOWNLOAD'], '2024-01-01');

-- Use Case 4: Grant equipment access for service
-- INSERT INTO resource_access (tenant_id, organization_id, resource_type, resource_id, project_id, access_purpose, access_level, allowed_actions, access_start_date)
-- VALUES ('tenant-1', 'service-org-1', 'EQUIPMENT', 'equip-789', NULL, 'MAINTENANCE', 'WRITE', ARRAY['VIEW', 'EDIT', 'COMMENT'], '2024-01-01');

-- =====================================================
-- SUMMARY
-- =====================================================
-- Resource-Based Access Control
-- 
-- Key Table: resource_access
-- - Flexible: Works with any resource type (PROJECT, DRAWING, DOCUMENT, EQUIPMENT)
-- - Granular: Can grant access to specific items or entire projects
-- - Purpose-driven: Track why access was granted (APPROVAL, PRODUCTION, MAINTENANCE)
-- - Action-based: Control specific actions (VIEW, DOWNLOAD, COMMENT, APPROVE, EDIT)
-- - Time-bound: Start/end dates for temporary access
--
-- Access Levels:
-- 1. Project-level: Access all resources in a project
-- 2. Resource-specific: Access only specific drawings/documents/equipment
-- 3. Hybrid: Mix of both (project access + specific resource access)
--
-- Use Cases Supported:
-- ✅ Customer approval of project drawings
-- ✅ Vendor access to production drawings (no project context)
-- ✅ Contractor access to maintenance manuals
-- ✅ Service provider access to equipment specs
-- ✅ Supplier access to material specifications
