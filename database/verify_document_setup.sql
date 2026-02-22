-- Verify current document records
SELECT 
  document_number,
  document_type,
  title,
  status,
  version,
  project_code,
  part_number,
  created_at
FROM document_records 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY document_number;

-- Check document sequences table
SELECT * FROM document_sequences 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

-- Test document number generation
SELECT generate_document_number('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'DRW') as new_drawing_number;
SELECT generate_document_number('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'SPE') as new_spec_number;