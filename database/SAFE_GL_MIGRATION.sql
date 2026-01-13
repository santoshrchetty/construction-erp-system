-- Safe GL Posting Master Data Migration
-- Adds missing columns to existing tables without data loss

-- Check and create cost_centers table or add missing columns
DO $$
BEGIN
    -- Create table if it doesn't exist
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'cost_centers') THEN
        CREATE TABLE cost_centers (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            company_code VARCHAR(4) NOT NULL,
            cost_center_code VARCHAR(10) NOT NULL,
            cost_center_name VARCHAR(100) NOT NULL,
            cost_center_type VARCHAR(20) DEFAULT 'STANDARD',
            responsible_person VARCHAR(100),
            profit_center_code VARCHAR(10),
            is_active BOOLEAN DEFAULT true,
            valid_from DATE DEFAULT CURRENT_DATE,
            valid_to DATE DEFAULT '9999-12-31',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            UNIQUE(company_code, cost_center_code)
        );
    ELSE
        -- Add missing columns if table exists
        IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'cost_centers' AND column_name = 'company_code') THEN
            ALTER TABLE cost_centers ADD COLUMN company_code VARCHAR(4) DEFAULT 'C001';
        END IF;
        IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'cost_centers' AND column_name = 'profit_center_code') THEN
            ALTER TABLE cost_centers ADD COLUMN profit_center_code VARCHAR(10);
        END IF;
        IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'cost_centers' AND column_name = 'valid_from') THEN
            ALTER TABLE cost_centers ADD COLUMN valid_from DATE DEFAULT CURRENT_DATE;
        END IF;
        IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'cost_centers' AND column_name = 'valid_to') THEN
            ALTER TABLE cost_centers ADD COLUMN valid_to DATE DEFAULT '9999-12-31';
        END IF;
    END IF;
END
$$;

-- Create profit_centers table
CREATE TABLE IF NOT EXISTS profit_centers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_code VARCHAR(4) NOT NULL,
    profit_center_code VARCHAR(10) NOT NULL,
    profit_center_name VARCHAR(100) NOT NULL,
    profit_center_type VARCHAR(20) DEFAULT 'STANDARD',
    responsible_person VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE DEFAULT '9999-12-31',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(company_code, profit_center_code)
);

-- Create wbs_elements table
CREATE TABLE IF NOT EXISTS wbs_elements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_code VARCHAR(4) NOT NULL,
    project_code VARCHAR(20) NOT NULL,
    wbs_element VARCHAR(24) NOT NULL,
    wbs_description VARCHAR(100) NOT NULL,
    wbs_level INTEGER DEFAULT 1,
    parent_wbs VARCHAR(24),
    project_manager VARCHAR(100),
    profit_center_code VARCHAR(10),
    is_active BOOLEAN DEFAULT true,
    project_start_date DATE,
    project_end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(company_code, wbs_element)
);

-- Create fiscal_year_variants table
CREATE TABLE IF NOT EXISTS fiscal_year_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_code VARCHAR(4) NOT NULL,
    fiscal_year_variant VARCHAR(2) NOT NULL,
    fiscal_year INTEGER NOT NULL,
    period_number INTEGER NOT NULL,
    period_start_date DATE NOT NULL,
    period_end_date DATE NOT NULL,
    is_open BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(company_code, fiscal_year, period_number)
);

-- Create document_number_ranges table
CREATE TABLE IF NOT EXISTS document_number_ranges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_code VARCHAR(4) NOT NULL,
    document_type VARCHAR(2) NOT NULL,
    number_range_object VARCHAR(10) NOT NULL,
    from_number INTEGER NOT NULL,
    to_number INTEGER NOT NULL,
    current_number INTEGER NOT NULL,
    external_numbering BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(company_code, document_type)
);

-- Create gl_account_authorization table
CREATE TABLE IF NOT EXISTS gl_account_authorization (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    company_code VARCHAR(4) NOT NULL,
    account_code VARCHAR(20) NOT NULL,
    authorization_type VARCHAR(10) NOT NULL, -- POST, DISPLAY, CHANGE
    amount_limit DECIMAL(15,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, company_code, account_code, authorization_type)
);

-- Create document_types table
CREATE TABLE IF NOT EXISTS document_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_type VARCHAR(2) NOT NULL UNIQUE,
    document_type_name VARCHAR(50) NOT NULL,
    number_range_object VARCHAR(10) NOT NULL,
    account_type_allowed VARCHAR(10) DEFAULT 'ALL',
    requires_approval BOOLEAN DEFAULT false,
    approval_amount_limit DECIMAL(15,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

DO $$
BEGIN
    -- Check each table individually before creating indexes
    IF EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'cost_centers' AND column_name = 'company_code') THEN
        IF NOT EXISTS (SELECT FROM pg_indexes WHERE indexname = 'idx_cost_centers_company') THEN
            CREATE INDEX idx_cost_centers_company ON cost_centers(company_code, is_active);
        END IF;
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'profit_centers' AND column_name = 'company_code') THEN
        IF NOT EXISTS (SELECT FROM pg_indexes WHERE indexname = 'idx_profit_centers_company') THEN
            CREATE INDEX idx_profit_centers_company ON profit_centers(company_code, is_active);
        END IF;
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'wbs_elements' AND column_name = 'company_code') THEN
        IF NOT EXISTS (SELECT FROM pg_indexes WHERE indexname = 'idx_wbs_elements_company') THEN
            CREATE INDEX idx_wbs_elements_company ON wbs_elements(company_code, is_active);
        END IF;
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'fiscal_year_variants' AND column_name = 'company_code') THEN
        IF NOT EXISTS (SELECT FROM pg_indexes WHERE indexname = 'idx_fiscal_periods') THEN
            CREATE INDEX idx_fiscal_periods ON fiscal_year_variants(company_code, fiscal_year, period_number);
        END IF;
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'gl_account_authorization' AND column_name = 'company_code') THEN
        IF NOT EXISTS (SELECT FROM pg_indexes WHERE indexname = 'idx_gl_auth_user') THEN
            CREATE INDEX idx_gl_auth_user ON gl_account_authorization(user_id, company_code);
        END IF;
    END IF;
END
$$;

SELECT 'Master data tables created/updated successfully without data loss' as status;