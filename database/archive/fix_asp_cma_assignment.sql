-- Fix ASP-CMA assignment - should only be in C002, not C001
-- Remove ASP-CMA from Plant P001 (Company C001)
DELETE FROM material_storage_data 
WHERE material_id = (SELECT id FROM stock_items WHERE item_code = 'ASP-CMA')
AND storage_location_id IN (
  SELECT sl.id FROM storage_locations sl 
  JOIN plants p ON sl.plant_id = p.id 
  WHERE p.plant_code = 'P001'
);

DELETE FROM material_plant_data 
WHERE material_id = (SELECT id FROM stock_items WHERE item_code = 'ASP-CMA')
AND plant_id = (SELECT id FROM plants WHERE plant_code = 'P001');

-- Verify ASP-CMA is only in C002 now
SELECT 
  si.item_code,
  si.description,
  cc.company_code,
  p.plant_code
FROM stock_items si
JOIN material_plant_data mpd ON si.id = mpd.material_id
JOIN plants p ON mpd.plant_id = p.id
JOIN company_codes cc ON p.company_id = cc.id
WHERE si.item_code = 'ASP-CMA';