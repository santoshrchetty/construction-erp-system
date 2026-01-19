-- Phase 1.3: Verification & Testing
-- Verify Material Request form will work correctly

-- Test 1: Verify companies exist
SELECT 'Test 1: Companies' as test_name, COUNT(*) as count, 
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM company_codes WHERE is_active = true;

-- Test 2: Verify plants exist for P001/P002
SELECT 'Test 2: Plants' as test_name, COUNT(*) as count,
       CASE WHEN COUNT(*) >= 2 THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM plants WHERE plant_code IN ('P001', 'P002') AND is_active = true;

-- Test 3: Verify storage locations exist
SELECT 'Test 3: Storage Locations' as test_name, COUNT(*) as count,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM storage_locations sl
JOIN plants p ON sl.plant_id = p.id
WHERE p.plant_code IN ('P001', 'P002') AND sl.is_active = true;

-- Test 4: Verify materials exist
SELECT 'Test 4: Materials' as test_name, COUNT(*) as count,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM materials WHERE is_active = true;

-- Test 5: Verify stock data exists
SELECT 'Test 5: Stock Data' as test_name, COUNT(*) as count,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM material_storage_data msd
JOIN storage_locations sl ON msd.storage_location_id = sl.id
JOIN plants p ON sl.plant_id = p.id
WHERE p.plant_code IN ('P001', 'P002');

-- Test 6: Verify materials with available stock
SELECT 'Test 6: Available Stock' as test_name, COUNT(*) as count,
       CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM material_storage_data msd
JOIN storage_locations sl ON msd.storage_location_id = sl.id
JOIN plants p ON sl.plant_id = p.id
WHERE p.plant_code IN ('P001', 'P002') AND msd.available_stock > 0;

-- Test 7: Sample material search query (what the API will do)
SELECT 
    'Test 7: Material Search' as test_name,
    m.material_code,
    m.material_name,
    msd.available_stock,
    sl.sloc_code,
    p.plant_code
FROM materials m
JOIN material_storage_data msd ON m.id = msd.material_id
JOIN storage_locations sl ON msd.storage_location_id = sl.id
JOIN plants p ON sl.plant_id = p.id
WHERE m.is_active = true
  AND p.plant_code = 'P001'
  AND (m.material_code ILIKE '%cement%' OR m.material_name ILIKE '%cement%')
  AND msd.available_stock > 0
LIMIT 5;

-- Summary Report
SELECT 
    '=== PHASE 1 VERIFICATION SUMMARY ===' as summary,
    (SELECT COUNT(*) FROM company_codes WHERE is_active = true) as companies,
    (SELECT COUNT(*) FROM plants WHERE plant_code IN ('P001', 'P002')) as plants,
    (SELECT COUNT(*) FROM storage_locations sl JOIN plants p ON sl.plant_id = p.id 
     WHERE p.plant_code IN ('P001', 'P002')) as storage_locations,
    (SELECT COUNT(*) FROM materials WHERE is_active = true) as materials,
    (SELECT COUNT(*) FROM material_storage_data msd JOIN storage_locations sl ON msd.storage_location_id = sl.id 
     JOIN plants p ON sl.plant_id = p.id WHERE p.plant_code IN ('P001', 'P002')) as stock_records,
    (SELECT COUNT(*) FROM material_storage_data msd JOIN storage_locations sl ON msd.storage_location_id = sl.id 
     JOIN plants p ON sl.plant_id = p.id WHERE p.plant_code IN ('P001', 'P002') AND msd.available_stock > 0) as materials_available;

-- Final Status
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM material_storage_data msd 
              JOIN storage_locations sl ON msd.storage_location_id = sl.id 
              JOIN plants p ON sl.plant_id = p.id 
              WHERE p.plant_code IN ('P001', 'P002') AND msd.available_stock > 0) > 0
        THEN '✅ Phase 1 Complete - Material Request form ready to test!'
        ELSE '❌ Phase 1 Failed - Please check errors above'
    END as final_status;
