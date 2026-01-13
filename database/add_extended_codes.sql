-- Dual-Code Schema for All Organizational Objects
-- SAP-compatible main codes + Extended codes for other ERPs

-- 1. Company Codes
ALTER TABLE company_codes 
ADD COLUMN IF NOT EXISTS company_code_extended VARCHAR(20);

-- 2. Plants  
ALTER TABLE plants 
ADD COLUMN IF NOT EXISTS plant_code_extended VARCHAR(20);

-- 3. Storage Locations
ALTER TABLE storage_locations 
ADD COLUMN IF NOT EXISTS sloc_code_extended VARCHAR(20);

-- 4. Controlling Areas
ALTER TABLE controlling_areas 
ADD COLUMN IF NOT EXISTS cocarea_code_extended VARCHAR(20);

-- 5. Cost Centers
ALTER TABLE cost_centers 
ADD COLUMN IF NOT EXISTS cost_center_code_extended VARCHAR(20);

-- 6. Profit Centers
ALTER TABLE profit_centers 
ADD COLUMN IF NOT EXISTS profit_center_code_extended VARCHAR(20);

-- 7. Purchasing Organizations
ALTER TABLE purchasing_organizations 
ADD COLUMN IF NOT EXISTS porg_code_extended VARCHAR(20);

-- 8. Departments
ALTER TABLE departments 
ADD COLUMN IF NOT EXISTS code_extended VARCHAR(20);

-- Create indexes for extended codes
CREATE INDEX IF NOT EXISTS idx_company_codes_extended ON company_codes(company_code_extended);
CREATE INDEX IF NOT EXISTS idx_plants_extended ON plants(plant_code_extended);
CREATE INDEX IF NOT EXISTS idx_storage_locations_extended ON storage_locations(sloc_code_extended);
CREATE INDEX IF NOT EXISTS idx_controlling_areas_extended ON controlling_areas(cocarea_code_extended);
CREATE INDEX IF NOT EXISTS idx_cost_centers_extended ON cost_centers(cost_center_code_extended);
CREATE INDEX IF NOT EXISTS idx_profit_centers_extended ON profit_centers(profit_center_code_extended);
CREATE INDEX IF NOT EXISTS idx_purchasing_orgs_extended ON purchasing_organizations(porg_code_extended);
CREATE INDEX IF NOT EXISTS idx_departments_extended ON departments(code_extended);

-- Verify additions
SELECT 'Extended code columns added successfully' as status;