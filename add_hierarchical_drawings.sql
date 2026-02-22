-- Add hierarchical drawing test data
-- Level 1: Master Drawing (Root)
INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW-26-0100',
  'DRW',
  'Site Plan Master',
  'Overall site layout and master plan',
  'GEN',
  'A',
  1,
  'CIVIL',
  'PROJ001',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'DRW-26-0100')
LIMIT 1;

-- Level 2: Child Drawings
INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, parent_document_id, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW-26-0101',
  'DRW',
  'Foundation Layout',
  'Foundation plan and details',
  'DET',
  'A',
  2,
  p.id,
  'CIVIL',
  'PROJ001',
  u.id
FROM users u, documents p
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND p.document_number = 'DRW-26-0100'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'DRW-26-0101')
LIMIT 1;

INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, parent_document_id, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW-26-0102',
  'DRW',
  'Structural Layout',
  'Structural framing plan',
  'DET',
  'B',
  2,
  p.id,
  'CIVIL',
  'PROJ001',
  u.id
FROM users u, documents p
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND p.document_number = 'DRW-26-0100'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'DRW-26-0102')
LIMIT 1;

-- Level 3: Sub-detail Drawings
INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, parent_document_id, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW-26-0111',
  'DRW',
  'Foundation Section A-A',
  'Cross section detail of foundation',
  'SEC',
  'A',
  3,
  p.id,
  'CIVIL',
  'PROJ001',
  u.id
FROM users u, documents p
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND p.document_number = 'DRW-26-0101'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'DRW-26-0111')
LIMIT 1;

INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, parent_document_id, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW-26-0112',
  'DRW',
  'Foundation Reinforcement Detail',
  'Rebar placement and specifications',
  'DET',
  'B',
  3,
  p.id,
  'CIVIL',
  'PROJ001',
  u.id
FROM users u, documents p
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND p.document_number = 'DRW-26-0101'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'DRW-26-0112')
LIMIT 1;

INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, parent_document_id, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW-26-0121',
  'DRW',
  'Beam Connection Detail',
  'Steel beam to column connection',
  'DET',
  'A',
  3,
  p.id,
  'CIVIL',
  'PROJ001',
  u.id
FROM users u, documents p
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND p.document_number = 'DRW-26-0102'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'DRW-26-0121')
LIMIT 1;

-- Create document relationships
INSERT INTO document_relationships (document_id, related_document_id, relationship_type, is_primary, created_by)
SELECT p.id, c.id, 'PARENT_OF', true, u.id
FROM users u, documents p, documents c
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND p.document_number = 'DRW-26-0100' 
AND c.document_number IN ('DRW-26-0101', 'DRW-26-0102')
AND NOT EXISTS (SELECT 1 FROM document_relationships WHERE document_id = p.id AND related_document_id = c.id);

INSERT INTO document_relationships (document_id, related_document_id, relationship_type, is_primary, created_by)
SELECT p.id, c.id, 'PARENT_OF', true, u.id
FROM users u, documents p, documents c
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND p.document_number = 'DRW-26-0101' 
AND c.document_number IN ('DRW-26-0111', 'DRW-26-0112')
AND NOT EXISTS (SELECT 1 FROM document_relationships WHERE document_id = p.id AND related_document_id = c.id);

INSERT INTO document_relationships (document_id, related_document_id, relationship_type, is_primary, created_by)
SELECT p.id, c.id, 'PARENT_OF', true, u.id
FROM users u, documents p, documents c
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND p.document_number = 'DRW-26-0102' 
AND c.document_number = 'DRW-26-0121'
AND NOT EXISTS (SELECT 1 FROM document_relationships WHERE document_id = p.id AND related_document_id = c.id);

-- Create lifecycle entries for all new documents
INSERT INTO document_lifecycle (document_id, version, status, created_by, is_current)
SELECT d.id, '0.1', 'DRAFT', d.created_by, true
FROM documents d
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND d.document_number IN ('DRW-26-0100', 'DRW-26-0101', 'DRW-26-0102', 'DRW-26-0111', 'DRW-26-0112', 'DRW-26-0121')
AND NOT EXISTS (SELECT 1 FROM document_lifecycle WHERE document_id = d.id);

-- Verify hierarchical structure
SELECT 
  d.document_number,
  d.title,
  d.document_level,
  p.document_number as parent_number,
  p.title as parent_title
FROM documents d
LEFT JOIN documents p ON d.parent_document_id = p.id
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND d.document_number LIKE 'DRW-26-01%'
ORDER BY d.document_level, d.document_number;