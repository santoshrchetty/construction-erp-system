-- Check if there are any documents in the database
SELECT COUNT(*) as document_count FROM documents WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

-- Get a valid user ID for created_by
SELECT id as user_id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1;

-- If no documents exist, create some test documents
INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW-26-0001',
  'DRW',
  'Foundation Plan',
  'Foundation layout and reinforcement details',
  'GEN',
  'A',
  1,
  'CIVIL',
  'PROJ001',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM documents WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15')
LIMIT 1;

INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'SPE-26-0001',
  'SPE',
  'Concrete Specification',
  'Grade 30 concrete specification',
  'MAT',
  'B',
  1,
  'CIVIL',
  'PROJ001',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'SPE-26-0001')
LIMIT 1;

-- Create lifecycle entries for test documents
INSERT INTO document_lifecycle (document_id, version, status, created_by, is_current)
SELECT d.id, '0.1', 'DRAFT', d.created_by, true
FROM documents d
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM document_lifecycle WHERE document_id = d.id);

-- Verify documents were created
SELECT 
  document_number, 
  document_type, 
  title, 
  document_subtype, 
  part_number, 
  document_level
FROM documents 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';