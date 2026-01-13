-- Multi-Tenant Project Master Data Schema Fix
-- Add company_code to make categories, types, and GL rules customer-specific

-- 1. Add company_code to project_categories
ALTER TABLE project_categories 
ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';

-- Update primary key to include company_code
ALTER TABLE project_categories DROP CONSTRAINT IF EXISTS project_categories_pkey;
ALTER TABLE project_categories ADD CONSTRAINT project_categories_pkey 
PRIMARY KEY (company_code, category_code);

-- 2. Add company_code to project_types (if exists)
ALTER TABLE project_types 
ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';

ALTER TABLE project_types DROP CONSTRAINT IF EXISTS project_types_pkey;
ALTER TABLE project_types ADD CONSTRAINT project_types_pkey 
PRIMARY KEY (company_code, type_code);

-- 3. Add company_code to project_gl_determination
ALTER TABLE project_gl_determination 
ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';

ALTER TABLE project_gl_determination DROP CONSTRAINT IF EXISTS project_gl_determination_pkey;
ALTER TABLE project_gl_determination ADD CONSTRAINT project_gl_determination_pkey 
PRIMARY KEY (company_code, project_category, event_type, gl_account_type);

-- 4. Add company_code to construction_types
ALTER TABLE construction_types 
ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';

ALTER TABLE construction_types DROP CONSTRAINT IF EXISTS construction_types_pkey;
ALTER TABLE construction_types ADD CONSTRAINT construction_types_pkey 
PRIMARY KEY (company_code, type_code);

-- 5. Add company_code to project_sectors
ALTER TABLE project_sectors 
ADD COLUMN IF NOT EXISTS company_code VARCHAR(10) DEFAULT 'C001';

ALTER TABLE project_sectors DROP CONSTRAINT IF EXISTS project_sectors_pkey;
ALTER TABLE project_sectors ADD CONSTRAINT project_sectors_pkey 
PRIMARY KEY (company_code, sector_code);

-- 6. Create template/seed data copy function
CREATE OR REPLACE FUNCTION copy_project_master_data(
    source_company VARCHAR(10),
    target_company VARCHAR(10)
) RETURNS VOID AS $$
BEGIN
    -- Copy categories
    INSERT INTO project_categories (
        company_code, category_code, category_name, settlement_type,
        financial_impact, revenue_recognition, capitalization_flag,
        profitability_tracking, gl_account_range, description, is_active
    )
    SELECT 
        target_company, category_code, category_name, settlement_type,
        financial_impact, revenue_recognition, capitalization_flag,
        profitability_tracking, gl_account_range, description, is_active
    FROM project_categories 
    WHERE company_code = source_company
    ON CONFLICT (company_code, category_code) DO NOTHING;

    -- Copy types
    INSERT INTO project_types (
        company_code, type_code, type_name, category_code, description, is_active
    )
    SELECT 
        target_company, type_code, type_name, category_code, description, is_active
    FROM project_types 
    WHERE company_code = source_company
    ON CONFLICT (company_code, type_code) DO NOTHING;

    -- Copy GL determination rules
    INSERT INTO project_gl_determination (
        company_code, project_category, event_type, gl_account_type,
        debit_credit, posting_key, gl_account_range, description, is_active
    )
    SELECT 
        target_company, project_category, event_type, gl_account_type,
        debit_credit, posting_key, gl_account_range, description, is_active
    FROM project_gl_determination 
    WHERE company_code = source_company
    ON CONFLICT (company_code, project_category, event_type, gl_account_type) DO NOTHING;

    -- Copy construction types
    INSERT INTO construction_types (
        company_code, type_code, type_name, description, is_active
    )
    SELECT 
        target_company, type_code, type_name, description, is_active
    FROM construction_types 
    WHERE company_code = source_company
    ON CONFLICT (company_code, type_code) DO NOTHING;

    -- Copy sectors
    INSERT INTO project_sectors (
        company_code, sector_code, sector_name, description, is_active
    )
    SELECT 
        target_company, sector_code, sector_name, description, is_active
    FROM project_sectors 
    WHERE company_code = source_company
    ON CONFLICT (company_code, sector_code) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- 7. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_project_categories_company ON project_categories(company_code);
CREATE INDEX IF NOT EXISTS idx_project_types_company ON project_types(company_code);
CREATE INDEX IF NOT EXISTS idx_project_gl_determination_company ON project_gl_determination(company_code);
CREATE INDEX IF NOT EXISTS idx_construction_types_company ON construction_types(company_code);
CREATE INDEX IF NOT EXISTS idx_project_sectors_company ON project_sectors(company_code);

-- 8. Example: Copy C001 template data to new company B001
-- SELECT copy_project_master_data('C001', 'B001');