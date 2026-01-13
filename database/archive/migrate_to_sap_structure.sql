-- Migration Strategy: Preserve Existing Data + Add SAP Structure
-- This script migrates existing data to new SAP organizational structure

-- =====================================================
-- STEP 1: CREATE SAP ORGANIZATIONAL STRUCTURE
-- =====================================================

-- Run the complete SAP config first
\i sap_organizational_structure.sql
\i inter_company_transactions.sql  
\i sap_complete_config.sql

-- =====================================================
-- STEP 2: MIGRATE EXISTING PROJECTS TO SAP STRUCTURE
-- =====================================================

-- Set default company code for existing projects
UPDATE projects 
SET company_code_id = (SELECT id FROM company_codes WHERE company_code = 'C001')
WHERE company_code_id IS NULL;

-- Set default purchasing org for existing projects
UPDATE projects 
SET purchasing_org_id = (SELECT id FROM purchasing_organizations WHERE porg_code = 'PO01')
WHERE purchasing_org_id IS NULL;

-- Set default controlling area for existing projects
UPDATE projects 
SET controlling_area_id = (SELECT id FROM controlling_areas WHERE cocarea_code = '1000')
WHERE controlling_area_id IS NULL;

-- Assign cost centers based on project type
UPDATE projects 
SET cost_center_id = (
    CASE 
        WHEN project_type = 'residential' THEN (SELECT id FROM cost_centers WHERE cost_center_code = 'CC001')
        WHEN project_type = 'commercial' THEN (SELECT id FROM cost_centers WHERE cost_center_code = 'CC002')
        WHEN project_type = 'infrastructure' THEN (SELECT id FROM cost_centers WHERE cost_center_code = 'CC101')
        ELSE (SELECT id FROM cost_centers WHERE cost_center_code = 'CC001')
    END
)
WHERE cost_center_id IS NULL;

-- Assign profit centers based on project type
UPDATE projects 
SET profit_center_id = (
    CASE 
        WHEN project_type = 'residential' THEN (SELECT id FROM profit_centers WHERE profit_center_code = 'PC001')
        WHEN project_type = 'commercial' THEN (SELECT id FROM profit_centers WHERE profit_center_code = 'PC002')
        WHEN project_type = 'infrastructure' THEN (SELECT id FROM profit_centers WHERE profit_center_code = 'PC101')
        ELSE (SELECT id FROM profit_centers WHERE profit_center_code = 'PC001')
    END
)
WHERE profit_center_id IS NULL;

-- =====================================================
-- STEP 3: CREATE PLANTS FOR EXISTING PROJECTS
-- =====================================================

-- Create plant for each existing project
INSERT INTO plants (company_code_id, plant_code, plant_name, plant_type, project_id)
SELECT 
    p.company_code_id,
    'P' || LPAD(ROW_NUMBER() OVER (ORDER BY p.created_at)::text, 3, '0'),
    p.name || ' - Site',
    'PROJECT',
    p.id
FROM projects p
WHERE NOT EXISTS (SELECT 1 FROM plants pl WHERE pl.project_id = p.id);

-- Update projects with their plant assignments
UPDATE projects 
SET plant_id = plants.id
FROM plants 
WHERE plants.project_id = projects.id AND projects.plant_id IS NULL;

-- =====================================================
-- STEP 4: CREATE STORAGE LOCATIONS FOR EXISTING STORES
-- =====================================================

-- Create storage locations for existing stores
INSERT INTO storage_locations (plant_id, sloc_code, sloc_name, location_type)
SELECT 
    pl.id,
    '0001',
    s.name,
    'WAREHOUSE'
FROM stores s
JOIN projects p ON s.project_id = p.id
JOIN plants pl ON pl.project_id = p.id
WHERE NOT EXISTS (SELECT 1 FROM storage_locations sl WHERE sl.plant_id = pl.id);

-- Link existing stores with storage locations
UPDATE stores 
SET storage_location_id = sl.id
FROM storage_locations sl
JOIN plants pl ON sl.plant_id = pl.id
JOIN projects p ON pl.project_id = p.id
WHERE stores.project_id = p.id AND stores.storage_location_id IS NULL;

-- =====================================================
-- STEP 5: PRESERVE EXISTING MATERIALS (NO CHANGES NEEDED)
-- =====================================================

-- Existing stock_items table remains unchanged
-- Materials keep their current structure
-- project_id field already exists for account assignment

-- =====================================================
-- STEP 6: MIGRATE EXISTING VENDORS TO SAP STRUCTURE
-- =====================================================

-- Add company code to existing vendors (default to main company)
UPDATE vendors 
SET company_code_id = (SELECT id FROM company_codes WHERE company_code = 'C001')
WHERE company_code_id IS NULL;

-- =====================================================
-- STEP 7: UPDATE EXISTING PURCHASE ORDERS
-- =====================================================

-- Ensure all POs have purchasing org assignment
UPDATE purchase_orders 
SET purchasing_org_id = (SELECT id FROM purchasing_organizations WHERE porg_code = 'PO01')
FROM projects p 
WHERE purchase_orders.project_id = p.id 
AND purchase_orders.purchasing_org_id IS NULL;

-- =====================================================
-- STEP 8: CREATE MIGRATION SUMMARY VIEW
-- =====================================================

CREATE OR REPLACE VIEW migration_summary AS
SELECT 
    'Projects' as entity,
    COUNT(*) as total_count,
    COUNT(company_code_id) as migrated_count,
    COUNT(company_code_id)::float / COUNT(*) * 100 as migration_percentage
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
    COUNT(company_code_id)::float / COUNT(*) * 100 as migration_percentage
FROM vendors;

-- =====================================================
-- STEP 9: VALIDATION QUERIES
-- =====================================================

-- Check migration status
SELECT * FROM migration_summary;

-- Verify project assignments
SELECT 
    p.code,
    p.name,
    cc.company_code,
    po.porg_code,
    cost.cost_center_code,
    profit.profit_center_code,
    pl.plant_code
FROM projects p
LEFT JOIN company_codes cc ON p.company_code_id = cc.id
LEFT JOIN purchasing_organizations po ON p.purchasing_org_id = po.id
LEFT JOIN cost_centers cost ON p.cost_center_id = cost.id
LEFT JOIN profit_centers profit ON p.profit_center_id = profit.id
LEFT JOIN plants pl ON p.plant_id = pl.id
ORDER BY p.created_at;

-- Verify material assignments (should show both global and project-specific)
SELECT 
    si.item_code,
    si.description,
    CASE 
        WHEN si.project_id IS NULL THEN 'Normal Stock'
        ELSE 'Q: ' || p.code
    END as account_assignment
FROM stock_items si
LEFT JOIN projects p ON si.project_id = p.id
ORDER BY si.item_code;

-- =====================================================
-- STEP 10: CLEANUP (OPTIONAL - RUN ONLY IF NEEDED)
-- =====================================================

-- Remove any orphaned records (uncomment if needed)
-- DELETE FROM stock_balances WHERE store_id NOT IN (SELECT id FROM stores);
-- DELETE FROM stock_movements WHERE store_id NOT IN (SELECT id FROM stores);