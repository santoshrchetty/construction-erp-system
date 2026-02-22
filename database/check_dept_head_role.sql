-- Check role assignments for DEPT_HEAD
SELECT 
  ra.id,
  ra.role_code,
  ra.employee_id,
  ra.scope_type,
  ra.scope_value,
  oh.employee_name,
  oh.position_title
FROM role_assignments ra
JOIN org_hierarchy oh ON ra.employee_id = oh.employee_id
WHERE ra.role_code = 'DEPT_HEAD'
AND ra.is_active = true;

-- Check if DEPT_HEAD role exists in agent_rules
SELECT rule_code, rule_name, rule_type, resolution_logic
FROM agent_rules
WHERE rule_code = 'DEPT_HEAD';
