-- Submit MR-01-2026-000003 for approval

-- 1. Update status to SUBMITTED
UPDATE material_requests
SET status = 'SUBMITTED'
WHERE request_number = 'MR-01-2026-000003';

-- 2. Get MR details for workflow
SELECT 
  id,
  request_number,
  request_type,
  status,
  created_by,
  company_code,
  plant_code,
  project_code,
  total_amount
FROM material_requests
WHERE request_number = 'MR-01-2026-000003';

-- Note: After running this, call the API to create workflow instance:
-- POST /api/material-requests/approvals
-- {
--   "action": "submit_for_approval",
--   "payload": {
--     "request_id": "<ID from above query>",
--     "requester_id": "<created_by from above query>"
--   }
-- }
