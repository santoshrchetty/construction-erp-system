-- Check if Bob Director exists
SELECT id, email, raw_user_meta_data
FROM auth.users
WHERE email = 'bob.director@example.com';

-- Check if Bob exists in org_hierarchy
SELECT employee_id, employee_name, position_title, department_code
FROM org_hierarchy
WHERE employee_name LIKE '%Bob%' OR employee_name LIKE '%Director%';

-- Add Bob Director as DEPT_HEAD for ENG
INSERT INTO role_assignments (role_code, employee_id, scope_type, scope_value, is_active)
VALUES ('DEPT_HEAD', '92d13ccc-8ba5-4cc1-88c6-14bb39d4e92a', 'DEPARTMENT', 'ENG', true);

-- Remove Jane Manager's duplicate DEPT_HEAD role for ENG (keep only one)
DELETE FROM role_assignments
WHERE id = 'a4b3fe64-243c-41b7-9f63-61f5aa0643e8';

-- Verify role assignments for DEPT_HEAD in ENG
SELECT 
  ra.id,
  ra.employee_id,
  oh.employee_name,
  ra.scope_value
FROM role_assignments ra
JOIN org_hierarchy oh ON ra.employee_id = oh.employee_id
WHERE ra.role_code = 'DEPT_HEAD'
AND ra.scope_value = 'ENG'
AND ra.is_active = true;
