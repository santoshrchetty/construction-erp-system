-- Create master documents table for unified document management
CREATE TABLE IF NOT EXISTS documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  
  -- Universal Document Fields
  document_number VARCHAR(50) NOT NULL,           -- DRW-24-0001, CNT-24-0001, etc.
  document_type VARCHAR(50) NOT NULL,             -- Drawing, Contract, RFI, Specification, Submittal, ChangeOrder, MasterDocument
  document_part VARCHAR(50) DEFAULT '000',        -- 000, 001, 001.001, 001.002 (hierarchy)
  title VARCHAR(500) NOT NULL,
  description TEXT,
  status VARCHAR(50) DEFAULT 'Draft',
  revision VARCHAR(20) DEFAULT 'A',
  
  -- Hierarchy (works across all document types)
  parent_document_id UUID REFERENCES documents(id) ON DELETE SET NULL,
  document_level INTEGER DEFAULT 1,
  
  -- Governance & Control
  confidentiality VARCHAR(50) DEFAULT 'Internal', -- Public, Internal, Confidential, Restricted
  issued_for VARCHAR(100),                        -- Construction, Approval, Information, Tender, Review
  lifecycle_stage VARCHAR(50) DEFAULT 'Draft',    -- Draft, Active, Superseded, Archived, Obsolete
  
  -- Approval & Lifecycle
  approved_by VARCHAR(200),
  approved_date TIMESTAMP,
  effective_date DATE,
  expiry_date DATE,
  next_review_date DATE,
  review_frequency VARCHAR(50),                   -- Annual, Quarterly, Monthly, None
  retention_period VARCHAR(50),                   -- 7 Years, 10 Years, Permanent
  
  -- Supersession & Versioning
  superseded_by_id UUID REFERENCES documents(id) ON DELETE SET NULL,
  supersedes_id UUID REFERENCES documents(id) ON DELETE SET NULL,
  version_history JSONB,                          -- Array of previous versions
  change_reason TEXT,                             -- Why this revision was created
  
  -- Distribution & Access
  distribution_list JSONB,                        -- Array of users/roles who should receive this
  access_level VARCHAR(50) DEFAULT 'Standard',    -- Public, Standard, Restricted, Confidential
  requires_acknowledgment BOOLEAN DEFAULT false,  -- Must users acknowledge receipt?
  
  -- Compliance & Regulatory
  compliance_category VARCHAR(100),               -- ISO 9001, ISO 19650, OSHA, etc.
  regulatory_reference VARCHAR(200),              -- Related regulation/standard
  risk_level VARCHAR(50),                         -- High, Medium, Low
  criticality VARCHAR(50),                        -- Critical, Important, Standard
  mandatory_review BOOLEAN DEFAULT false,         -- Must be reviewed periodically?
  
  -- File Management
  file_name VARCHAR(500),
  file_path TEXT,
  file_size BIGINT,                               -- In bytes
  file_format VARCHAR(50),                        -- PDF, DWG, DXF, DOCX, etc.
  file_hash VARCHAR(100),                         -- SHA-256 hash for integrity
  file_version INTEGER DEFAULT 1,
  
  -- Workflow & Status
  workflow_state VARCHAR(50),                     -- Current workflow step
  workflow_id UUID,                               -- Link to workflow definition
  current_approver_id UUID,                       -- Who needs to approve now
  approval_deadline DATE,                         -- When approval is due
  rejection_reason TEXT,                          -- Why document was rejected
  
  -- Transmittal & Communication
  transmittal_number VARCHAR(100),                -- Cover letter reference
  transmittal_date DATE,
  received_date DATE,
  response_due_date DATE,
  response_received_date DATE,
  
  -- Tags & Classification
  tags JSONB,                                     -- Array of tags for searching
  keywords TEXT,                                  -- Searchable keywords
  custom_fields JSONB,                            -- Tenant-specific custom fields,
  
  -- Origination
  originator VARCHAR(200),
  checked_by VARCHAR(200),
  
  -- Object Links (SAP-style integration)
  project_id UUID,
  project_code VARCHAR(100),
  project_name VARCHAR(200),
  wbs_element VARCHAR(100),
  activity_id VARCHAR(100),
  contract_id UUID,
  contract_number VARCHAR(100),
  material_id UUID,
  material_number VARCHAR(100),
  material_description VARCHAR(500),
  equipment_id UUID,
  equipment_number VARCHAR(100),
  vendor_id UUID,
  vendor_code VARCHAR(100),
  vendor_name VARCHAR(200),
  cost_center VARCHAR(50),
  gl_account VARCHAR(50),
  plant_code VARCHAR(50),
  storage_location VARCHAR(50),
  equipment_location VARCHAR(100),
  linked_objects JSONB,
  
  -- Metadata
  created_by UUID,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_by UUID,
  updated_at TIMESTAMP DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT documents_tenant_fk FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  CONSTRAINT documents_number_tenant_unique UNIQUE (document_number, tenant_id)
);

