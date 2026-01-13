-- Update all organizational code fields to maximum lengths for ERP integration flexibility
-- Using NetSuite's 31-character limit as the maximum across all major ERPs

-- 1. Company Codes (currently 4 chars → 31 chars)
ALTER TABLE company_codes 
ALTER COLUMN company_code TYPE VARCHAR(31);

-- 2. Plants (currently 6 chars → 31 chars) 
ALTER TABLE plants 
ALTER COLUMN plant_code TYPE VARCHAR(31);

-- 3. Storage Locations (currently 4 chars → 31 chars)
ALTER TABLE storage_locations 
ALTER COLUMN sloc_code TYPE VARCHAR(31);

-- 4. Controlling Areas (currently 4 chars → 31 chars)
ALTER TABLE controlling_areas 
ALTER COLUMN cocarea_code TYPE VARCHAR(31);

-- 5. Cost Centers (currently 10 chars → 31 chars)
ALTER TABLE cost_centers 
ALTER COLUMN cost_center_code TYPE VARCHAR(31);

-- 6. Profit Centers (currently 10 chars → 31 chars)
ALTER TABLE profit_centers 
ALTER COLUMN profit_center_code TYPE VARCHAR(31);

-- 7. Purchasing Organizations (currently 4 chars → 31 chars)
ALTER TABLE purchasing_organizations 
ALTER COLUMN porg_code TYPE VARCHAR(31);

-- 8. Departments (currently 10 chars → 31 chars)
ALTER TABLE departments 
ALTER COLUMN code TYPE VARCHAR(31);

-- Update name fields to accommodate longer descriptions (Oracle's 240 char limit)
ALTER TABLE company_codes ALTER COLUMN company_name TYPE VARCHAR(240);
ALTER TABLE plants ALTER COLUMN plant_name TYPE VARCHAR(240);
ALTER TABLE storage_locations ALTER COLUMN sloc_name TYPE VARCHAR(240);
ALTER TABLE controlling_areas ALTER COLUMN cocarea_name TYPE VARCHAR(240);
ALTER TABLE cost_centers ALTER COLUMN cost_center_name TYPE VARCHAR(240);
ALTER TABLE profit_centers ALTER COLUMN profit_center_name TYPE VARCHAR(240);
ALTER TABLE purchasing_organizations ALTER COLUMN porg_name TYPE VARCHAR(240);
ALTER TABLE departments ALTER COLUMN name TYPE VARCHAR(240);

-- Verify the changes
SELECT 
  table_name,
  column_name,
  data_type,
  character_maximum_length
FROM information_schema.columns 
WHERE table_name IN (
  'company_codes', 'plants', 'storage_locations', 'controlling_areas',
  'cost_centers', 'profit_centers', 'purchasing_organizations', 'departments'
)
AND column_name LIKE '%code%' OR column_name LIKE '%name%'
ORDER BY table_name, column_name;