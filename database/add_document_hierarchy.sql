-- Add parent_document_id field for document hierarchy
ALTER TABLE document_records ADD COLUMN IF NOT EXISTS parent_document_id UUID REFERENCES document_records(id) ON DELETE SET NULL;
ALTER TABLE document_records ADD COLUMN IF NOT EXISTS document_level INTEGER DEFAULT 1;

-- Create index for hierarchy queries
CREATE INDEX IF NOT EXISTS idx_document_records_parent ON document_records (parent_document_id);
CREATE INDEX IF NOT EXISTS idx_document_records_level ON document_records (document_level);

-- Function to generate hierarchical part numbers
CREATE OR REPLACE FUNCTION generate_part_number(
  p_parent_document_id UUID,
  p_tenant_id UUID
) RETURNS VARCHAR AS $$
DECLARE
  v_parent_part_number VARCHAR(100);
  v_next_sequence INTEGER;
  v_new_part_number VARCHAR(100);
BEGIN
  -- If no parent, this is a root document
  IF p_parent_document_id IS NULL THEN
    -- Get next root sequence
    SELECT COALESCE(MAX(CAST(SUBSTRING(part_number FROM '^([0-9]+)') AS INTEGER)), 0) + 1
    INTO v_next_sequence
    FROM document_records
    WHERE tenant_id = p_tenant_id
    AND parent_document_id IS NULL
    AND part_number ~ '^[0-9]+$';
    
    -- Format: 001, 002, 003, etc.
    v_new_part_number := LPAD(v_next_sequence::TEXT, 3, '0');
  ELSE
    -- Get parent part number
    SELECT part_number INTO v_parent_part_number
    FROM document_records
    WHERE id = p_parent_document_id;
    
    -- Get next child sequence for this parent
    SELECT COALESCE(MAX(CAST(SUBSTRING(part_number FROM '[0-9]+$') AS INTEGER)), 0) + 1
    INTO v_next_sequence
    FROM document_records
    WHERE parent_document_id = p_parent_document_id
    AND tenant_id = p_tenant_id;
    
    -- Format: parent.child (e.g., 001.001, 001.002, 001.001.001)
    v_new_part_number := v_parent_part_number || '.' || LPAD(v_next_sequence::TEXT, 3, '0');
  END IF;
  
  RETURN v_new_part_number;
END;
$$ LANGUAGE plpgsql;

-- Update document_level based on hierarchy depth
CREATE OR REPLACE FUNCTION update_document_level()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.parent_document_id IS NULL THEN
    NEW.document_level := 1;
  ELSE
    SELECT document_level + 1 INTO NEW.document_level
    FROM document_records
    WHERE id = NEW.parent_document_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update document level
CREATE TRIGGER trigger_update_document_level
  BEFORE INSERT OR UPDATE ON document_records
  FOR EACH ROW
  EXECUTE FUNCTION update_document_level();

-- Sample hierarchical data
-- Root drawing
INSERT INTO document_records (
  tenant_id, 
  document_number, 
  title, 
  document_type, 
  status, 
  version,
  part_number,
  parent_document_id,
  created_by
) VALUES 
(
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW-26-0002',
  'Main Assembly Drawing',
  'DRW',
  'APPROVED',
  '1.0',
  '001',
  NULL,
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
) ON CONFLICT (tenant_id, document_number) DO NOTHING;

-- Child drawings
INSERT INTO document_records (
  tenant_id, 
  document_number, 
  title, 
  document_type, 
  status, 
  version,
  part_number,
  parent_document_id,
  created_by
) VALUES 
(
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW-26-0003',
  'Foundation Detail',
  'DRW',
  'DRAFT',
  '1.0',
  '001.001',
  (SELECT id FROM document_records WHERE document_number = 'DRW-26-0002' AND tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'),
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
),
(
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW-26-0004',
  'Structural Frame Detail',
  'DRW',
  'DRAFT',
  '1.0',
  '001.002',
  (SELECT id FROM document_records WHERE document_number = 'DRW-26-0002' AND tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'),
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
) ON CONFLICT (tenant_id, document_number) DO NOTHING;

-- Verify hierarchy
SELECT 
  document_number,
  title,
  part_number,
  document_level,
  CASE WHEN parent_document_id IS NULL THEN 'ROOT' ELSE 'CHILD' END as hierarchy_type
FROM document_records 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND document_type = 'DRW'
ORDER BY part_number;