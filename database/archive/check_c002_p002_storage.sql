-- Check materials for Company C002, Plant P002, Storage Locations 0001 or 0003
SELECT 
  si.item_code,
  si.description,
  si.category,
  sb.current_quantity,
  sl.sloc_code,
  sl.sloc_name,
  p.plant_code,
  cc.company_code
FROM stock_items si
JOIN stock_balances sb ON si.id = sb.stock_item_id
JOIN storage_locations sl ON sb.storage_location_id = sl.id
JOIN plants p ON sl.plant_id = p.id
JOIN company_codes cc ON p.company_code_id = cc.id
WHERE cc.company_code = 'C002' 
  AND p.plant_code = 'P002' 
  AND sl.sloc_code IN ('0001', '0003')
ORDER BY si.item_code;

-- Count materials by storage location for C002/P002
SELECT 
  cc.company_code,
  p.plant_code,
  sl.sloc_code,
  sl.sloc_name,
  COUNT(*) as material_count
FROM stock_items si
JOIN stock_balances sb ON si.id = sb.stock_item_id
JOIN storage_locations sl ON sb.storage_location_id = sl.id
JOIN plants p ON sl.plant_id = p.id
JOIN company_codes cc ON p.company_code_id = cc.id
WHERE cc.company_code = 'C002' AND p.plant_code = 'P002'
GROUP BY cc.company_code, p.plant_code, sl.sloc_code, sl.sloc_name
ORDER BY sl.sloc_code;