-- Check Bob's employee_id
SELECT employee_id, employee_name, position_title, department_code
FROM org_hierarchy
WHERE employee_name LIKE '%Bob%';

-- Check Bob's role assignments
SELECT ra.*, oh.employee_name
FROM role_assignments ra
JOIN org_hierarchy oh ON ra.employee_id = oh.employee_id
WHERE oh.employee_name LIKE '%Bob%';

-- Check latest workflow instance for MR-01-2026-000012
SELECT wi.*, wd.workflow_name
FROM workflow_instances wi
JOIN workflow_definitions wd ON wi.workflow_id = wd.id
WHERE wi.object_id::text IN (
  SELECT id::text FROM material_requests WHERE request_number = 'MR-01-2026-000012'
)
ORDER BY wi.created_at DESC;

-- Check all step instances for this workflow
SELECT si.*, ws.step_name
FROM step_instances si
JOIN workflow_steps ws ON si.workflow_step_id = ws.id
WHERE si.workflow_instance_id IN (
  SELECT wi.id FROM workflow_instances wi
  WHERE wi.object_id::text IN (
    SELECT id::text FROM material_requests WHERE request_number = 'MR-01-2026-000012'
  )
)
ORDER BY si.step_sequence, si.created_at;
