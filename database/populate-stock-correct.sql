-- Populate material_storage_data using stock_items (correct approach)

-- 1. Check what stock_items we have
SELECT 
    si.id as stock_item_id,
    si.item_code,
    si.description,
    sl.id as storage_location_id,
    sl.sloc_code,
    p.plant_code
FROM stock_items si
CROSS JOIN storage_locations sl
JOIN plants p ON sl.plant_id = p.id
WHERE si.is_active = true
  AND sl.is_active = true
  AND p.plant_code IN ('P001', 'P002')
ORDER BY p.plant_code, sl.sloc_code, si.item_code
LIMIT 20;

-- 2. Insert sample stock data using stock_items
INSERT INTO material_storage_data (material_id, storage_location_id, current_stock, reserved_stock)
SELECT 
    si.id,
    sl.id,
    CASE 
        WHEN RANDOM() < 0.7 THEN (RANDOM() * 1000)::NUMERIC(10,2)
        ELSE 0
    END as current_stock,
    CASE 
        WHEN RANDOM() < 0.3 THEN (RANDOM() * 100)::NUMERIC(10,2)
        ELSE 0
    END as reserved_stock
FROM stock_items si
CROSS JOIN storage_locations sl
JOIN plants p ON sl.plant_id = p.id
WHERE si.is_active = true
  AND sl.is_active = true
  AND p.plant_code IN ('P001', 'P002')
  AND NOT EXISTS (
    SELECT 1 FROM material_storage_data msd 
    WHERE msd.material_id = si.id 
    AND msd.storage_location_id = sl.id
  );

-- 3. Verify results
SELECT 
    si.item_code,
    si.description,
    sl.sloc_code,
    p.plant_code,
    msd.current_stock,
    msd.reserved_stock,
    msd.available_stock
FROM material_storage_data msd
JOIN stock_items si ON msd.material_id = si.id
JOIN storage_locations sl ON msd.storage_location_id = sl.id
JOIN plants p ON sl.plant_id = p.id
WHERE msd.current_stock > 0
ORDER BY p.plant_code, sl.sloc_code, si.item_code
LIMIT 20;