-- Create indexes
CREATE INDEX idx_documents_tenant ON documents(tenant_id);
CREATE INDEX idx_documents_type ON documents(document_type);
CREATE INDEX idx_documents_status ON documents(status);
CREATE INDEX idx_documents_lifecycle ON documents(lifecycle_stage);
CREATE INDEX idx_documents_parent ON documents(parent_document_id);
CREATE INDEX idx_documents_number ON documents(document_number);
CREATE INDEX idx_documents_created ON documents(created_at DESC);
CREATE INDEX idx_documents_effective ON documents(effective_date);
CREATE INDEX idx_documents_expiry ON documents(expiry_date);
CREATE INDEX idx_documents_review ON documents(next_review_date);
CREATE INDEX idx_documents_workflow ON documents(workflow_state);
CREATE INDEX idx_documents_superseded ON documents(superseded_by_id);
CREATE INDEX idx_documents_file_hash ON documents(file_hash);
CREATE INDEX idx_documents_project ON documents(project_id);
CREATE INDEX idx_documents_contract ON documents(contract_id);
CREATE INDEX idx_documents_material ON documents(material_id);
CREATE INDEX idx_documents_wbs ON documents(wbs_element);
CREATE INDEX idx_documents_vendor ON documents(vendor_id);

-- Add document_number to existing tables
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS document_id UUID REFERENCES documents(id) ON DELETE CASCADE;
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS document_id UUID REFERENCES documents(id) ON DELETE CASCADE;
ALTER TABLE rfis ADD COLUMN IF NOT EXISTS document_id UUID REFERENCES documents(id) ON DELETE CASCADE;
ALTER TABLE specifications ADD COLUMN IF NOT EXISTS document_id UUID REFERENCES documents(id) ON DELETE CASCADE;
ALTER TABLE submittals ADD COLUMN IF NOT EXISTS document_id UUID REFERENCES documents(id) ON DELETE CASCADE;
ALTER TABLE change_orders ADD COLUMN IF NOT EXISTS document_id UUID REFERENCES documents(id) ON DELETE CASCADE;
ALTER TABLE master_data_documents ADD COLUMN IF NOT EXISTS document_id UUID REFERENCES documents(id) ON DELETE CASCADE;

-- Create sequence table for auto-numbering
CREATE TABLE IF NOT EXISTS document_sequences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  document_type VARCHAR(50) NOT NULL,
  year INTEGER NOT NULL,
  last_sequence INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT doc_seq_tenant_fk FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
  CONSTRAINT doc_seq_unique UNIQUE (tenant_id, document_type, year)
);

-- Function to generate next document number
CREATE OR REPLACE FUNCTION generate_document_number(
  p_tenant_id UUID,
  p_document_type VARCHAR
) RETURNS VARCHAR AS $$
DECLARE
  v_year INTEGER;
  v_sequence INTEGER;
  v_type_code VARCHAR(3);
  v_document_number VARCHAR(50);
BEGIN
  -- Get current year (last 2 digits)
  v_year := EXTRACT(YEAR FROM CURRENT_DATE) % 100;
  
  -- Map document type to code
  v_type_code := CASE p_document_type
    WHEN 'Drawing' THEN 'DRW'
    WHEN 'Contract' THEN 'CNT'
    WHEN 'RFI' THEN 'RFI'
    WHEN 'Specification' THEN 'SPE'
    WHEN 'Submittal' THEN 'SUB'
    WHEN 'ChangeOrder' THEN 'CHG'
    WHEN 'MasterDocument' THEN 'MDD'
    ELSE 'DOC'
  END;
  
  -- Get or create sequence
  INSERT INTO document_sequences (tenant_id, document_type, year, last_sequence)
  VALUES (p_tenant_id, p_document_type, v_year, 1)
  ON CONFLICT (tenant_id, document_type, year)
  DO UPDATE SET 
    last_sequence = document_sequences.last_sequence + 1,
    updated_at = NOW()
  RETURNING last_sequence INTO v_sequence;
  
  -- Format: DRW-24-0001
  v_document_number := v_type_code || '-' || LPAD(v_year::TEXT, 2, '0') || '-' || LPAD(v_sequence::TEXT, 4, '0');
  
  RETURN v_document_number;
END;
$$ LANGUAGE plpgsql;

-- Example usage:
-- SELECT generate_document_number('tenant-uuid', 'Drawing');  -- Returns: DRW-24-0001
-- SELECT generate_document_number('tenant-uuid', 'Contract'); -- Returns: CNT-24-0001

COMMENT ON TABLE documents IS 'Master document register for all document types with unified numbering';
COMMENT ON COLUMN documents.document_number IS 'Auto-generated unique document number: DRW-24-0001, CNT-24-0001, etc.';
COMMENT ON COLUMN documents.document_type IS 'Type of document: Drawing, Contract, RFI, Specification, Submittal, ChangeOrder, MasterDocument';
COMMENT ON FUNCTION generate_document_number IS 'Generates next sequential document number for given tenant and document type';
