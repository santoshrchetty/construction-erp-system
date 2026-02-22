-- Check recent material requests
SELECT 
  id,
  request_number,
  status,
  request_type,
  created_by,
  created_at
FROM material_requests
ORDER BY created_at DESC
LIMIT 5;
