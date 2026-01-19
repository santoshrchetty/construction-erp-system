-- Check which storage locations have materials with stock

-- Summary by storage location
SELECT 
    p.plant_code,
    p.plant_name,
    sl.sloc_code,
    sl.sloc_name,
    COUNT(DISTINCT msd.material_id) as total_materials,
    SUM(CASE WHEN msd.current_stock > 0 THEN 1 ELSE 0 END) as materials_with_stock,
    SUM(CASE WHEN msd.available_stock > 0 THEN 1 ELSE 0 END) as materials_available,
    ROUND(SUM(msd.current_stock), 2) as total_current_stock,
    ROUND(SUM(msd.available_stock), 2) as total_available_stock
FROM storage_locations sl
JOIN plants p ON sl.plant_id = p.id
LEFT JOIN material_storage_data msd ON sl.id = msd.storage_location_id
WHERE sl.is_active = true
GROUP BY p.plant_code, p.plant_name, sl.sloc_code, sl.sloc_name
HAVING COUNT(msd.id) > 0
ORDER BY p.plant_code, sl.sloc_code;

-- Detailed view: Which materials in which locations
SELECT 
    p.plant_code,
    sl.sloc_code,
    sl.sloc_name,
    m.material_code,
    m.material_name,
    m.base_uom,
    msd.current_stock,
    msd.reserved_stock,
    msd.available_stock
FROM material_storage_data msd
JOIN materials m ON msd.material_id = m.id
JOIN storage_locations sl ON msd.storage_location_id = sl.id
JOIN plants p ON sl.plant_id = p.id
WHERE msd.current_stock > 0
ORDER BY p.plant_code, sl.sloc_code, m.material_code;
