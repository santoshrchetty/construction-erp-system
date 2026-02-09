-- Submit Draft Material Requests for Approval

-- Update MR status to SUBMITTED
UPDATE material_requests
SET status = 'SUBMITTED'
WHERE status = 'DRAFT'
AND request_type = 'MATERIAL_REQ';

-- Verify
SELECT 
  request_number,
  request_type,
  status,
  created_by,
  project_code
FROM material_requests
WHERE request_type = 'MATERIAL_REQ'
ORDER BY created_at DESC;
