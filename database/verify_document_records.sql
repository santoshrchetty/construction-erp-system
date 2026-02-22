-- Verify document_records table exists and has data
SELECT 
  'TABLE_EXISTS' as check_type,
  COUNT(*) as record_count
FROM document_records 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';

-- Show sample records
SELECT 
  id,
  document_number,
  title,
  document_type,
  status,
  version,
  revision,
  created_at
FROM document_records 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY created_at DESC
LIMIT 5;

-- Insert additional test records if needed
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
  'SPEC-000001',
  'Concrete Specifications',
  'Technical specifications for concrete work',
  'SPECIFICATION',
  'APPROVED',
  '2.1',
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
),
(
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'RFI-000001',
  'Foundation Depth Clarification',
  'Request for information regarding foundation depth requirements',
  'RFI',
  'UNDER_REVIEW',
  '1.0',
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
)
ON CONFLICT (tenant_id, document_number) DO NOTHING;

-- Final verification
SELECT 
  document_type,
  status,
  COUNT(*) as count
FROM document_records 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
GROUP BY document_type, status
ORDER BY document_type, status;