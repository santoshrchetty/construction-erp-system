-- Fixed Multi-Company Setup - Handles Duplicate Company Names
-- Step by step approach to avoid subquery errors

-- Step 1: Add company_id column
ALTER TABLE company_codes ADD COLUMN IF NOT EXISTS company_id UUID;

-- Step 2: Create companies table with unique constraint
CREATE TABLE IF NOT EXISTS companies (
    company_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(200) UNIQUE NOT NULL,
    industry VARCHAR(50),
    country VARCHAR(2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Step 3: Clean up any duplicate companies first
DELETE FROM companies WHERE company_name IN ('ABC Group', 'Bramen Group', 'Construction Corp Group', 'Nascar Group');

-- Step 4: Insert parent companies (one at a time to avoid conflicts)
INSERT INTO companies (company_name, industry, country) VALUES ('ABC Group', 'CONSTRUCTION', 'IN');
INSERT INTO companies (company_name, industry, country) VALUES ('Bramen Group', 'CONSTRUCTION', 'IN');
INSERT INTO companies (company_name, industry, country) VALUES ('Construction Corp Group', 'CONSTRUCTION', 'IN');
INSERT INTO companies (company_name, industry, country) VALUES ('Nascar Group', 'CONSTRUCTION', 'IN');

-- Step 5: Link company codes one by one to avoid subquery errors
-- ABC Group
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'ABC Group' LIMIT 1)
WHERE company_code = 'C001' AND company_id IS NULL;

UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'ABC Group' LIMIT 1)
WHERE company_code = 'C002' AND company_id IS NULL;

UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'ABC Group' LIMIT 1)
WHERE company_code = 'C003' AND company_id IS NULL;

UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'ABC Group' LIMIT 1)
WHERE company_code = 'C004' AND company_id IS NULL;

-- Bramen Group
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'Bramen Group' LIMIT 1)
WHERE company_code = 'B001' AND company_id IS NULL;

-- Construction Corp Group
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'Construction Corp Group' LIMIT 1)
WHERE company_code = '1000' AND company_id IS NULL;

-- Nascar Group
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'Nascar Group' LIMIT 1)
WHERE company_code = 'N001' AND company_id IS NULL;

-- Step 6: Add company_code to master data tables
ALTER TABLE project_categories ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';

-- Step 7: Verify the setup
SELECT 
    cc.company_code,
    cc.company_name,
    c.company_name as parent_company
FROM company_codes cc
LEFT JOIN companies c ON cc.company_id = c.company_id
WHERE cc.is_active = true
ORDER BY c.company_name, cc.company_code;