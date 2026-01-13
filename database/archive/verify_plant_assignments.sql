-- Check if plants have company_code_id assigned
SELECT 
    p.plant_code,
    p.plant_name,
    p.company_code_id,
    cc.company_code,
    cc.company_name
FROM plants p
LEFT JOIN company_codes cc ON p.company_code_id = cc.id
ORDER BY p.plant_code;

-- Update any plants that don't have company assignments
UPDATE plants 
SET company_code_id = (SELECT id FROM company_codes WHERE company_code = 'C001' LIMIT 1)
WHERE company_code_id IS NULL;