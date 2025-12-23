-- SCRIPT 4: Verification and Views
-- Copy and paste this entire script into Supabase SQL Editor

-- Create migration summary view
CREATE OR REPLACE VIEW migration_summary AS
SELECT 
    'Projects' as entity,
    COUNT(*) as total_count,
    COUNT(company_code_id) as migrated_count,
    ROUND(COUNT(company_code_id)::numeric / COUNT(*) * 100, 2) as migration_percentage
FROM projects
UNION ALL
SELECT 
    'Plants' as entity,
    COUNT(*) as total_count,
    COUNT(*) as migrated_count,
    100.0 as migration_percentage
FROM plants
UNION ALL
SELECT 
    'Storage Locations' as entity,
    COUNT(*) as total_count,
    COUNT(*) as migrated_count,
    100.0 as migration_percentage
FROM storage_locations
UNION ALL
SELECT 
    'Materials' as entity,
    COUNT(*) as total_count,
    COUNT(*) as migrated_count,
    100.0 as migration_percentage
FROM stock_items
UNION ALL
SELECT 
    'Vendors' as entity,
    COUNT(*) as total_count,
    COUNT(company_code_id) as migrated_count,
    ROUND(COUNT(company_code_id)::numeric / COUNT(*) * 100, 2) as migration_percentage
FROM vendors;

-- Verification query
SELECT 
    p.code as project_code,
    p.name as project_name,
    cc.company_code,
    po.porg_code as purchasing_org,
    pl.plant_code,
    sl.sloc_code as storage_location
FROM projects p
LEFT JOIN company_codes cc ON p.company_code_id = cc.id
LEFT JOIN purchasing_organizations po ON p.purchasing_org_id = po.id
LEFT JOIN plants pl ON p.plant_id = pl.id
LEFT JOIN storage_locations sl ON pl.id = sl.plant_id
ORDER BY p.created_at;

-- Check migration status
SELECT * FROM migration_summary;