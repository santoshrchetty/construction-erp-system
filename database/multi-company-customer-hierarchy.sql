-- Multi-Company Code Architecture
-- One company can have multiple company codes

-- 1. Create companies master table
CREATE TABLE IF NOT EXISTS companies (
    company_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(200) NOT NULL,
    industry VARCHAR(50),
    country VARCHAR(10),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 2. Create company codes table with company relationship
CREATE TABLE IF NOT EXISTS company_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(company_id),
    company_code VARCHAR(10) UNIQUE NOT NULL,
    company_name VARCHAR(200) NOT NULL,
    country VARCHAR(10),
    currency VARCHAR(3) DEFAULT 'USD',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3. Insert sample company with multiple company codes
INSERT INTO companies (company_name, industry, country) VALUES
('ABC Construction Group', 'CONSTRUCTION', 'USA'),
('XYZ Engineering Corp', 'ENGINEERING', 'CAN');

INSERT INTO company_codes (company_id, company_code, company_name, country, currency) VALUES
-- ABC Construction Group company codes
((SELECT company_id FROM companies WHERE company_name = 'ABC Construction Group'), 'C001', 'ABC Construction USA', 'USA', 'USD'),
((SELECT company_id FROM companies WHERE company_name = 'ABC Construction Group'), 'C002', 'ABC Construction Canada', 'CAN', 'CAD'),
((SELECT company_id FROM companies WHERE company_name = 'ABC Construction Group'), 'C003', 'ABC Construction Mexico', 'MEX', 'MXN'),
-- XYZ Engineering Corp company codes
((SELECT company_id FROM companies WHERE company_name = 'XYZ Engineering Corp'), 'E001', 'XYZ Engineering USA', 'USA', 'USD'),
((SELECT company_id FROM companies WHERE company_name = 'XYZ Engineering Corp'), 'E002', 'XYZ Engineering Europe', 'EUR', 'EUR');

-- 4. Create company-level master data sharing function
CREATE OR REPLACE FUNCTION copy_master_data_within_company(
    source_company_code VARCHAR(10),
    target_company_code VARCHAR(10)
) RETURNS VOID AS $$
DECLARE
    source_company_id UUID;
    target_company_id UUID;
BEGIN
    -- Get company IDs
    SELECT company_id INTO source_company_id FROM company_codes WHERE company_code = source_company_code;
    SELECT company_id INTO target_company_id FROM company_codes WHERE company_code = target_company_code;
    
    -- Only allow copying within same company
    IF source_company_id != target_company_id THEN
        RAISE EXCEPTION 'Cannot copy master data between different companies';
    END IF;
    
    -- Copy categories
    INSERT INTO project_categories (
        company_code, category_code, category_name, settlement_type,
        financial_impact, revenue_recognition, capitalization_flag,
        profitability_tracking, gl_account_range, description, is_active
    )
    SELECT 
        target_company_code, category_code, category_name, settlement_type,
        financial_impact, revenue_recognition, capitalization_flag,
        profitability_tracking, gl_account_range, description, is_active
    FROM project_categories 
    WHERE company_code = source_company_code
    ON CONFLICT (company_code, category_code) DO NOTHING;

    -- Copy GL rules
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
    
    -- Copy types
    INSERT INTO project_types (
        company_code, type_code, type_name, category_code, description, is_active
    )
    SELECT 
        target_company_code, type_code, type_name, category_code, description, is_active
    FROM project_types 
    WHERE company_code = source_company_code
    ON CONFLICT (company_code, type_code) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- 5. Create company-level template setup function
CREATE OR REPLACE FUNCTION setup_new_company_code_from_template(
    company_name_param VARCHAR(200),
    new_company_code VARCHAR(10),
    new_company_code_name VARCHAR(200),
    template_company_code VARCHAR(10) DEFAULT 'C001'
) RETURNS VOID AS $$
DECLARE
    company_uuid UUID;
BEGIN
    -- Get company ID
    SELECT company_id INTO company_uuid FROM companies WHERE company_name = company_name_param;
    
    IF company_uuid IS NULL THEN
        RAISE EXCEPTION 'Company % not found', company_name_param;
    END IF;
    
    -- Create new company code
    INSERT INTO company_codes (company_id, company_code, company_name, is_active)
    VALUES (company_uuid, new_company_code, new_company_code_name, true);
    
    -- Copy master data from template
    PERFORM copy_project_master_data(template_company_code, new_company_code);
END;
$$ LANGUAGE plpgsql;

-- 6. Create indexes
CREATE INDEX IF NOT EXISTS idx_company_codes_customer ON company_codes(customer_id);
CREATE INDEX IF NOT EXISTS idx_company_codes_active ON company_codes(is_active);

-- 7. Example usage:
-- Setup new company code for existing company
-- SELECT setup_new_company_code_from_template('ABC Construction Group', 'C004', 'ABC Construction Brazil', 'C001');

-- Copy master data between company codes within same company
-- SELECT copy_master_data_within_company('C001', 'C002');