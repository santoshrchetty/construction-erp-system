-- Check all projects with HW pattern
SELECT 
    code,
    name,
    created_at,
    CASE 
        WHEN code ~ '^HW-[0-9]+$' THEN 
            CAST(SUBSTRING(code FROM 'HW-([0-9]+)') AS INTEGER)
        ELSE 0
    END as extracted_number
FROM projects 
WHERE code LIKE 'HW-%'
ORDER BY extracted_number DESC;

-- Check what the function sees as max existing
SELECT COALESCE(MAX(
    CASE 
        WHEN code ~ '^HW-[0-9]+$' THEN 
            CAST(SUBSTRING(code FROM 'HW-([0-9]+)') AS INTEGER)
        ELSE 0
    END
), 0) as max_existing_hw_number
FROM projects;