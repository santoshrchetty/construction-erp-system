-- Safe GL Posting Master Data Creation
-- Handles existing tables and missing columns

-- Drop existing tables if they exist to avoid conflicts
DROP TABLE IF EXISTS gl_account_authorization CASCADE;
DROP TABLE IF EXISTS document_number_ranges CASCADE;
DROP TABLE IF EXISTS fiscal_year_variants CASCADE;
DROP TABLE IF EXISTS wbs_elements CASCADE;
DROP TABLE IF EXISTS profit_centers CASCADE;
DROP TABLE IF EXISTS cost_centers CASCADE;

-- Cost Centers Table
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

-- Profit Centers Table
CREATE TABLE profit_centers (
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

-- Projects/WBS Elements Table
CREATE TABLE wbs_elements (
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

-- Fiscal Year Variants
CREATE TABLE fiscal_year_variants (
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

-- Document Number Ranges
CREATE TABLE document_number_ranges (
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

-- GL Account Authorization
CREATE TABLE gl_account_authorization (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    company_code VARCHAR(4) NOT NULL,
    account_code VARCHAR(20) NOT NULL,
    authorization_type VARCHAR(10) NOT NULL, -- POST, DISPLAY, CHANGE
    amount_limit DECIMAL(15,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, company_code, account_code, authorization_type)
);

-- Document Types Table
CREATE TABLE IF NOT EXISTS document_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_type VARCHAR(2) NOT NULL UNIQUE,
    document_type_name VARCHAR(50) NOT NULL,
    number_range_object VARCHAR(10) NOT NULL,
    account_type_allowed VARCHAR(10) DEFAULT 'ALL', -- ALL, BALANCE_SHEET, P&L
    requires_approval BOOLEAN DEFAULT false,
    approval_amount_limit DECIMAL(15,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_cost_centers_company ON cost_centers(company_code, is_active);
CREATE INDEX idx_profit_centers_company ON profit_centers(company_code, is_active);
CREATE INDEX idx_wbs_elements_company ON wbs_elements(company_code, is_active);
CREATE INDEX idx_fiscal_periods ON fiscal_year_variants(company_code, fiscal_year, period_number);
CREATE INDEX idx_gl_auth_user ON gl_account_authorization(user_id, company_code);

SELECT 'Master data tables created successfully' as status;