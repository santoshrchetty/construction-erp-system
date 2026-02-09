-- Update Material Requests with required_date and purpose

UPDATE material_requests
SET 
  purpose = 'Construction materials for project execution',
  justification = 'Required for ongoing construction activities as per project schedule'
WHERE request_number IN ('MR-01-2026-994477', 'MR-01-2026-000002');

-- Verify
SELECT 
  request_number,
  status,
  priority,
  purpose,
  justification,
  project_code,
  wbs_element,
  created_at
FROM material_requests
WHERE request_number IN ('MR-01-2026-994477', 'MR-01-2026-000002');
