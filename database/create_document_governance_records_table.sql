-- Create document_governance_records table
CREATE TABLE IF NOT EXISTS document_governance_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  document_number VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  document_type VARCHAR(50) NOT NULL,
  document_subtype VARCHAR(50),
  version VARCHAR(20) DEFAULT '1.0',
  part_number VARCHAR(20),
  system_status VARCHAR(20) DEFAULT 'WIP',
  user_status VARCHAR(20),
  object_links JSONB DEFAULT '[]'::jsonb,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(tenant_id, document_number)
);

-- Create index
CREATE INDEX idx_doc_gov_records_tenant ON document_governance_records(tenant_id);
CREATE INDEX idx_doc_gov_records_type ON document_governance_records(document_type);
CREATE INDEX idx_doc_gov_records_status ON document_governance_records(system_status);

-- Enable RLS
ALTER TABLE document_governance_records ENABLE ROW LEVEL SECURITY;

-- Create RLS policy
CREATE POLICY tenant_isolation_policy ON document_governance_records
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
