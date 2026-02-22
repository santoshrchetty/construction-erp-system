-- Insert test documents with linked objects into unified documents table
INSERT INTO documents (
  tenant_id,
  document_number,
  document_type,
  title,
  description,
  status,
  revision,
  project_code,
  project_name,
  wbs_element,
  material_number,
  material_description,
  vendor_name,
  contract_number,
  cost_center,
  created_by
) VALUES 
(
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'DRW-24-0001',
  'Drawing',
  'Site Layout Plan',
  'Main site layout showing building positions and utilities',
  'Approved',
  'A',
  'PROJ-001',
  'Construction Project Alpha',
  'WBS-001.001',
  'MAT-12345',
  'Concrete Grade 30',
  'ABC Construction Supply',
  'CNT-2024-001',
  'CC-100',
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
),
(
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'SPE-24-0001',
  'Specification',
  'Concrete Specifications',
  'Technical specifications for concrete work including mix design',
  'Approved',
  'B',
  'PROJ-001',
  'Construction Project Alpha',
  'WBS-001.002',
  'MAT-12346',
  'Steel Reinforcement Bars',
  'Steel Works Ltd',
  'CNT-2024-002',
  'CC-200',
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
),
(
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'RFI-24-0001',
  'RFI',
  'Foundation Depth Clarification',
  'Request for information regarding foundation depth requirements in zone A',
  'Draft',
  'A',
  'PROJ-002',
  'Infrastructure Development',
  'WBS-002.001',
  NULL,
  NULL,
  NULL,
  'CNT-2024-003',
  'CC-300',
  (SELECT id FROM users WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' LIMIT 1)
)
ON CONFLICT (document_number, tenant_id) DO NOTHING;

-- Verify the data was inserted
SELECT 
  document_number,
  title,
  document_type,
  status,
  project_code,
  wbs_element,
  material_number,
  vendor_name
FROM documents 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY created_at DESC;