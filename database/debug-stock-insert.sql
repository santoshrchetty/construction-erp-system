-- Debug: Check if stock data was inserted

-- 1. Check if material_storage_data table has any records
SELECT COUNT(*) as total_records FROM material_storage_data;

-- 2. Check if we have materials
SELECT COUNT(*) as total_materials FROM materials WHERE is_active = true;

-- 3. Check if we have storage locations in P001/P002
SELECT p.plant_code, sl.sloc_code, sl.sloc_name, sl.id
FROM storage_locations sl
JOIN plants p ON sl.plant_id = p.id
WHERE p.plant_code IN ('P001', 'P002')
  AND sl.is_active = true;

-- 4. Try manual insert for one material in one location
-- Get first material and first storage location
WITH first_material AS (
  SELECT id FROM materials WHERE is_active = true LIMIT 1
),
first_location AS (
  SELECT sl.id 
  FROM storage_locations sl
  JOIN plants p ON sl.plant_id = p.id
  WHERE p.plant_code = 'P001' AND sl.is_active = true
  LIMIT 1
)
INSERT INTO material_storage_data (material_id, storage_location_id, current_stock, reserved_stock)
SELECT fm.id, fl.id, 100, 10
FROM first_material fm, first_location fl
WHERE NOT EXISTS (
  SELECT 1 FROM material_storage_data 
  WHERE material_id = fm.id AND storage_location_id = fl.id
)
RETURNING *;

-- 5. Verify the insert
SELECT 
    m.material_code,
    m.material_name,
    sl.sloc_code,
    p.plant_code,
    msd.current_stock,
    msd.available_stock
FROM material_storage_data msd
JOIN materials m ON msd.material_id = m.id
JOIN storage_locations sl ON msd.storage_location_id = sl.id
JOIN plants p ON sl.plant_id = p.id
LIMIT 5;
