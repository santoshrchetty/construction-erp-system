-- Add linked object fields to document_records table
ALTER TABLE document_records ADD COLUMN IF NOT EXISTS project_code VARCHAR(100);
ALTER TABLE document_records ADD COLUMN IF NOT EXISTS project_name VARCHAR(200);
ALTER TABLE document_records ADD COLUMN IF NOT EXISTS wbs_element VARCHAR(100);
ALTER TABLE document_records ADD COLUMN IF NOT EXISTS contract_number VARCHAR(100);
ALTER TABLE document_records ADD COLUMN IF NOT EXISTS material_number VARCHAR(100);
ALTER TABLE document_records ADD COLUMN IF NOT EXISTS material_description VARCHAR(500);
ALTER TABLE document_records ADD COLUMN IF NOT EXISTS part_number VARCHAR(100);
ALTER TABLE document_records ADD COLUMN IF NOT EXISTS vendor_name VARCHAR(200);
ALTER TABLE document_records ADD COLUMN IF NOT EXISTS equipment_number VARCHAR(100);
ALTER TABLE document_records ADD COLUMN IF NOT EXISTS cost_center VARCHAR(50);

-- Update existing records with sample linked objects
UPDATE document_records SET 
  project_code = 'PROJ-001',
  project_name = 'Construction Project Alpha',
  wbs_element = 'WBS-001.001',
  material_number = 'MAT-12345',
  material_description = 'Concrete Grade 30',
  part_number = 'PART-A001',
  vendor_name = 'ABC Construction Supply',
  contract_number = 'CNT-2024-001',
  cost_center = 'CC-100'
WHERE document_number = 'DRW-24-0001';

UPDATE document_records SET 
  project_code = 'PROJ-001',
  project_name = 'Construction Project Alpha',
  wbs_element = 'WBS-001.002',
  material_number = 'MAT-12346',
  material_description = 'Steel Reinforcement Bars',
  vendor_name = 'Steel Works Ltd',
  contract_number = 'CNT-2024-002',
  cost_center = 'CC-200'
WHERE document_number = 'SPE-24-0001';

UPDATE document_records SET 
  project_code = 'PROJ-002',
  project_name = 'Infrastructure Development',
  wbs_element = 'WBS-002.001',
  contract_number = 'CNT-2024-003',
  cost_center = 'CC-300'
WHERE document_number = 'RFI-24-0001';

-- Verify the updates
SELECT 
  document_number,
  title,
  document_type,
  status,
  version,
  project_code,
  wbs_element,
  material_number,
  part_number,
  vendor_name
FROM document_records 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY created_at DESC;