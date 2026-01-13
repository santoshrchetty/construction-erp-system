-- Minimal Multi-Company Setup for Existing Company Codes
-- Only add what's needed, don't insert new company codes

-- Step 1: Add company_id column to existing company_codes table
ALTER TABLE company_codes ADD COLUMN IF NOT EXISTS company_id UUID;

-- Step 2: Create parent companies table
CREATE TABLE IF NOT EXISTS companies (
    company_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(200) NOT NULL,
    industry VARCHAR(50),
    country VARCHAR(2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Step 3: Insert parent companies based on existing data
INSERT INTO companies (company_name, industry, country) 
VALUES 
('ABC Group', 'CONSTRUCTION', 'IN'),  -- Parent for C001, C002
('Bramen Group', 'CONSTRUCTION', 'IN') -- Parent for B001
ON CONFLICT DO NOTHING;

-- Step 4: Link existing company codes to parent companies
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'ABC Group')
WHERE company_code IN ('C001', 'C002') AND company_id IS NULL;

UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'Bramen Group')
WHERE company_code = 'B001' AND company_id IS NULL;

-- Step 5: Add company_code to master data tables
ALTER TABLE project_categories ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';

DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_gl_determination') THEN
        ALTER TABLE project_gl_determination ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';
    END IF;
END $$;

-- Step 6: Verify the setup
SELECT 
    cc.company_code,
    cc.company_name,
    cc.legal_entity_name,
    c.company_name as parent_company,
    cc.currency,
    cc.country
FROM company_codes cc
LEFT JOIN companies c ON cc.company_id = c.company_id
WHERE cc.is_active = true
ORDER BY cc.company_code;