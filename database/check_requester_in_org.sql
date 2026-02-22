-- Check who created MR-01-2026-000009
SELECT id, requested_by, created_by
FROM material_requests
WHERE request_number = 'MR-01-2026-000009';

-- Check if that user exists in org_hierarchy
SELECT 
  oh.employee_id,
  oh.employee_name,
  oh.manager_id,
  oh.position_title,
  oh.department_code
FROM org_hierarchy oh
WHERE oh.employee_id::text IN (
  SELECT created_by::text FROM material_requests WHERE request_number = 'MR-01-2026-000009'
);

-- Check if their manager exists
SELECT 
  manager.employee_id,
  manager.employee_name,
  manager.position_title
FROM org_hierarchy manager
WHERE manager.employee_id::text IN (
  SELECT oh.manager_id::text
  FROM org_hierarchy oh
  WHERE oh.employee_id::text IN (
    SELECT created_by::text FROM material_requests WHERE request_number = 'MR-01-2026-000009'
  )
);
