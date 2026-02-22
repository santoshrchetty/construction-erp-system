-- 🏗️ ENGINEERING-GRADE DOCUMENT MANAGEMENT SYSTEM
-- Graph-based relationships, stable identity, controlled lifecycle

-- 1️⃣ DOCUMENT IDENTITY MODEL
CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  
  -- Stable Identity (IMMUTABLE)
  document_number VARCHAR(50) NOT NULL UNIQUE,
  document_type VARCHAR(3) NOT NULL CHECK (document_type IN ('DRW', 'SPE', 'CNT', 'RFI', 'SUB', 'CHG', 'DOC')),
  
  -- Core Metadata
  title VARCHAR(500) NOT NULL,
  description TEXT,
  discipline VARCHAR(100) NOT NULL,
  project_code VARCHAR(100) NOT NULL,
  
  -- Audit
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT documents_tenant_number_unique UNIQUE (tenant_id, document_number)
);

-- 2️⃣ LIFECYCLE MODEL
CREATE TABLE document_lifecycle (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  
  -- Version Control
  version VARCHAR(20) NOT NULL DEFAULT '0.1',
  revision VARCHAR(10),
  status VARCHAR(20) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'IFR', 'IFA', 'IFC', 'AS_BUILT', 'VOID')),
  
  -- Lifecycle Dates
  effective_date DATE,
  supersedes_document_id UUID REFERENCES documents(id),
  
  -- Audit
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Current version tracking
  is_current BOOLEAN DEFAULT true
);

-- 3️⃣ DOCUMENT RELATIONSHIPS (GRAPH MODEL)
CREATE TABLE document_relationships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  related_document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  
  relationship_type VARCHAR(20) NOT NULL CHECK (relationship_type IN ('PARENT_OF', 'REFERENCES', 'DERIVED_FROM', 'SUPERSEDES', 'RELATED_TO')),
  is_primary BOOLEAN DEFAULT false,
  
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Prevent self-reference
  CONSTRAINT no_self_reference CHECK (document_id != related_document_id)
);

-- 4️⃣ WBS OWNERSHIP INTEGRATION
CREATE TABLE document_wbs_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  wbs_id UUID NOT NULL, -- References WBS system
  
  is_financial_owner BOOLEAN DEFAULT false,
  
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5️⃣ OBJECT LINKING (SCALABLE MODEL)
CREATE TABLE document_object_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  
  object_type VARCHAR(20) NOT NULL CHECK (object_type IN ('MATERIAL', 'EQUIPMENT', 'VENDOR', 'CONTRACT', 'COST_CENTER')),
  object_id VARCHAR(100) NOT NULL,
  
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6️⃣ COST IMPACT GOVERNANCE
CREATE TABLE document_cost_impacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES documents(id),
  lifecycle_id UUID NOT NULL REFERENCES document_lifecycle(id),
  
  wbs_id UUID NOT NULL,
  impact_type VARCHAR(20) NOT NULL CHECK (impact_type IN ('REVISION_ISSUED', 'STATUS_CHANGE')),
  
  requires_approval BOOLEAN DEFAULT true,
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 📊 INDEXES FOR PERFORMANCE
CREATE INDEX idx_documents_tenant ON documents(tenant_id);
CREATE INDEX idx_documents_number ON documents(document_number);
CREATE INDEX idx_documents_type ON documents(document_type);
CREATE INDEX idx_documents_project ON documents(project_code);

CREATE INDEX idx_lifecycle_document ON document_lifecycle(document_id);
CREATE INDEX idx_lifecycle_current ON document_lifecycle(document_id, is_current);
CREATE INDEX idx_lifecycle_status ON document_lifecycle(status);

CREATE INDEX idx_relationships_document ON document_relationships(document_id);
CREATE INDEX idx_relationships_related ON document_relationships(related_document_id);
CREATE INDEX idx_relationships_type ON document_relationships(relationship_type);

CREATE INDEX idx_wbs_links_document ON document_wbs_links(document_id);
CREATE INDEX idx_wbs_links_financial ON document_wbs_links(document_id, is_financial_owner);

CREATE INDEX idx_object_links_document ON document_object_links(document_id);
CREATE INDEX idx_object_links_type ON document_object_links(object_type, object_id);

-- 🔒 CONSTRAINTS & VALIDATION

-- Only one financial owner per document
CREATE UNIQUE INDEX idx_single_financial_owner ON document_wbs_links(document_id) 
WHERE is_financial_owner = true;

-- Only one current lifecycle per document
CREATE UNIQUE INDEX idx_single_current_lifecycle ON document_lifecycle(document_id) 
WHERE is_current = true;

-- Prevent circular PARENT_OF relationships
CREATE OR REPLACE FUNCTION prevent_circular_parent() RETURNS TRIGGER AS $$
BEGIN
  -- Check if adding this relationship would create a cycle
  IF NEW.relationship_type = 'PARENT_OF' THEN
    IF EXISTS (
      WITH RECURSIVE hierarchy AS (
        SELECT related_document_id as doc_id FROM document_relationships 
        WHERE document_id = NEW.related_document_id AND relationship_type = 'PARENT_OF'
        UNION
        SELECT dr.related_document_id FROM document_relationships dr
        JOIN hierarchy h ON dr.document_id = h.doc_id
        WHERE dr.relationship_type = 'PARENT_OF'
      )
      SELECT 1 FROM hierarchy WHERE doc_id = NEW.document_id
    ) THEN
      RAISE EXCEPTION 'Circular parent relationship detected';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_prevent_circular_parent
  BEFORE INSERT OR UPDATE ON document_relationships
  FOR EACH ROW EXECUTE FUNCTION prevent_circular_parent();

-- 🔢 DOCUMENT NUMBERING FUNCTION (STABLE, NON-HIERARCHICAL)
CREATE OR REPLACE FUNCTION generate_stable_document_number(
  p_tenant_id UUID,
  p_document_type VARCHAR
) RETURNS VARCHAR AS $$
DECLARE
  v_year INTEGER;
  v_sequence INTEGER;
  v_document_number VARCHAR(50);
BEGIN
  v_year := EXTRACT(YEAR FROM CURRENT_DATE) % 100;
  
  -- Get next sequence for this type and year
  INSERT INTO document_sequences (tenant_id, document_type, year, last_sequence)
  VALUES (p_tenant_id, p_document_type, v_year, 1)
  ON CONFLICT (tenant_id, document_type, year)
  DO UPDATE SET 
    last_sequence = document_sequences.last_sequence + 1,
    updated_at = NOW()
  RETURNING last_sequence INTO v_sequence;
  
  -- Format: DRW-26-0001 (NO HIERARCHY ENCODING)
  v_document_number := p_document_type || '-' || LPAD(v_year::TEXT, 2, '0') || '-' || LPAD(v_sequence::TEXT, 4, '0');
  
  RETURN v_document_number;
END;
$$ LANGUAGE plpgsql;