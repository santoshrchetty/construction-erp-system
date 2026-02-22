-- Create document_records table for Document Governance
-- This table stores all document records with proper tenant isolation

CREATE TABLE IF NOT EXISTS document_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  document_number VARCHAR(100) NOT NULL,
  title VARCHAR(500) NOT NULL,
  description TEXT,
  document_type VARCHAR(50) NOT NULL CHECK (document_type IN ('DRAWING', 'SPECIFICATION', 'CONTRACT', 'RFI', 'SUBMITTAL', 'CHANGE_ORDER', 'OTHER')),
  status VARCHAR(50) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'UNDER_REVIEW', 'APPROVED', 'REJECTED', 'SUPERSEDED')),
  version VARCHAR(20) NOT NULL DEFAULT '1.0',
  revision VARCHAR(10),
  project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  UNIQUE(tenant_id, document_number)
);

-- Create indexes separately
CREATE INDEX IF NOT EXISTS idx_document_records_tenant_id ON document_records (tenant_id);
CREATE INDEX IF NOT EXISTS idx_document_records_document_number ON document_records (tenant_id, document_number);
CREATE INDEX IF NOT EXISTS idx_document_records_title ON document_records (tenant_id, title);
CREATE INDEX IF NOT EXISTS idx_document_records_type ON document_records (tenant_id, document_type);
CREATE INDEX IF NOT EXISTS idx_document_records_status ON document_records (tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_document_records_project ON document_records (tenant_id, project_id);
CREATE INDEX IF NOT EXISTS idx_document_records_created_by ON document_records (tenant_id, created_by);
CREATE INDEX IF NOT EXISTS idx_document_records_created_at ON document_records (tenant_id, created_at);

-- Enable Row Level Security
ALTER TABLE document_records ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can only access documents from their tenant" ON document_records
  FOR ALL USING (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

-- Create function to generate document numbers
CREATE OR REPLACE FUNCTION get_next_document_number(p_document_type TEXT, p_tenant_id UUID)
RETURNS TEXT AS $$
DECLARE
  next_number INTEGER;
  formatted_number TEXT;
BEGIN
  -- Get the next sequence number for this document type and tenant
  SELECT COALESCE(MAX(CAST(SUBSTRING(document_number FROM '[0-9]+$') AS INTEGER)), 0) + 1
  INTO next_number
  FROM document_records
  WHERE tenant_id = p_tenant_id
  AND document_type = p_document_type
  AND document_number ~ (p_document_type || '-[0-9]+$');
  
  -- Format the number with leading zeros
  formatted_number := p_document_type || '-' || LPAD(next_number::TEXT, 6, '0');
  
  RETURN formatted_number;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_document_records_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_document_records_updated_at
  BEFORE UPDATE ON document_records
  FOR EACH ROW
  EXECUTE FUNCTION update_document_records_updated_at();

-- Insert sample data for testing (optional)
INSERT INTO document_records (
  tenant_id, 
  document_number, 
  title, 
  description, 
  document_type, 
  status, 
  version, 
  created_by
) VALUES (
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRAWING-000001',
  'Site Plan Drawing',
  'Main site plan showing building layout and utilities',
  'DRAWING',
  'APPROVED',
  '1.0',
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
) ON CONFLICT (tenant_id, document_number) DO NOTHING;

-- Verify the table was created
SELECT 
  'DOCUMENT RECORDS TABLE' as check_type,
  COUNT(*) as record_count
FROM document_records 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';