-- Complete SAP Setup - Run this first
-- Execute in Supabase SQL Editor

-- Step 1: Run organizational structure
\i sap_organizational_structure.sql

-- Step 2: Run inter-company transactions
\i inter_company_transactions.sql

-- Step 3: Update existing data with default company
UPDATE projects 
SET company_code_id = (SELECT id FROM company_codes WHERE company_code = 'C001')
WHERE company_code_id IS NULL;

UPDATE projects 
SET purchasing_org_id = (SELECT id FROM purchasing_organizations WHERE porg_code = 'PO01')
WHERE purchasing_org_id IS NULL;

-- Step 4: Create default plants for existing projects
INSERT INTO plants (company_code_id, plant_code, plant_name, plant_type, project_id)
SELECT 
    p.company_code_id,
    'P' || LPAD(ROW_NUMBER() OVER (ORDER BY p.created_at)::text, 3, '0'),
    p.name || ' - Site',
    'PROJECT',
    p.id
FROM projects p
WHERE NOT EXISTS (SELECT 1 FROM plants pl WHERE pl.project_id = p.id);

-- Step 5: Update projects with their plants
UPDATE projects 
SET plant_id = plants.id
FROM plants 
WHERE plants.project_id = projects.id AND projects.plant_id IS NULL;

-- Step 6: Create default storage locations
INSERT INTO storage_locations (plant_id, sloc_code, sloc_name, location_type)
SELECT 
    pl.id,
    '0001',
    'Main Warehouse',
    'WAREHOUSE'
FROM plants pl
WHERE NOT EXISTS (SELECT 1 FROM storage_locations sl WHERE sl.plant_id = pl.id);

-- Step 7: Link existing stores with storage locations
UPDATE stores 
SET storage_location_id = sl.id
FROM storage_locations sl
JOIN plants pl ON sl.plant_id = pl.id
WHERE stores.project_id = pl.project_id AND stores.storage_location_id IS NULL;