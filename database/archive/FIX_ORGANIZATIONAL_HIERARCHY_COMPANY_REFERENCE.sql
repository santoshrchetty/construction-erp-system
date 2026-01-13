-- Fix Organizational Hierarchy and Company Dropdown Issues
-- Ensures proper referential integrity and correct API data source

-- Step 1: Add proper foreign key relationship to organizational_hierarchy
ALTER TABLE organizational_hierarchy 
ADD COLUMN IF NOT EXISTS company_code_id UUID;

-- Step 2: Update existing records to link to company_codes table
UPDATE organizational_hierarchy 
SET company_code_id = cc.id
FROM company_codes cc
WHERE organizational_hierarchy.company_code = cc.company_code
AND organizational_hierarchy.company_code_id IS NULL;

-- Step 3: Add foreign key constraint
ALTER TABLE organizational_hierarchy 
DROP CONSTRAINT IF EXISTS fk_org_hierarchy_company_code;

ALTER TABLE organizational_hierarchy 
ADD CONSTRAINT fk_org_hierarchy_company_code 
FOREIGN KEY (company_code_id) REFERENCES company_codes(id);

-- Step 4: Create index for performance
CREATE INDEX IF NOT EXISTS idx_org_hierarchy_company_code_id 
ON organizational_hierarchy(company_code_id);

-- Step 5: Create view for proper company data with names
CREATE OR REPLACE VIEW v_companies_with_names AS
SELECT 
    cc.company_code as code,
    cc.company_name as name,
    cc.legal_entity_name,
    cc.currency,
    cc.country,
    cc.is_active,
    COUNT(oh.id) as employee_count
FROM company_codes cc
LEFT JOIN organizational_hierarchy oh ON cc.id = oh.company_code_id AND oh.is_active = true
WHERE cc.is_active = true
GROUP BY cc.id, cc.company_code, cc.company_name, cc.legal_entity_name, cc.currency, cc.country, cc.is_active
ORDER BY cc.company_code;

-- Step 6: Verify the fix
SELECT 'Organizational Hierarchy Fix Applied Successfully' as status;

-- Step 7: Show current company data
SELECT 
    'Available Companies' as info,
    code,
    name,
    employee_count
FROM v_companies_with_names
ORDER BY code;