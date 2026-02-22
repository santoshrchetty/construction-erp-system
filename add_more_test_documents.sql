-- Add more test documents for better testing
INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'CNT-26-0001',
  'CNT',
  'Main Construction Contract',
  'Primary construction agreement',
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
  'Foundation Clarification',
  'Request for information on foundation details',
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

INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'SUB-26-0001',
  'SUB',
  'Steel Submittal',
  'Structural steel shop drawings submittal',
  'SHO',
  'A',
  1,
  'CIVIL',
  'PROJ001',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'SUB-26-0001')
LIMIT 1;

INSERT INTO documents (
  tenant_id, document_number, document_type, title, description,
  document_subtype, part_number, document_level, discipline, project_code, created_by
) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'CHG-26-0001',
  'CHG',
  'Design Change Order',
  'Change order for foundation design modification',
  'DES',
  'A',
  1,
  'CIVIL',
  'PROJ001',
  u.id
FROM users u
WHERE u.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND NOT EXISTS (SELECT 1 FROM documents WHERE document_number = 'CHG-26-0001')
LIMIT 1;

-- Create lifecycle entries for new documents
INSERT INTO document_lifecycle (document_id, version, status, created_by, is_current)
SELECT d.id, '0.1', 'DRAFT', d.created_by, true
FROM documents d
WHERE d.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND d.document_number IN ('CNT-26-0001', 'RFI-26-0001', 'SUB-26-0001', 'CHG-26-0001')
AND NOT EXISTS (SELECT 1 FROM document_lifecycle WHERE document_id = d.id);

-- Verify all documents
SELECT COUNT(*) as total_documents FROM documents WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';