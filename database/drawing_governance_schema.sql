-- =====================================================
-- DRAWING GOVERNANCE MODULE - DATABASE SCHEMA
-- =====================================================

-- 1. DRAWINGS (Core Entity)
CREATE TABLE drawings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  
  -- Drawing Identification
  drawing_number VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  revision VARCHAR(10) NOT NULL DEFAULT 'A',
  
  -- Classification
  discipline VARCHAR(50) NOT NULL, -- MECHANICAL, ELECTRICAL, CIVIL, PIPING, INSTRUMENTATION, STRUCTURAL
  drawing_type VARCHAR(50) NOT NULL, -- GA, DETAIL, ASSEMBLY, SCHEMATIC, LAYOUT, ISOMETRIC
  drawing_size VARCHAR(10), -- A0, A1, A2, A3, A4
  scale VARCHAR(20), -- 1:1, 1:2, 1:5, 1:10, 1:50, 1:100
  
  -- Relationships
  project_id UUID REFERENCES projects(id),
  equipment_tag VARCHAR(50), -- Link to equipment (future)
  
  -- File Information
  file_path VARCHAR(500) NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_size_mb DECIMAL(10,2),
  file_type VARCHAR(20), -- PDF, DWG, DXF
  
  -- Status & Workflow
  status VARCHAR(20) NOT NULL DEFAULT 'DRAFT', -- DRAFT, UNDER_REVIEW, APPROVED, REJECTED, SUPERSEDED, OBSOLETE
  workflow_instance_id UUID REFERENCES workflow_instances(id),
  
  -- Metadata
  description TEXT,
  tags TEXT[], -- For search
  
  -- Supersession
  superseded_by UUID REFERENCES drawings(id),
  superseded_at TIMESTAMP WITH TIME ZONE,
  
  -- Audit Fields
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_by UUID REFERENCES users(id),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMP WITH TIME ZONE,
  
  -- Constraints
  UNIQUE(tenant_id, drawing_number, revision),
  CHECK (status IN ('DRAFT', 'UNDER_REVIEW', 'APPROVED', 'REJECTED', 'SUPERSEDED', 'OBSOLETE'))
);

-- Indexes for performance
CREATE INDEX idx_drawings_tenant ON drawings(tenant_id);
CREATE INDEX idx_drawings_project ON drawings(project_id);
CREATE INDEX idx_drawings_status ON drawings(status);
CREATE INDEX idx_drawings_discipline ON drawings(discipline);
CREATE INDEX idx_drawings_created_at ON drawings(created_at DESC);
CREATE INDEX idx_drawings_number ON drawings(drawing_number);
CREATE INDEX idx_drawings_search ON drawings USING gin(to_tsvector('english', title || ' ' || COALESCE(description, '')));

-- Row Level Security
ALTER TABLE drawings ENABLE ROW LEVEL SECURITY;

CREATE POLICY drawings_tenant_isolation ON drawings
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- =====================================================

-- 2. DRAWING_REVISIONS (Version History)
CREATE TABLE drawing_revisions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  drawing_id UUID NOT NULL REFERENCES drawings(id) ON DELETE CASCADE,
  
  -- Revision Info
  revision VARCHAR(10) NOT NULL,
  version INT NOT NULL DEFAULT 1, -- Multiple versions of same revision (A.1, A.2)
  
  -- File Information
  file_path VARCHAR(500) NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_size_mb DECIMAL(10,2),
  
  -- Change Description
  revision_description TEXT NOT NULL,
  change_reason VARCHAR(50), -- DESIGN_CHANGE, ERROR_CORRECTION, CLIENT_REQUEST, REGULATORY
  
  -- Audit Fields
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  UNIQUE(drawing_id, revision, version)
);

-- Indexes
CREATE INDEX idx_drawing_revisions_tenant ON drawing_revisions(tenant_id);
CREATE INDEX idx_drawing_revisions_drawing ON drawing_revisions(drawing_id);
CREATE INDEX idx_drawing_revisions_created_at ON drawing_revisions(created_at DESC);

-- Row Level Security
ALTER TABLE drawing_revisions ENABLE ROW LEVEL SECURITY;

CREATE POLICY drawing_revisions_tenant_isolation ON drawing_revisions
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- =====================================================

