-- Check Actual Schema and Handle Required Columns
-- This will show us exactly what columns exist and their constraints

-- Step 1: Check the actual company_codes table structure
SELECT 
    column_name, 
    data_type, 
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'company_codes' 
ORDER BY ordinal_position;

-- Step 2: Check existing data to understand the structure
SELECT * FROM company_codes LIMIT 3;

-- Step 3: Add company_id column safely
ALTER TABLE company_codes ADD COLUMN IF NOT EXISTS company_id UUID;

-- Step 4: Create companies table
CREATE TABLE IF NOT EXISTS companies (
    company_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(200) NOT NULL,
    industry VARCHAR(50),
    country VARCHAR(2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Step 5: Insert companies
INSERT INTO companies (company_name, industry, country) 
VALUES 
('ABC Construction Group', 'CONSTRUCTION', 'US'),
('XYZ Engineering Corp', 'ENGINEERING', 'CA')
ON CONFLICT DO NOTHING;

-- Step 6: Insert company codes with ALL required columns
-- Based on the error, we need to include legal_entity_name
INSERT INTO company_codes (
    company_code, 
    company_name, 
    legal_entity_name,  -- This was missing!
    country, 
    currency
) 
VALUES 
('C001', 'ABC Construction USA', 'ABC Construction USA LLC', 'US', 'USD'),
('C002', 'ABC Construction Canada', 'ABC Construction Canada Inc', 'CA', 'CAD'),
('C003', 'ABC Construction Mexico', 'ABC Construction Mexico SA', 'MX', 'MXN')
ON CONFLICT (company_code) DO NOTHING;

-- Step 7: Update company_id relationships
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'ABC Construction Group')
WHERE company_code IN ('C001', 'C002', 'C003') AND company_id IS NULL;