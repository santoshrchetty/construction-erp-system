-- Fix parent document search by ensuring correct document types and subtypes

-- Update existing documents to use correct 3-letter subtypes
UPDATE documents 
SET document_subtype = 'GA'
WHERE document_number = 'DRW-26-0200' AND document_subtype = 'GEN';

UPDATE documents 
SET document_subtype = 'FLR'
WHERE document_number = 'DRW-26-0201' AND document_subtype = 'FLR';

UPDATE documents 
SET document_subtype = 'MAT'
WHERE document_number = 'SPE-26-0100' AND document_subtype = 'MAT';

UPDATE documents 
SET document_subtype = 'CON'
WHERE document_number = 'SPE-26-0101' AND document_subtype = 'CON';

UPDATE documents 
SET document_subtype = 'MAN'
WHERE document_number = 'CNT-26-0001' AND document_subtype = 'MAI';

UPDATE documents 
SET document_subtype = 'CLA'
WHERE document_number = 'RFI-26-0001' AND document_subtype = 'CLA';

-- Add a few more test documents to ensure parent search works
INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW-26-0300',
  'DRW',
  'Structural Plans Master',
  'Master structural drawing set',
  'GA',
  'A',
  1,
  'STRUCTURAL',
  'PROJ001',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'DRW-26-0300')
LIMIT 1;

INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'SPE-26-0200',
  'SPE',
  'Equipment Specifications',
  'Equipment specification document',
  'EQP',
  'A',
  1,
  'MECHANICAL',
  'PROJ001',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'SPE-26-0200')
LIMIT 1;

-- Create lifecycle entries for new documents
INSERT INTO document_lifecycle (document_id, version, status, created_by, is_current)
SELECT d.id, '0.1', 'DRAFT', d.created_by, true
FROM documents d
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND d.document_number IN ('DRW-26-0300', 'SPE-26-0200')
AND NOT EXISTS (SELECT 1 FROM document_lifecycle WHERE document_id = d.id);

-- Verify the documents are available for parent selection
SELECT 
  document_number,
  document_type,
  title,
  document_subtype,
  document_level,
  CASE WHEN parent_document_id IS NULL THEN 'ROOT' ELSE 'CHILD' END as hierarchy_level
FROM documents 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY document_type, document_number;