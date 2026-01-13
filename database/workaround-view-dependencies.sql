-- Workaround for View Dependencies
-- Handle existing views that prevent column alterations

-- Step 1: Check what views depend on company_codes
SELECT 
    schemaname,
    viewname,
    definition
FROM pg_views 
WHERE definition LIKE '%company_codes%';

-- Step 2: Drop dependent view temporarily (if it exists)
DROP VIEW IF EXISTS v_companies_with_names CASCADE;

-- Step 3: Now we can alter the columns
DO $$ 
BEGIN
    -- Fix country column if it exists and is too small
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'company_codes' AND column_name = 'country' 
               AND character_maximum_length < 10) THEN
        ALTER TABLE company_codes ALTER COLUMN country TYPE VARCHAR(10);
    END IF;
    
    -- Fix currency column if it exists and is too small  
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'company_codes' AND column_name = 'currency' 
               AND character_maximum_length < 3) THEN
        ALTER TABLE company_codes ALTER COLUMN currency TYPE VARCHAR(3);
    END IF;
END $$;

-- Step 4: Add company_id if missing
ALTER TABLE company_codes ADD COLUMN IF NOT EXISTS company_id UUID;

-- Step 5: Create companies table
CREATE TABLE IF NOT EXISTS companies (
    company_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(200) NOT NULL,
    industry VARCHAR(50),
    country VARCHAR(10),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Step 6: Insert companies with 2-character country codes (to fit existing constraint)
INSERT INTO companies (company_name, industry, country) 
VALUES 
('ABC Construction Group', 'CONSTRUCTION', 'US'),
('XYZ Engineering Corp', 'ENGINEERING', 'CA')
ON CONFLICT DO NOTHING;

-- Step 7: Insert company codes with 2-character country codes
INSERT INTO company_codes (company_code, company_name, country, currency) 
VALUES 
('C001', 'ABC Construction USA', 'US', 'USD'),
('C002', 'ABC Construction Canada', 'CA', 'CAD'),
('C003', 'ABC Construction Mexico', 'MX', 'MXN'),
('E001', 'XYZ Engineering USA', 'US', 'USD'),
('E002', 'XYZ Engineering Europe', 'EU', 'EUR')
ON CONFLICT (company_code) DO NOTHING;

-- Step 8: Update company_id relationships
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'ABC Construction Group')
WHERE company_code IN ('C001', 'C002', 'C003');

UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'XYZ Engineering Corp')
WHERE company_code IN ('E001', 'E002');

-- Step 9: Recreate the view if needed (basic version)
CREATE OR REPLACE VIEW v_companies_with_names AS
SELECT 
    cc.company_code,
    cc.company_name,
    cc.country,
    cc.currency,
    c.company_name as parent_company_name
FROM company_codes cc
LEFT JOIN companies c ON cc.company_id = c.company_id
WHERE cc.is_active = true;