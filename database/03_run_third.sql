-- SCRIPT 3: Migrate Existing Data to SAP Structure
-- Copy and paste this entire script into Supabase SQL Editor

-- Set default company code for existing projects
UPDATE projects 
SET company_code_id = (SELECT id FROM company_codes WHERE company_code = 'C001')
WHERE company_code_id IS NULL;

-- Set default purchasing org for existing projects
UPDATE projects 
SET purchasing_org_id = (SELECT id FROM purchasing_organizations WHERE porg_code = 'PO01')
WHERE purchasing_org_id IS NULL;

-- Create plants for existing projects
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

-- Create storage locations for existing stores
INSERT INTO storage_locations (plant_id, sloc_code, sloc_name, location_type)
SELECT 
    pl.id,
    '0001',
    COALESCE(s.name, 'Main Warehouse'),
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

-- Set default company code for existing vendors
UPDATE vendors 
SET company_code_id = (SELECT id FROM company_codes WHERE company_code = 'C001')
WHERE company_code_id IS NULL;