-- Check materials with stock in storage locations

-- Materials with stock data
SELECT 
    m.material_code,
    m.material_name,
    m.base_uom,
    msd.current_stock,
    msd.reserved_stock,
    msd.available_stock,
    sl.sloc_code,
    sl.sloc_name,
    p.plant_code,
    p.plant_name
FROM materials m
JOIN material_storage_data msd ON m.id = msd.material_id
JOIN storage_locations sl ON msd.storage_location_id = sl.id
JOIN plants p ON sl.plant_id = p.id
WHERE m.is_active = true
  AND sl.is_active = true
ORDER BY p.plant_code, sl.sloc_code, m.material_code;

-- Summary by storage location
SELECT 
    p.plant_code,
    sl.sloc_code,
    sl.sloc_name,
    COUNT(DISTINCT m.id) as material_count,
    SUM(CASE WHEN msd.available_stock > 0 THEN 1 ELSE 0 END) as materials_in_stock
FROM storage_locations sl
JOIN plants p ON sl.plant_id = p.id
LEFT JOIN material_storage_data msd ON sl.id = msd.storage_location_id
LEFT JOIN materials m ON msd.material_id = m.id AND m.is_active = true
WHERE sl.is_active = true
GROUP BY p.plant_code, sl.sloc_code, sl.sloc_name
ORDER BY p.plant_code, sl.sloc_code;
