-- Phase 1.2: Populate Stock Data
-- Add sample stock for materials in P001 and P002 plants

-- Step 1: Clear any existing test data (optional)
-- DELETE FROM material_storage_data WHERE material_id IN (
--   SELECT id FROM materials WHERE material_code LIKE 'TEST-%'
-- );

-- Step 2: Check what we're about to insert
SELECT 
    COUNT(*) as total_combinations,
    COUNT(DISTINCT m.id) as unique_materials,
    COUNT(DISTINCT sl.id) as unique_locations
FROM materials m
CROSS JOIN storage_locations sl
JOIN plants p ON sl.plant_id = p.id
WHERE m.is_active = true
  AND sl.is_active = true
  AND p.plant_code IN ('P001', 'P002')
  AND NOT EXISTS (
    SELECT 1 FROM material_storage_data msd 
    WHERE msd.material_id = m.id 
    AND msd.storage_location_id = sl.id
  );

-- Step 3: Insert stock data
INSERT INTO material_storage_data (material_id, storage_location_id, current_stock, reserved_stock)
SELECT 
    m.id,
    sl.id,
    CASE 
        WHEN RANDOM() < 0.7 THEN ROUND((RANDOM() * 1000)::NUMERIC, 2)
        ELSE 0
    END as current_stock,
    CASE 
        WHEN RANDOM() < 0.3 THEN ROUND((RANDOM() * 100)::NUMERIC, 2)
        ELSE 0
    END as reserved_stock
FROM materials m
CROSS JOIN storage_locations sl
JOIN plants p ON sl.plant_id = p.id
WHERE m.is_active = true
  AND sl.is_active = true
  AND p.plant_code IN ('P001', 'P002')
  AND NOT EXISTS (
    SELECT 1 FROM material_storage_data msd 
    WHERE msd.material_id = m.id 
    AND msd.storage_location_id = sl.id
  );

-- Step 4: Verify insertion
SELECT 
    p.plant_code,
    sl.sloc_code,
    COUNT(*) as materials_count,
    SUM(CASE WHEN msd.current_stock > 0 THEN 1 ELSE 0 END) as materials_with_stock,
    ROUND(SUM(msd.current_stock), 2) as total_stock,
    ROUND(SUM(msd.available_stock), 2) as total_available
FROM material_storage_data msd
JOIN storage_locations sl ON msd.storage_location_id = sl.id
JOIN plants p ON sl.plant_id = p.id
WHERE p.plant_code IN ('P001', 'P002')
GROUP BY p.plant_code, sl.sloc_code
ORDER BY p.plant_code, sl.sloc_code;

-- Step 5: Show sample materials with stock
SELECT 
    m.material_code,
    m.material_name,
    sl.sloc_code,
    p.plant_code,
    msd.current_stock,
    msd.reserved_stock,
    msd.available_stock
FROM material_storage_data msd
JOIN materials m ON msd.material_id = m.id
JOIN storage_locations sl ON msd.storage_location_id = sl.id
JOIN plants p ON sl.plant_id = p.id
WHERE msd.current_stock > 0
  AND p.plant_code IN ('P001', 'P002')
ORDER BY p.plant_code, sl.sloc_code, m.material_code
LIMIT 20;

-- Success message
SELECT 'Phase 1.2 Complete: Stock data populated for P001 and P002 plants' as status;
