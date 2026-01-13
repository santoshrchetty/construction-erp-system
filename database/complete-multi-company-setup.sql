-- Complete Multi-Company Setup for All Existing Company Codes
-- Groups: ABC Group (C001-C004), Bramen Group (B001), Construction Corp (1000), Nascar (N001)

-- Step 1: Add company_id column
ALTER TABLE company_codes ADD COLUMN IF NOT EXISTS company_id UUID;

-- Step 2: Create companies table
CREATE TABLE IF NOT EXISTS companies (
    company_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(200) NOT NULL,
    industry VARCHAR(50),
    country VARCHAR(2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Step 3: Insert all parent companies
INSERT INTO companies (company_name, industry, country) 
VALUES 
('ABC Group', 'CONSTRUCTION', 'IN'),           -- C001, C002, C003, C004
('Bramen Group', 'CONSTRUCTION', 'IN'),        -- B001
('Construction Corp Group', 'CONSTRUCTION', 'IN'), -- 1000
('Nascar Group', 'CONSTRUCTION', 'IN')         -- N001
ON CONFLICT DO NOTHING;

-- Step 4: Link all company codes to their parent companies
-- ABC Group (C001, C002, C003, C004)
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'ABC Group')
WHERE company_code IN ('C001', 'C002', 'C003', 'C004') AND company_id IS NULL;

-- Bramen Group (B001)
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'Bramen Group')
WHERE company_code = 'B001' AND company_id IS NULL;

-- Construction Corp Group (1000)
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'Construction Corp Group')
WHERE company_code = '1000' AND company_id IS NULL;

-- Nascar Group (N001)
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE company_name = 'Nascar Group')
WHERE company_code = 'N001' AND company_id IS NULL;

-- Step 5: Add company_code to master data tables
ALTER TABLE project_categories ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';

DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_gl_determination') THEN
        ALTER TABLE project_gl_determination ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_types') THEN
        ALTER TABLE project_types ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';
    END IF;
END $$;

-- Step 6: Create copy function for master data within same parent company
CREATE OR REPLACE FUNCTION copy_project_master_data(
    source_company_code VARCHAR(10),
    target_company_code VARCHAR(10)
) RETURNS TEXT AS $$
DECLARE
    source_company_id UUID;
    target_company_id UUID;
    result_msg TEXT := '';
    rec_count INTEGER;
BEGIN
    -- Get parent company IDs
    SELECT company_id INTO source_company_id FROM company_codes WHERE company_code = source_company_code;
    SELECT company_id INTO target_company_id FROM company_codes WHERE company_code = target_company_code;
    
    -- Only allow copying within same parent company
    IF source_company_id != target_company_id THEN
        RAISE EXCEPTION 'Cannot copy master data between different parent companies (% vs %)', 
            source_company_code, target_company_code;
    END IF;
    
    -- Copy project categories
    INSERT INTO project_categories (
        company_code, category_code, category_name, 
        settlement_type, financial_impact, revenue_recognition,
        capitalization_flag, profitability_tracking, 
        gl_account_range, description, is_active
    )
    SELECT 
        target_company_code, category_code, category_name,
        settlement_type, financial_impact, revenue_recognition,
        capitalization_flag, profitability_tracking,
        gl_account_range, description, is_active
    FROM project_categories 
    WHERE company_code = source_company_code
    ON CONFLICT (company_code, category_code) DO NOTHING;
    
    GET DIAGNOSTICS rec_count = ROW_COUNT;
    result_msg := 'Categories copied: ' || rec_count;
    
    RETURN result_msg;
END;
$$ LANGUAGE plpgsql;

-- Step 7: Verify the complete setup
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
ORDER BY c.company_name, cc.company_code;

-- Step 8: Show grouping summary
SELECT 
    c.company_name as parent_company,
    COUNT(*) as company_codes_count,
    STRING_AGG(cc.company_code, ', ' ORDER BY cc.company_code) as company_codes
FROM companies c
JOIN company_codes cc ON c.company_id = cc.company_id
WHERE cc.is_active = true
GROUP BY c.company_name
ORDER BY c.company_name;