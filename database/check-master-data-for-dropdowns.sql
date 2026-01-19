-- Check existing master data tables for Material Request dropdowns

-- First, check what tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
  AND table_name IN ('company_codes', 'plants', 'cost_centers', 'projects', 'materials', 'storage_locations', 'vendors')
ORDER BY table_name;

-- 1. Company Codes
SELECT 'company_codes' as table_name, COUNT(*) as record_count FROM company_codes WHERE is_active = true;

-- 2. Plants
SELECT 'plants' as table_name, COUNT(*) as record_count FROM plants WHERE is_active = true;

-- 3. Cost Centers
SELECT 'cost_centers' as table_name, COUNT(*) as record_count FROM cost_centers WHERE is_active = true;

-- 4. Projects
SELECT 'projects' as table_name, COUNT(*) as record_count FROM projects;

-- 5. Materials
SELECT 'materials' as table_name, COUNT(*) as record_count FROM materials WHERE is_active = true;

-- 6. Storage Locations
SELECT 'storage_locations' as table_name, COUNT(*) as record_count FROM storage_locations WHERE is_active = true;

-- 7. Vendors
SELECT 'vendors' as table_name, COUNT(*) as record_count FROM vendors WHERE is_active = true;

-- Show sample company codes
SELECT company_code, company_name, currency FROM company_codes WHERE is_active = true LIMIT 5;

-- Show sample plants
SELECT plant_code, plant_name, plant_type FROM plants WHERE is_active = true LIMIT 5;

-- Show sample cost centers
SELECT cost_center_code, cost_center_name, company_code FROM cost_centers WHERE is_active = true LIMIT 5;

-- Show sample projects
SELECT code, name, status FROM projects LIMIT 5;

-- Show sample materials
SELECT material_code, material_name, base_uom, standard_price FROM materials WHERE is_active = true LIMIT 5;

-- Show sample storage locations with plant info
SELECT sl.sloc_code, sl.sloc_name, p.plant_code, p.plant_name 
FROM storage_locations sl
JOIN plants p ON sl.plant_id = p.id
WHERE sl.is_active = true LIMIT 5;

-- Show sample vendors
SELECT vendor_code, vendor_name, contact_person, phone FROM vendors WHERE is_active = true LIMIT 5;
