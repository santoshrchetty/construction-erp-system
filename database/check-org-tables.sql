-- Check if organizational tables exist and have data
SELECT 'Checking organizational tables:' as info;

-- Check company_codes table
SELECT 'company_codes' as table_name, COUNT(*) as record_count
FROM company_codes
UNION ALL
SELECT 'controlling_areas', COUNT(*) FROM controlling_areas
UNION ALL
SELECT 'plants', COUNT(*) FROM plants
UNION ALL
SELECT 'cost_centers', COUNT(*) FROM cost_centers
UNION ALL
SELECT 'profit_centers', COUNT(*) FROM profit_centers
UNION ALL
SELECT 'storage_locations', COUNT(*) FROM storage_locations
UNION ALL
SELECT 'purchasing_organizations', COUNT(*) FROM purchasing_organizations
UNION ALL
SELECT 'departments', COUNT(*) FROM departments;