-- Minimal Fix for Company Codes Schema
-- Run this step by step

-- Step 1: Check current schema
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'company_codes';

-- Step 2: Fix column sizes (run only if columns exist and are too small)
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

-- Step 3: Add company_id if missing
ALTER TABLE company_codes ADD COLUMN IF NOT EXISTS company_id UUID;

-- Step 4: Create companies table
CREATE TABLE IF NOT EXISTS companies (
    company_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(200) NOT NULL,
    industry VARCHAR(50),
    country VARCHAR(10),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Step 5: Insert companies
INSERT INTO companies (company_name, industry, country) 
VALUES 
('ABC Construction Group', 'CONSTRUCTION', 'US'),
('XYZ Engineering Corp', 'ENGINEERING', 'CA')
ON CONFLICT DO NOTHING;

-- Step 6: Test insert with minimal data
INSERT INTO company_codes (company_code, company_name, country, currency) 
VALUES ('C001', 'ABC Construction USA', 'US', 'USD')
ON CONFLICT (company_code) DO NOTHING;