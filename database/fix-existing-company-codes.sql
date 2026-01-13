-- Step 1: Check existing company_codes table structure and fix
-- Run this first to understand current schema

-- Check existing table structure
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'company_codes' 
ORDER BY ordinal_position;

-- Fix column sizes if they're too small
ALTER TABLE company_codes 
ALTER COLUMN country TYPE VARCHAR(10);

ALTER TABLE company_codes 
ALTER COLUMN currency TYPE VARCHAR(3);

-- If company_codes exists but missing company_id, add it
ALTER TABLE company_codes 
ADD COLUMN IF NOT EXISTS company_id UUID;

-- Create companies table if it doesn't exist
CREATE TABLE IF NOT EXISTS companies (
    company_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(200) NOT NULL,
    industry VARCHAR(50),
    country VARCHAR(10),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample companies
INSERT INTO companies (company_name, industry, country) 
VALUES 
('ABC Construction Group', 'CONSTRUCTION', 'US'),
('XYZ Engineering Corp', 'ENGINEERING', 'CA')
ON CONFLICT DO NOTHING;

-- Update existing company_codes to link to companies
-- Assuming C001, C002, C003 belong to ABC Construction Group
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'ABC Construction Group')
WHERE company_code IN ('C001', 'C002', 'C003');

-- Assuming E001, E002 belong to XYZ Engineering Corp  
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'XYZ Engineering Corp')
WHERE company_code IN ('E001', 'E002');

-- If no existing company codes, insert them with ALL required columns
INSERT INTO company_codes (
    company_id, 
    company_code, 
    company_name, 
    legal_entity_name,
    country, 
    currency
) 
SELECT 
    c.company_id,
    cc.code,
    cc.name,
    cc.legal_name,
    cc.country,
    cc.currency
FROM companies c
CROSS JOIN (VALUES 
    ('C001', 'ABC Construction USA', 'ABC Construction USA LLC', 'US', 'USD'),
    ('C002', 'ABC Construction Canada', 'ABC Construction Canada Inc', 'CA', 'CAD'),
    ('C003', 'ABC Construction Mexico', 'ABC Construction Mexico SA', 'MX', 'MXN')
) cc(code, name, legal_name, country, currency)
WHERE c.company_name = 'ABC Construction Group'
  AND NOT EXISTS (SELECT 1 FROM company_codes WHERE company_code = cc.code)

UNION ALL

SELECT 
    c.company_id,
    cc.code,
    cc.name,
    cc.legal_name,
    cc.country,
    cc.currency
FROM companies c
CROSS JOIN (VALUES 
    ('E001', 'XYZ Engineering USA', 'XYZ Engineering USA Corp', 'US', 'USD'),
    ('E002', 'XYZ Engineering Europe', 'XYZ Engineering Europe Ltd', 'EU', 'EUR')
) cc(code, name, legal_name, country, currency)
WHERE c.company_name = 'XYZ Engineering Corp'
  AND NOT EXISTS (SELECT 1 FROM company_codes WHERE company_code = cc.code);

-- Add foreign key constraint if not exists
ALTER TABLE company_codes 
ADD CONSTRAINT fk_company_codes_company_id 
FOREIGN KEY (company_id) REFERENCES companies(company_id);