-- Consolidate ABC Companies Under One Parent Group
-- Fix: C001-C003 under "ABC Construction Group" and C004 under "ABC Group"

-- Step 1: Move C004 to ABC Construction Group to consolidate all ABC companies
UPDATE company_codes 
SET company_id = (SELECT company_id FROM companies WHERE grpcompany_name = 'ABC Construction Group' LIMIT 1)
WHERE company_code = 'C004';

-- Step 2: Remove the unused "ABC Group" parent company
DELETE FROM companies WHERE grpcompany_name = 'ABC Group';

-- Step 3: Add company_code to all master data tables
ALTER TABLE project_categories ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';

DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_gl_determination') THEN
        ALTER TABLE project_gl_determination ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_types') THEN
        ALTER TABLE project_types ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'construction_types') THEN
        ALTER TABLE construction_types ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_sectors') THEN
        ALTER TABLE project_sectors ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';
    END IF;
END $$;

-- Step 4: Create copy function for master data within same parent company
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

-- Step 5: Final verification - should show consolidated structure
SELECT 
    c.grpcompany_name as parent_company,
    COUNT(*) as company_codes_count,
    STRING_AGG(cc.company_code, ', ' ORDER BY cc.company_code) as company_codes
FROM companies c
JOIN company_codes cc ON c.company_id = cc.company_id
WHERE cc.is_active = true
GROUP BY c.grpcompany_name
ORDER BY c.grpcompany_name;

-- Step 6: Test copy function within ABC Construction Group
-- SELECT copy_project_master_data('C001', 'C002');