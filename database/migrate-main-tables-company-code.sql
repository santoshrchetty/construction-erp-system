-- Phase 1: Add company_code string to main ERP tables
-- Keep existing company_code_id for backward compatibility

-- Projects table (already done)
-- ALTER TABLE projects ADD COLUMN IF NOT EXISTS company_code VARCHAR(10);

-- Plants table
ALTER TABLE plants ADD COLUMN IF NOT EXISTS company_code VARCHAR(10);
UPDATE plants 
SET company_code = cc.company_code
FROM company_codes cc 
WHERE plants.company_code_id = cc.id 
AND plants.company_code IS NULL;

-- Purchasing Organizations table
ALTER TABLE purchasing_organizations ADD COLUMN IF NOT EXISTS company_code VARCHAR(10);
UPDATE purchasing_organizations 
SET company_code = cc.company_code
FROM company_codes cc 
WHERE purchasing_organizations.company_code_id = cc.id 
AND purchasing_organizations.company_code IS NULL;

-- Profit Centers table
ALTER TABLE profit_centers ADD COLUMN IF NOT EXISTS company_code VARCHAR(10);
UPDATE profit_centers 
SET company_code = cc.company_code
FROM company_codes cc 
WHERE profit_centers.company_code_id = cc.id 
AND profit_centers.company_code IS NULL;

-- Cost Centers table
ALTER TABLE cost_centers ADD COLUMN IF NOT EXISTS company_code VARCHAR(10);
UPDATE cost_centers 
SET company_code = cc.company_code
FROM company_codes cc 
WHERE cost_centers.company_code_id = cc.id 
AND cost_centers.company_code IS NULL;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_plants_company_code_string ON plants(company_code);
CREATE INDEX IF NOT EXISTS idx_porg_company_code_string ON purchasing_organizations(company_code);
CREATE INDEX IF NOT EXISTS idx_profit_centers_company_code_string ON profit_centers(company_code);
CREATE INDEX IF NOT EXISTS idx_cost_centers_company_code_string ON cost_centers(company_code);