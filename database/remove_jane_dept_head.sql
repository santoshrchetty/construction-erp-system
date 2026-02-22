-- Remove Jane Manager's DEPT_HEAD role for ENG
DELETE FROM role_assignments
WHERE id = '669ddb9d-b89e-4abe-906f-a2f1157e0dc0';

-- Verify only Bob is DEPT_HEAD for ENG now
SELECT 
  ra.id,
  ra.employee_id,
  oh.employee_name,
  oh.position_title,
  ra.scope_value
FROM role_assignments ra
JOIN org_hierarchy oh ON ra.employee_id = oh.employee_id
WHERE ra.role_code = 'DEPT_HEAD'
AND ra.scope_value = 'ENG'
AND ra.is_active = true;
