-- Test Material Request Dropdown APIs
-- Run these queries to verify data is ready for API consumption

-- 1. Companies (for dropdown)
SELECT company_code, company_name, currency 
FROM company_codes 
WHERE is_active = true 
ORDER BY company_code;

-- 2. Plants (cascading by company)
SELECT p.plant_code, p.plant_name, p.plant_type, cc.company_code
FROM plants p
JOIN company_codes cc ON p.company_code_id = cc.id
WHERE p.is_active = true
ORDER BY cc.company_code, p.plant_code;

-- 3. Storage Locations (cascading by plant)
SELECT sl.sloc_code, sl.sloc_name, sl.location_type, p.plant_code, p.plant_name
FROM storage_locations sl
JOIN plants p ON sl.plant_id = p.id
WHERE sl.is_active = true
ORDER BY p.plant_code, sl.sloc_code;

-- 4. Materials with stock (for autocomplete)
SELECT 
    m.material_code,
    m.material_name,
    m.base_uom,
    m.standard_price,
    msd.current_stock,
    msd.reserved_stock,
    msd.available_stock,
    sl.sloc_code,
    p.plant_code
FROM materials m
LEFT JOIN material_storage_data msd ON m.id = msd.material_id
LEFT JOIN storage_locations sl ON msd.storage_location_id = sl.id
LEFT JOIN plants p ON sl.plant_id = p.id
WHERE m.is_active = true
ORDER BY m.material_name
LIMIT 10;

-- 5. Material search test (like API will do)
SELECT material_code, material_name, category_name, group_name, base_uom, plant_count
FROM material_master_view
WHERE material_name ILIKE '%cement%' OR material_code ILIKE '%cement%'
LIMIT 5;

-- 6. Projects (for cost object)
SELECT code, name, status FROM projects WHERE status IN ('planning', 'active') LIMIT 5;

-- 7. Cost Centers
SELECT cost_center_code, cost_center_name, company_code 
FROM cost_centers 
WHERE is_active = true 
LIMIT 5;

-- 8. Vendors
SELECT vendor_code, vendor_name, contact_person, phone 
FROM vendors 
WHERE is_active = true 
LIMIT 5;
