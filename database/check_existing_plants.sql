-- Check existing plant master data
SELECT 
  plant_code,
  plant_name,
  plant_type,
  company_code,
  is_active
FROM plants
WHERE is_active = true
ORDER BY plant_code;
