-- Create sample material requests
INSERT INTO material_requests (
  request_number,
  mr_type,
  status,
  project_code,
  wbs_element,
  company_code,
  plant_code,
  department,
  requested_by,
  request_date,
  required_date,
  priority,
  description,
  tenant_id,
  created_by
)
VALUES 
  (
    'MR-2024-001',
    'STANDARD',
    'SUBMITTED',
    'PROJ-001',
    'WBS-001',
    '1000',
    'P001',
    'CONSTRUCTION',
    'John Doe',
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '7 days',
    'MEDIUM',
    'Materials for foundation work',
    '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
    (SELECT id FROM users WHERE email = 'admin@prom.com' LIMIT 1)
  ),
  (
    'MR-2024-002',
    'EMERGENCY',
    'APPROVED',
    'PROJ-002',
    'WBS-002',
    '1000',
    'P001',
    'MAINTENANCE',
    'Jane Smith',
    CURRENT_DATE - INTERVAL '2 days',
    CURRENT_DATE + INTERVAL '1 day',
    'HIGH',
    'Emergency repair materials',
    '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
    (SELECT id FROM users WHERE email = 'admin@prom.com' LIMIT 1)
  ),
  (
    'MR-2024-003',
    'STANDARD',
    'DRAFT',
    'PROJ-001',
    'WBS-003',
    '1000',
    'P002',
    'CONSTRUCTION',
    'Bob Johnson',
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '14 days',
    'LOW',
    'Materials for electrical work',
    '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
    (SELECT id FROM users WHERE email = 'admin@prom.com' LIMIT 1)
  );

-- Verify
SELECT 
  request_number,
  mr_type,
  status,
  project_code,
  created_at
FROM material_requests
ORDER BY created_at DESC;
