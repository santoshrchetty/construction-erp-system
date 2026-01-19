-- Check current employee IDs
SELECT id, employee_code, first_name, last_name 
FROM employees 
WHERE employee_code IN ('EMP-001', 'EMP-007');

-- Check activity_manpower records
SELECT am.id, am.employee_id, am.role, e.employee_code, e.first_name, e.last_name
FROM activity_manpower am
LEFT JOIN employees e ON am.employee_id = e.id
WHERE am.activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71';

-- Fix: Update activity_manpower with correct employee IDs
UPDATE activity_manpower am
SET employee_id = e.id
FROM employees e
WHERE am.activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'
  AND am.role = 'Civil Engineer'
  AND e.employee_code = 'EMP-001';

UPDATE activity_manpower am
SET employee_id = e.id
FROM employees e
WHERE am.activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71'
  AND am.role = 'Surveyor'
  AND e.employee_code = 'EMP-007';

-- Verify fix
SELECT am.id, am.employee_id, am.role, e.employee_code, e.first_name, e.last_name
FROM activity_manpower am
LEFT JOIN employees e ON am.employee_id = e.id
WHERE am.activity_id = '6f9b9bb1-9e72-436a-b682-f80abd9ebf71';
