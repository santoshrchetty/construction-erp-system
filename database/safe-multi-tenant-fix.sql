-- Step 2: Multi-Tenant Master Data Schema Fix (Simplified)
-- Run this after fixing company_codes table

-- 1. Add company_code to project_categories (if not exists)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'project_categories' AND column_name = 'company_code') THEN
        ALTER TABLE project_categories ADD COLUMN company_code VARCHAR(10) DEFAULT 'C001';
    END IF;
END $$;

-- 2. Add company_code to project_types (if table exists)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_types') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'project_types' AND column_name = 'company_code') THEN
            ALTER TABLE project_types ADD COLUMN company_code VARCHAR(10) DEFAULT 'C001';
        END IF;
    END IF;
END $$;

-- 3. Add company_code to project_gl_determination (if table exists)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_gl_determination') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'project_gl_determination' AND column_name = 'company_code') THEN
            ALTER TABLE project_gl_determination ADD COLUMN company_code VARCHAR(10) DEFAULT 'C001';
        END IF;
    END IF;
END $$;

-- 4. Create basic copy function
CREATE OR REPLACE FUNCTION copy_project_master_data(
    source_company_code VARCHAR(10),
    target_company_code VARCHAR(10)
) RETURNS TEXT AS $$
DECLARE
    result_msg TEXT := '';
    rec_count INTEGER;
BEGIN
    -- Copy categories if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_categories') THEN
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
        result_msg := result_msg || 'Categories copied: ' || rec_count || '; ';
    END IF;
    
    -- Copy GL rules if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_gl_determination') THEN
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
        result_msg := result_msg || 'GL rules copied: ' || rec_count || '; ';
    END IF;
    
    -- Copy types if table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_types') THEN
        INSERT INTO project_types (
            company_code, type_code, type_name, category_code, description, is_active
        )
        SELECT 
            target_company_code, type_code, type_name, category_code, description, is_active
        FROM project_types 
        WHERE company_code = source_company_code
        ON CONFLICT (company_code, type_code) DO NOTHING;
        
        GET DIAGNOSTICS rec_count = ROW_COUNT;
        result_msg := result_msg || 'Types copied: ' || rec_count;
    END IF;
    
    RETURN result_msg;
END;
$$ LANGUAGE plpgsql;

-- 5. Create indexes (safe to run multiple times)
CREATE INDEX IF NOT EXISTS idx_project_categories_company ON project_categories(company_code);
CREATE INDEX IF NOT EXISTS idx_project_types_company ON project_types(company_code) WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_types');
CREATE INDEX IF NOT EXISTS idx_project_gl_determination_company ON project_gl_determination(company_code) WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_gl_determination');