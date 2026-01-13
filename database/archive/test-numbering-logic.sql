-- Test the numbering function logic
SELECT 
    code,
    CASE 
        WHEN code ~ '^HW-[0-9]+$' THEN 
            CAST(SUBSTRING(code FROM 'HW-([0-9]+)') AS INTEGER)
        ELSE 0
    END as extracted_number
FROM projects 
WHERE code LIKE 'HW-%'
ORDER BY extracted_number DESC;

-- Test the function directly
SELECT generate_project_number_with_pattern('PROJECT', 'C001', 'HW-{####}');

-- Check current numbering rules
SELECT * FROM project_numbering_rules WHERE pattern = 'HW-{####}' AND company_code = 'C001';