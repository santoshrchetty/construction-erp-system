-- Populate material_storage_data with sample stock

-- First, check what we have
SELECT 
    m.id as material_id,
    m.material_code,
    m.material_name,
    sl.id as storage_location_id,
    sl.sloc_code,
    p.plant_code
FROM materials m
CROSS JOIN storage_locations sl
JOIN plants p ON sl.plant_id = p.id
WHERE m.is_active = true
  AND sl.is_active = true
  AND p.plant_code IN ('P001', 'P002')
ORDER BY p.plant_code, sl.sloc_code, m.material_code
LIMIT 20;

-- Insert sample stock data for materials in P001 and P002 plants
INSERT INTO material_storage_data (material_id, storage_location_id, current_stock, reserved_stock)
SELECT 
    m.id,
    sl.id,
    CASE 
        WHEN RANDOM() < 0.7 THEN (RANDOM() * 1000)::NUMERIC(10,2)  -- 70% have stock
        ELSE 0
    END as current_stock,
    CASE 
        WHEN RANDOM() < 0.3 THEN (RANDOM() * 100)::NUMERIC(10,2)   -- 30% have reservations
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

-- No need to update available_stock - it's auto-calculated

-- Verify results
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
ORDER BY p.plant_code, sl.sloc_code, m.material_code
LIMIT 20;
