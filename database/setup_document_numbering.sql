-- Add document numbering system to document_records table
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

-- Function to generate document numbers with [TYPE]-[YEAR]-[SEQUENCE] pattern
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
    WHEN 'DRW' THEN 'DRW'
    WHEN 'SPE' THEN 'SPE'
    WHEN 'CNT' THEN 'CNT'
    WHEN 'RFI' THEN 'RFI'
    WHEN 'SUB' THEN 'SUB'
    WHEN 'CHG' THEN 'CHG'
    WHEN 'DOC' THEN 'DOC'
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

-- Update existing records to use new numbering pattern
UPDATE document_records SET document_number = 'DRW-24-0001' WHERE document_number = 'DRAWING-000001';
UPDATE document_records SET document_number = 'SPE-24-0001' WHERE document_number = 'SPEC-000001';  
UPDATE document_records SET document_number = 'RFI-24-0001' WHERE document_number = 'RFI-000001';

-- Insert test records with proper numbering
INSERT INTO document_records (
  tenant_id, 
  document_number, 
  title, 
  description, 
  document_type, 
  status, 
  version, 
  created_by
) VALUES 
(
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'CNT-24-0001',
  'Main Construction Contract',
  'Primary contract for construction work',
  'CNT',
  'APPROVED',
  '1.0',
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
),
(
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'SUB-24-0001',
  'Material Submittal Package',
  'Submittal for concrete materials approval',
  'SUB',
  'UNDER_REVIEW',
  '1.0',
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
)
ON CONFLICT (tenant_id, document_number) DO NOTHING;