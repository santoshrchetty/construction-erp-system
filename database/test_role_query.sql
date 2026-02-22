-- Simulate what getRoleAssignments returns for DEPT_HEAD
SELECT 
  ra.*,
  oh.employee_name,
  oh.position_title,
  oh.department_code,
  oh.plant_code
FROM role_assignments ra
JOIN org_hierarchy oh ON ra.employee_id = oh.employee_id
WHERE ra.role_code = 'DEPT_HEAD'
AND ra.is_active = true;

-- Filter by department_code = 'ENG' (what the code should do)
SELECT 
  ra.employee_id,
  ra.role_code,
  ra.scope_value,
  oh.employee_name
FROM role_assignments ra
JOIN org_hierarchy oh ON ra.employee_id = oh.employee_id
WHERE ra.role_code = 'DEPT_HEAD'
AND ra.is_active = true
AND ra.scope_value = 'ENG';
