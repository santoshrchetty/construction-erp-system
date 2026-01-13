-- Step 2: Test both functions (run this after step 1)

-- Check current state
SELECT current_number FROM project_numbering_rules WHERE pattern = 'HW-{####}' AND company_code = 'C001';

-- Test preview function (should NOT increment counter)
SELECT preview_project_number_with_pattern('PROJECT', 'C001', 'HW-{####}') as preview_1;
SELECT preview_project_number_with_pattern('PROJECT', 'C001', 'HW-{####}') as preview_2;

-- Check counter (should be unchanged)
SELECT current_number FROM project_numbering_rules WHERE pattern = 'HW-{####}' AND company_code = 'C001';

-- Test reserve function (should increment counter)
SELECT generate_project_number_with_pattern('PROJECT', 'C001', 'HW-{####}') as reserved_number;

-- Check counter (should be incremented)
SELECT current_number FROM project_numbering_rules WHERE pattern = 'HW-{####}' AND company_code = 'C001';

-- Test preview again (should show next number)
SELECT preview_project_number_with_pattern('PROJECT', 'C001', 'HW-{####}') as next_preview;