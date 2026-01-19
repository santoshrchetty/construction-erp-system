-- Multi-Company Setup Based on Existing Data
-- You have: C001 (ABC Construction Ltd), C002 (ABC Infrastructure), B001 (Bramen Ltd)

-- Step 1: Add company_id column to existing company_codes table
ALTER TABLE company_codes ADD COLUMN IF NOT EXISTS company_id UUID;

-- Step 2: Create companies table (parent companies)
CREATE TABLE IF NOT EXISTS companies (
    company_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    grpcompany_name VARCHAR(200) NOT NULL,
    industry VARCHAR(50),
    country VARCHAR(2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Step 3: Insert parent companies based on your existing data
INSERT INTO companies (grpcompany_name, industry, country) 
VALUES 
('ABC Group', 'CONSTRUCTION', 'IN'),  -- Parent for C001, C002
('Bramen Group', 'CONSTRUCTION', 'IN') -- Parent for B001
ON CONFLICT DO NOTHING;

-- Step 4: Link existing company codes to parent companies
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE grpcompany_name = 'ABC Group')
WHERE company_code IN ('C001', 'C002') AND company_id IS NULL;

UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE grpcompany_name = 'Bramen Group')
WHERE company_code = 'B001' AND company_id IS NULL;

-- Step 5: Add company_code to project master data tables
ALTER TABLE project_categories ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';
ALTER TABLE project_gl_determination ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';

-- Step 6: Create copy function for master data within same company
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
    result_msg := 'Categories copied: ' || rec_count || '; ';
    
    -- Copy GL determination rules
    INSERT INTO project_gl_determination (
        company_code, project_category, event_type, gl_account_type,
        debit_credit, posting_key, gl_account_range, description, is_active
    )
    SELECT 
        target_company_code, project_category, event_type, gl_account_type,
        debit_credit, posting_key, gl_account_range, description, is_active
    FROM project_gl_determination 
    WHERE company_code = source_company_code
    ON CONFLICT (company_code, project_category, event_type, gl_account_type) DO NOTHING;
    
    GET DIAGNOSTICS rec_count = ROW_COUNT;
    result_msg := result_msg || 'GL rules copied: ' || rec_count;
    
    RETURN result_msg;
END;
$$ LANGUAGE plpgsql;

-- Step 7: Test the setup
SELECT 
    cc.company_code,
    cc.company_name,
    cc.legal_entity_name,
    c.grpcompany_name as parent_company,
    cc.currency,
    cc.country
FROM company_codes cc
LEFT JOIN companies c ON cc.company_id = c.company_id
WHERE cc.is_active = true
ORDER BY cc.company_code;

-- Step 8: Example usage - Copy master data within ABC Group
-- SELECT copy_project_master_data('C001', 'C002');