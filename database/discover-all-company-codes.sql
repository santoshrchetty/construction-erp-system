-- Discover All Existing Company Codes
-- This will show us all company codes to group them properly

-- Step 1: Show all existing company codes
SELECT 
    company_code,
    company_name,
    legal_entity_name,
    country,
    currency,
    is_active
FROM company_codes 
ORDER BY company_code;

-- Step 2: Add company_id column
ALTER TABLE company_codes ADD COLUMN IF NOT EXISTS company_id UUID;

-- Step 3: Create companies table
CREATE TABLE IF NOT EXISTS companies (
    company_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    grpcompany_name VARCHAR(200) NOT NULL,
    industry VARCHAR(50),
    country VARCHAR(2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Step 4: Insert parent companies (we'll add more based on what we see)
INSERT INTO companies (grpcompany_name, industry, country) 
VALUES 
('ABC Group', 'CONSTRUCTION', 'IN'),
('Bramen Group', 'CONSTRUCTION', 'IN')
ON CONFLICT DO NOTHING;

-- Step 5: Link known company codes to parent companies
-- ABC Group (C001, C002)
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE grpcompany_name = 'ABC Group')
WHERE company_code LIKE 'C%' AND company_id IS NULL;

-- Bramen Group (B001)
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE grpcompany_name = 'Bramen Group')
WHERE company_code LIKE 'B%' AND company_id IS NULL;

-- Step 6: Show the result to see what other company codes need grouping
SELECT 
    cc.company_code,
    cc.company_name,
    cc.legal_entity_name,
    c.grpcompany_name as parent_company,
    CASE WHEN cc.company_id IS NULL THEN 'NEEDS GROUPING' ELSE 'GROUPED' END as status
FROM company_codes cc
LEFT JOIN companies c ON cc.company_id = c.company_id
WHERE cc.is_active = true
ORDER BY cc.company_code;