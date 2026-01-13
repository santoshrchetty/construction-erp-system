-- Check the project numbering function
SELECT routine_name, routine_definition 
FROM information_schema.routines 
WHERE routine_name LIKE '%project_number%';

-- Check if the function exists
SELECT proname FROM pg_proc WHERE proname LIKE '%project_number%';

-- Test the function directly
SELECT generate_project_number_with_pattern('PROJECT', 'C001', 'HW-{####}');

-- Check actual projects vs counter mismatch
SELECT 
  (SELECT current_number FROM project_numbering_rules WHERE pattern = 'HW-{####}') as counter_value,
  (SELECT COUNT(*) FROM projects WHERE code LIKE 'HW-%') as actual_projects;