-- =====================================================
-- DROP AND RECREATE EXTERNAL ACCESS TABLES
-- =====================================================

-- Drop existing tables
DROP TABLE IF EXISTS external_access_audit_log CASCADE;
DROP TABLE IF EXISTS drawing_raci CASCADE;
DROP TABLE IF EXISTS vendor_progress_updates CASCADE;
DROP TABLE IF EXISTS drawing_customer_approvals CASCADE;
DROP TABLE IF EXISTS resource_access CASCADE;
DROP TABLE IF EXISTS external_org_relationships CASCADE;
DROP TABLE IF EXISTS external_org_users CASCADE;

-- 1. EXTERNAL_ORG_USERS
CREATE TABLE public.external_org_users (
  org_user_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  external_org_id UUID NOT NULL,
  user_id UUID NOT NULL,
  role VARCHAR(50) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  invited_by UUID,
  invited_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT external_org_users_pkey PRIMARY KEY (org_user_id),
  CONSTRAINT external_org_users_unique UNIQUE (external_org_id, user_id)
);

CREATE INDEX idx_ext_org_users_org ON external_org_users(external_org_id);
CREATE INDEX idx_ext_org_users_user ON external_org_users(user_id);

CREATE TRIGGER update_external_org_users_updated_at 
  BEFORE UPDATE ON external_org_users 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- 2. EXTERNAL_ORG_RELATIONSHIPS
CREATE TABLE public.external_org_relationships (
  relationship_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  parent_org_id UUID NOT NULL,
  child_org_id UUID NOT NULL,
  relationship_type VARCHAR(50) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT external_org_relationships_pkey PRIMARY KEY (relationship_id)
);

CREATE INDEX idx_ext_org_rel_parent ON external_org_relationships(parent_org_id);
CREATE INDEX idx_ext_org_rel_child ON external_org_relationships(child_org_id);

CREATE TRIGGER update_external_org_relationships_updated_at 
  BEFORE UPDATE ON external_org_relationships 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- 3. RESOURCE_ACCESS
CREATE TABLE public.resource_access (
  access_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  external_org_id UUID NOT NULL,
  resource_type VARCHAR(50) NOT NULL,
  resource_id UUID NOT NULL,
  access_level VARCHAR(20) NOT NULL DEFAULT 'VIEW',
  access_start_date DATE,
  access_end_date DATE,
  is_active BOOLEAN DEFAULT true,
  granted_by UUID,
  granted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT resource_access_pkey PRIMARY KEY (access_id)
);

CREATE INDEX idx_resource_access_org ON resource_access(external_org_id);
CREATE INDEX idx_resource_access_type ON resource_access(resource_type);
CREATE INDEX idx_resource_access_resource ON resource_access(resource_id);

CREATE TRIGGER update_resource_access_updated_at 
  BEFORE UPDATE ON resource_access 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- 4. DRAWING_CUSTOMER_APPROVALS
CREATE TABLE public.drawing_customer_approvals (
  approval_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  drawing_id UUID NOT NULL,
  external_org_id UUID NOT NULL,
  approval_status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
  approved_by UUID,
  approved_at TIMESTAMP WITH TIME ZONE,
  comments TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT drawing_customer_approvals_pkey PRIMARY KEY (approval_id)
);

CREATE INDEX idx_drawing_approvals_drawing ON drawing_customer_approvals(drawing_id);
CREATE INDEX idx_drawing_approvals_org ON drawing_customer_approvals(external_org_id);

CREATE TRIGGER update_drawing_customer_approvals_updated_at 
  BEFORE UPDATE ON drawing_customer_approvals 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- 5. VENDOR_PROGRESS_UPDATES
CREATE TABLE public.vendor_progress_updates (
  update_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  drawing_id UUID NOT NULL,
  external_org_id UUID NOT NULL,
  progress_percentage INTEGER NOT NULL DEFAULT 0,
  status VARCHAR(50) NOT NULL DEFAULT 'NOT_STARTED',
  notes TEXT,
  submitted_by UUID,
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT vendor_progress_updates_pkey PRIMARY KEY (update_id)
);

CREATE INDEX idx_vendor_progress_drawing ON vendor_progress_updates(drawing_id);
CREATE INDEX idx_vendor_progress_org ON vendor_progress_updates(external_org_id);

CREATE TRIGGER update_vendor_progress_updates_updated_at 
  BEFORE UPDATE ON vendor_progress_updates 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- 6. DRAWING_RACI
CREATE TABLE public.drawing_raci (
  raci_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  drawing_id UUID NOT NULL,
  user_id UUID,
  external_org_id UUID,
  raci_role VARCHAR(1) NOT NULL,
  responsibility_area VARCHAR(200),
  assigned_by UUID,
  assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT drawing_raci_pkey PRIMARY KEY (raci_id)
);

CREATE INDEX idx_drawing_raci_drawing ON drawing_raci(drawing_id);
CREATE INDEX idx_drawing_raci_user ON drawing_raci(user_id);
CREATE INDEX idx_drawing_raci_org ON drawing_raci(external_org_id);

CREATE TRIGGER update_drawing_raci_updated_at 
  BEFORE UPDATE ON drawing_raci 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- 7. EXTERNAL_ACCESS_AUDIT_LOG
CREATE TABLE public.external_access_audit_log (
  log_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  user_id UUID,
  action_type VARCHAR(50) NOT NULL,
  table_name VARCHAR(100),
  record_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address VARCHAR(50),
  user_agent TEXT,
  performed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT external_access_audit_log_pkey PRIMARY KEY (log_id)
);

CREATE INDEX idx_audit_log_user ON external_access_audit_log(user_id);
CREATE INDEX idx_audit_log_action ON external_access_audit_log(action_type);
CREATE INDEX idx_audit_log_performed ON external_access_audit_log(performed_at);
