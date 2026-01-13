-- Remove duplicate numbering rules, keep the most recent one
DELETE FROM project_numbering_rules 
WHERE id = '11133813-4188-47b3-9849-5684ca5a95e0';

-- Verify only one HW pattern remains
SELECT * FROM project_numbering_rules WHERE pattern = 'HW-{####}' AND company_code = 'C001';

-- Test the function again
SELECT generate_project_number_with_pattern('PROJECT', 'C001', 'HW-{####}');