-- 3. DRAWING_COMMENTS (Collaboration)
CREATE TABLE drawing_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  drawing_id UUID NOT NULL REFERENCES drawings(id) ON DELETE CASCADE,
  
  -- Comment Content
  comment_text TEXT NOT NULL,
  comment_type VARCHAR(20) DEFAULT 'GENERAL', -- GENERAL, REVIEW, APPROVAL, REJECTION
  
  -- Optional: Location on drawing (for markup - Phase 2)
  page_number INT,
  x_coordinate DECIMAL(10,2),
  y_coordinate DECIMAL(10,2),
  
  -- Audit Fields
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_drawing_comments_tenant ON drawing_comments(tenant_id);
CREATE INDEX idx_drawing_comments_drawing ON drawing_comments(drawing_id);
CREATE INDEX idx_drawing_comments_created_at ON drawing_comments(created_at DESC);

-- Row Level Security
ALTER TABLE drawing_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY drawing_comments_tenant_isolation ON drawing_comments
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- =====================================================

-- 4. DRAWING_ATTACHMENTS (Supporting Documents)
CREATE TABLE drawing_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  drawing_id UUID NOT NULL REFERENCES drawings(id) ON DELETE CASCADE,
  
  -- Attachment Info
  attachment_name VARCHAR(255) NOT NULL,
  attachment_type VARCHAR(50), -- CALCULATION, DATASHEET, SPECIFICATION, REFERENCE
  file_path VARCHAR(500) NOT NULL,
  file_size_mb DECIMAL(10,2),
  
  -- Audit Fields
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_drawing_attachments_tenant ON drawing_attachments(tenant_id);
CREATE INDEX idx_drawing_attachments_drawing ON drawing_attachments(drawing_id);

-- Row Level Security
ALTER TABLE drawing_attachments ENABLE ROW LEVEL SECURITY;

CREATE POLICY drawing_attachments_tenant_isolation ON drawing_attachments
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- =====================================================

-- 5. DRAWING_LINKS (Drawing Dependencies)
CREATE TABLE drawing_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  
  -- Link Relationship
  source_drawing_id UUID NOT NULL REFERENCES drawings(id) ON DELETE CASCADE,
  target_drawing_id UUID NOT NULL REFERENCES drawings(id) ON DELETE CASCADE,
  link_type VARCHAR(50) NOT NULL, -- REFERENCES, SUPERSEDES, RELATED_TO, ASSEMBLY_OF
  
  -- Audit Fields
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  UNIQUE(source_drawing_id, target_drawing_id, link_type),
  CHECK (source_drawing_id != target_drawing_id)
);

-- Indexes
CREATE INDEX idx_drawing_links_tenant ON drawing_links(tenant_id);
CREATE INDEX idx_drawing_links_source ON drawing_links(source_drawing_id);
CREATE INDEX idx_drawing_links_target ON drawing_links(target_drawing_id);

-- Row Level Security
ALTER TABLE drawing_links ENABLE ROW LEVEL SECURITY;

CREATE POLICY drawing_links_tenant_isolation ON drawing_links
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- =====================================================

-- 6. DRAWING_ACCESS_LOG (Audit Trail for Downloads/Views)
CREATE TABLE drawing_access_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  drawing_id UUID NOT NULL REFERENCES drawings(id) ON DELETE CASCADE,
  
  -- Access Info
  access_type VARCHAR(20) NOT NULL, -- VIEW, DOWNLOAD, PRINT
  user_id UUID NOT NULL REFERENCES users(id),
  ip_address VARCHAR(45),
  user_agent TEXT,
  
  -- Timestamp
  accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes (partitioned by month for performance)
CREATE INDEX idx_drawing_access_log_tenant ON drawing_access_log(tenant_id);
CREATE INDEX idx_drawing_access_log_drawing ON drawing_access_log(drawing_id);
CREATE INDEX idx_drawing_access_log_user ON drawing_access_log(user_id);
CREATE INDEX idx_drawing_access_log_accessed_at ON drawing_access_log(accessed_at DESC);

-- Row Level Security
ALTER TABLE drawing_access_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY drawing_access_log_tenant_isolation ON drawing_access_log
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- =====================================================
-- SUMMARY
-- =====================================================
-- New Tables Created: 6
-- 1. drawings - Core drawing entity
-- 2. drawing_revisions - Version history
-- 3. drawing_comments - Collaboration
-- 4. drawing_attachments - Supporting documents
-- 5. drawing_links - Drawing dependencies
-- 6. drawing_access_log - Audit trail for access
-- =====================================================
