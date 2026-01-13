-- Check storage locations for Plant P002
SELECT 
  sl.id,
  sl.sloc_code,
  sl.sloc_name,
  p.plant_code,
  cc.company_code
FROM storage_locations sl
JOIN plants p ON sl.plant_id = p.id
JOIN company_codes cc ON p.company_code_id = cc.id
WHERE p.plant_code = 'P002'
ORDER BY sl.sloc_code;