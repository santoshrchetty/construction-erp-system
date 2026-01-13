-- Simple Approach - Work with Existing Constraints
-- Don't alter existing columns, just add what we need

-- Step 1: Check existing schema
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'company_codes';

-- Step 2: Add company_id column (this should work)
ALTER TABLE company_codes ADD COLUMN IF NOT EXISTS company_id UUID;

-- Step 3: Create companies table
CREATE TABLE IF NOT EXISTS companies (
    company_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(200) NOT NULL,
    industry VARCHAR(50),
    country VARCHAR(2), -- Match existing constraint
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Step 4: Insert companies with 2-character country codes
INSERT INTO companies (company_name, industry, country) 
VALUES 
('ABC Construction Group', 'CONSTRUCTION', 'US'),
('XYZ Engineering Corp', 'ENGINEERING', 'CA')
ON CONFLICT DO NOTHING;

-- Step 5: Insert company codes with existing column constraints
INSERT INTO company_codes (company_code, company_name, country, currency) 
VALUES 
('C001', 'ABC Construction USA', 'US', 'USD'),
('C002', 'ABC Construction Canada', 'CA', 'CAD'),
('C003', 'ABC Construction Mexico', 'MX', 'MXN')
ON CONFLICT (company_code) DO NOTHING;

-- Step 6: Link existing company codes to companies
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'ABC Construction Group')
WHERE company_code IN ('C001', 'C002', 'C003') AND company_id IS NULL;

-- Step 7: Verify the setup
SELECT 
    cc.company_code,
    cc.company_name,
    cc.country,
    c.company_name as parent_company
FROM company_codes cc
LEFT JOIN companies c ON cc.company_id = c.company_id;