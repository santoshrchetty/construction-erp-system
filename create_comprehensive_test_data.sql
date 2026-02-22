-- Comprehensive test data for document structure testing

-- 1. Create projects for object linking
INSERT INTO projects (tenant_id, project_code, project_name, description, created_by)
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'PROJ001',
  'Office Building Construction',
  'Main office building project',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM projects WHERE project_code = 'PROJ001')
LIMIT 1;

INSERT INTO projects (tenant_id, project_code, project_name, description, created_by)
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'PROJ002',
  'Warehouse Expansion',
  'Warehouse facility expansion',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM projects WHERE project_code = 'PROJ002')
LIMIT 1;

-- 2. Create WBS elements for object linking
INSERT INTO wbs_elements (tenant_id, wbs_code, wbs_description, project_code, created_by)
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'WBS001',
  'Foundation Work',
  'PROJ001',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM wbs_elements WHERE wbs_code = 'WBS001')
LIMIT 1;

INSERT INTO wbs_elements (tenant_id, wbs_code, wbs_description, project_code, created_by)
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'WBS002',
  'Structural Steel',
  'PROJ001',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM wbs_elements WHERE wbs_code = 'WBS002')
LIMIT 1;

-- 3. Create materials for object linking
INSERT INTO materials (tenant_id, material_code, material_name, category, created_by)
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'MAT001',
  'Concrete Grade 30',
  'Construction Materials',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM materials WHERE material_code = 'MAT001')
LIMIT 1;

INSERT INTO materials (tenant_id, material_code, material_name, category, created_by)
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'MAT002',
  'Steel Rebar 16mm',
  'Reinforcement',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM materials WHERE material_code = 'MAT002')
LIMIT 1;

-- 4. Create comprehensive document hierarchy for testing
-- Level 1: Master Documents
INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW-26-0200',
  'DRW',
  'Architectural Plans Master',
  'Master architectural drawing set',
  'GEN',
  'A',
  1,
  'ARCHITECTURAL',
  'PROJ001',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'DRW-26-0200')
LIMIT 1;

INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'SPE-26-0100',
  'SPE',
  'Material Specifications Master',
  'Master material specification document',
  'MAT',
  'A',
  1,
  'CIVIL',
  'PROJ001',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'SPE-26-0100')
LIMIT 1;

-- Level 2: Child Documents
INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, parent_document_id, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW-26-0201',
  'DRW',
  'Ground Floor Plan',
  'Detailed ground floor architectural plan',
  'FLR',
  'A',
  2,
  p.id,
  'ARCHITECTURAL',
  'PROJ001',
  u.id
FROM users u, documents p
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND p.document_number = 'DRW-26-0200'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'DRW-26-0201')
LIMIT 1;

INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, parent_document_id, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'SPE-26-0101',
  'SPE',
  'Concrete Specification',
  'Grade 30 concrete specification details',
  'CON',
  'A',
  2,
  p.id,
  'CIVIL',
  'PROJ001',
  u.id
FROM users u, documents p
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND p.document_number = 'SPE-26-0100'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'SPE-26-0101')
LIMIT 1;

-- Different document types for testing
INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'CNT-26-0001',
  'CNT',
  'Main Construction Contract',
  'Primary construction contract',
  'MAI',
  'A',
  1,
  'CIVIL',
  'PROJ001',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'CNT-26-0001')
LIMIT 1;

INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'RFI-26-0001',
  'RFI',
  'Foundation Detail Clarification',
  'Request for information on foundation reinforcement details',
  'CLA',
  'A',
  1,
  'CIVIL',
  'PROJ001',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'RFI-26-0001')
LIMIT 1;

-- 5. Create document relationships
INSERT INTO document_relationships (document_id, related_document_id, relationship_type, is_primary, created_by)
SELECT p.id, c.id, 'PARENT_OF', true, u.id
FROM users u, documents p, documents c
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND p.document_number = 'DRW-26-0200' 
AND c.document_number = 'DRW-26-0201'
AND NOT EXISTS (SELECT 1 FROM document_relationships WHERE document_id = p.id AND related_document_id = c.id);

INSERT INTO document_relationships (document_id, related_document_id, relationship_type, is_primary, created_by)
SELECT p.id, c.id, 'PARENT_OF', true, u.id
FROM users u, documents p, documents c
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND p.document_number = 'SPE-26-0100' 
AND c.document_number = 'SPE-26-0101'
AND NOT EXISTS (SELECT 1 FROM document_relationships WHERE document_id = p.id AND related_document_id = c.id);

-- 6. Create lifecycle entries with different statuses
INSERT INTO document_lifecycle (document_id, version, status, created_by, is_current)
SELECT d.id, '0.1', 'DRAFT', d.created_by, true
FROM documents d
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND d.document_number IN ('DRW-26-0200', 'DRW-26-0201', 'SPE-26-0100', 'SPE-26-0101', 'CNT-26-0001')
AND NOT EXISTS (SELECT 1 FROM document_lifecycle WHERE document_id = d.id);

-- Update some documents to different statuses for testing
UPDATE document_lifecycle 
SET status = 'IFR', version = '1.0'
WHERE document_id IN (
  SELECT id FROM documents WHERE document_number = 'DRW-26-0200'
);

UPDATE document_lifecycle 
SET status = 'IFA', version = '1.1'
WHERE document_id IN (
  SELECT id FROM documents WHERE document_number = 'SPE-26-0100'
);

-- 7. Create document-WBS links for testing object links
INSERT INTO document_wbs_links (document_id, wbs_code, created_by)
SELECT d.id, 'WBS001', d.created_by
FROM documents d
WHERE d.document_number = 'DRW-26-0201'
AND NOT EXISTS (SELECT 1 FROM document_wbs_links WHERE document_id = d.id AND wbs_code = 'WBS001');

INSERT INTO document_wbs_links (document_id, wbs_code, created_by)
SELECT d.id, 'WBS002', d.created_by
FROM documents d
WHERE d.document_number = 'SPE-26-0101'
AND NOT EXISTS (SELECT 1 FROM document_wbs_links WHERE document_id = d.id AND wbs_code = 'WBS002');

-- 8. Verify test data
SELECT 
  'PROJECTS' as data_type,
  COUNT(*) as count
FROM projects 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'

UNION ALL

SELECT 
  'WBS_ELEMENTS' as data_type,
  COUNT(*) as count
FROM wbs_elements 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'

UNION ALL

SELECT 
  'MATERIALS' as data_type,
  COUNT(*) as count
FROM materials 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'

UNION ALL

SELECT 
  'DOCUMENTS' as data_type,
  COUNT(*) as count
FROM documents 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'

UNION ALL

SELECT 
  'DOCUMENT_RELATIONSHIPS' as data_type,
  COUNT(*) as count
FROM document_relationships dr
JOIN documents d ON dr.document_id = d.id
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'

UNION ALL

SELECT 
  'DOCUMENT_LIFECYCLE' as data_type,
  COUNT(*) as count
FROM document_lifecycle dl
JOIN documents d ON dl.document_id = d.id
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'

ORDER BY data_type;