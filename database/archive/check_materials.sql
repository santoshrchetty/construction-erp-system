-- Check complete materials available after cleanup
SELECT 
  'MATERIALS SUMMARY' as report_type,
  COUNT(*) as total_materials,
  COUNT(DISTINCT category) as total_categories
FROM stock_items;

-- List all materials by category
SELECT 
  category,
  COUNT(*) as material_count,
  STRING_AGG(item_code, ', ') as material_codes
FROM stock_items 
GROUP BY category
ORDER BY category;

-- Check materials with plant assignments
SELECT 
  'PLANT ASSIGNMENTS' as report_type,
  COUNT(*) as assigned_materials
FROM material_plant_data;

-- Check materials with storage assignments  
SELECT 
  'STORAGE ASSIGNMENTS' as report_type,
  COUNT(*) as assigned_materials
FROM material_storage_data;

-- List all available materials
SELECT 
  item_code,
  description,
  category,
  unit,
  is_active
FROM stock_items
ORDER BY category, item_code;