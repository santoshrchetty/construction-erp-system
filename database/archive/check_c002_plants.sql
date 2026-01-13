-- Check plants for Company C002
SELECT 
  p.id,
  p.plant_code,
  p.plant_name,
  cc.company_code,
  cc.company_name
FROM plants p
JOIN company_codes cc ON p.company_code_id = cc.id
WHERE cc.company_code = 'C002'
ORDER BY p.plant_code;

-- Check all company-plant relationships
SELECT 
  cc.company_code,
  cc.company_name,
  p.plant_code,
  p.plant_name
FROM company_codes cc
LEFT JOIN plants p ON cc.id = p.company_code_id
ORDER BY cc.company_code, p.plant_code;