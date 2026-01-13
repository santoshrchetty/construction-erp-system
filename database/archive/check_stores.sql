-- Check existing stores
SELECT s.id, s.code, s.name, s.project_id, s.storage_location_id 
FROM stores s;

-- Check stores with full organizational structure
SELECT 
  s.code as store_code,
  s.name as store_name,
  proj.code as project_code,
  sl.sloc_code,
  p.plant_code,
  cc.company_code
FROM stores s 
LEFT JOIN projects proj ON s.project_id = proj.id
LEFT JOIN company_codes cc ON proj.company_code_id = cc.id
LEFT JOIN storage_locations sl ON s.storage_location_id = sl.id
LEFT JOIN plants p ON sl.plant_id = p.id;