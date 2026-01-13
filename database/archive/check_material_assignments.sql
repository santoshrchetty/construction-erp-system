-- Check material assignments for ASP-CMA
SELECT 
  si.item_code,
  si.description,
  cc.company_code,
  p.plant_code,
  sl.sloc_code,
  msd.current_stock
FROM stock_items si
JOIN material_plant_data mpd ON si.id = mpd.material_id
JOIN plants p ON mpd.plant_id = p.id
JOIN company_codes cc ON p.company_id = cc.id
LEFT JOIN material_storage_data msd ON si.id = msd.material_id
LEFT JOIN storage_locations sl ON msd.storage_location_id = sl.id
WHERE si.item_code = 'ASP-CMA'
ORDER BY cc.company_code, p.plant_code;

-- Check all ASP materials assignments
SELECT 
  si.item_code,
  si.description,
  cc.company_code,
  p.plant_code
FROM stock_items si
JOIN material_plant_data mpd ON si.id = mpd.material_id
JOIN plants p ON mpd.plant_id = p.id
JOIN company_codes cc ON p.company_id = cc.id
WHERE si.item_code LIKE 'ASP-%'
ORDER BY si.item_code, cc.company_code;