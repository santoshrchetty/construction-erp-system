-- COMPLETE FINANCE ENGINE DEPLOYMENT SCRIPT
-- Run this entire script in Supabase SQL Editor

-- 1. Add missing columns to company_codes table
ALTER TABLE company_codes ADD COLUMN IF NOT EXISTS local_currency VARCHAR(3) DEFAULT 'USD';
ALTER TABLE company_codes ADD COLUMN IF NOT EXISTS reporting_currency VARCHAR(3) DEFAULT 'USD';

-- 2. Create FX rates table
CREATE TABLE IF NOT EXISTS fx_rates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_currency VARCHAR(3) NOT NULL,
    to_currency VARCHAR(3) NOT NULL,
    rate_date DATE NOT NULL,
    exchange_rate DECIMAL(12,6) NOT NULL,
    rate_source VARCHAR(20) DEFAULT 'SYSTEM',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert sample FX rates
INSERT INTO fx_rates (from_currency, to_currency, rate_date, exchange_rate) VALUES
('EUR', 'USD', '2026-01-01', 1.0500),
('GBP', 'USD', '2026-01-01', 1.2500),
('AED', 'USD', '2026-01-01', 0.2722)
ON CONFLICT DO NOTHING;

-- 3. Create Universal Journal Table (ACDOCA-Type)
CREATE TABLE IF NOT EXISTS universal_journal (
    -- Core Event Fields
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_timestamp TIMESTAMPTZ NOT NULL,
    source_system VARCHAR(20) NOT NULL,
    source_document_type VARCHAR(20),
    source_document_id VARCHAR(50),
    
    -- Company & Ledger
    company_code VARCHAR(10) NOT NULL,
    ledger VARCHAR(20) NOT NULL, -- ACCRUAL, CASH, TAX, MANAGEMENT
    
    -- Posting Details
    posting_date DATE NOT NULL,
    document_date DATE NOT NULL,
    gl_account VARCHAR(20) NOT NULL,
    posting_key VARCHAR(20) NOT NULL, -- Auto-derived
    debit_credit CHAR(1) NOT NULL CHECK (debit_credit IN ('D', 'C')),
    
    -- Amounts & Currency
    transaction_currency VARCHAR(3) NOT NULL,
    transaction_amount DECIMAL(15,2) NOT NULL,
    company_currency VARCHAR(3) NOT NULL,
    company_amount DECIMAL(15,2) NOT NULL,
    group_currency VARCHAR(3),
    group_amount DECIMAL(15,2),
    
    -- FX Handling
    fx_rate_transaction_to_company DECIMAL(12,6),
    fx_rate_transaction_to_group DECIMAL(12,6),
    fx_rate_source VARCHAR(20),
    fx_rate_timestamp TIMESTAMPTZ,
    
    -- Multi-Dimensional Analytics
    cost_center VARCHAR(20),
    profit_center VARCHAR(20),
    project_code VARCHAR(20),
    wbs_element VARCHAR(30),
    asset_number VARCHAR(20),
    material_number VARCHAR(40),
    production_order VARCHAR(20),
    maintenance_order VARCHAR(20),
    customer_code VARCHAR(20),
    supplier_code VARCHAR(20),
    employee_id VARCHAR(20),
    contract_number VARCHAR(30),
    real_estate_object VARCHAR(20),
    treasury_instrument VARCHAR(20),
    tax_code VARCHAR(10),
    
    -- Audit & Control
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID,
    is_reversal BOOLEAN DEFAULT FALSE,
    reversal_of_event_id UUID,
    reversal_reason TEXT,
    
    -- Constraints
    CONSTRAINT fk_company_code FOREIGN KEY (company_code) REFERENCES company_codes(company_code)
);

-- 4. Create Performance Indexes
CREATE INDEX IF NOT EXISTS idx_universal_journal_event ON universal_journal(event_id, event_type);
CREATE INDEX IF NOT EXISTS idx_universal_journal_company_ledger ON universal_journal(company_code, ledger);
CREATE INDEX IF NOT EXISTS idx_universal_journal_posting_date ON universal_journal(posting_date);
CREATE INDEX IF NOT EXISTS idx_universal_journal_gl_account ON universal_journal(gl_account);
CREATE INDEX IF NOT EXISTS idx_universal_journal_dimensions ON universal_journal(cost_center, profit_center, project_code);
CREATE INDEX IF NOT EXISTS idx_universal_journal_source ON universal_journal(source_system, source_document_type, source_document_id);

-- 5. Create Posting Key Mapping Table
CREATE TABLE IF NOT EXISTS posting_key_mapping (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type VARCHAR(50) NOT NULL,
    gl_account_type VARCHAR(20) NOT NULL, -- ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE
    debit_credit CHAR(1) NOT NULL CHECK (debit_credit IN ('D', 'C')),
    posting_key VARCHAR(30) NOT NULL,
    posting_key_description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Insert Posting Key Mappings
INSERT INTO posting_key_mapping (event_type, gl_account_type, debit_credit, posting_key, posting_key_description) VALUES
-- Project Labor Costs
('PROJECT_LABOR_COST', 'EXPENSE', 'D', 'DR_LABOR_EXP', 'Debit Labor Expense'),
('PROJECT_LABOR_COST', 'LIABILITY', 'C', 'CR_PAYROLL_LIAB', 'Credit Payroll Liability'),

-- Customer Invoicing
('CUSTOMER_INVOICE_POSTED', 'REVENUE', 'C', 'CR_REVENUE', 'Credit Revenue'),
('CUSTOMER_INVOICE_POSTED', 'ASSET', 'D', 'DR_AR', 'Debit Accounts Receivable'),

-- Supplier Invoicing
('SUPPLIER_INVOICE_POSTED', 'LIABILITY', 'C', 'CR_AP', 'Credit Accounts Payable'),
('SUPPLIER_INVOICE_POSTED', 'EXPENSE', 'D', 'DR_EXPENSE', 'Debit Expense'),
('SUPPLIER_INVOICE_POSTED', 'ASSET', 'D', 'DR_ASSET', 'Debit Asset'),

-- Depreciation
('DEPRECIATION_POSTED', 'ASSET', 'C', 'CR_ACC_DEPR', 'Credit Accumulated Depreciation'),
('DEPRECIATION_POSTED', 'EXPENSE', 'D', 'DR_DEPR_EXP', 'Debit Depreciation Expense'),

-- Bank Payments
('BANK_PAYMENT', 'ASSET', 'C', 'CR_BANK', 'Credit Bank Account'),
('BANK_PAYMENT', 'EXPENSE', 'D', 'DR_BANK_EXP', 'Debit Expense'),
('BANK_PAYMENT', 'LIABILITY', 'D', 'DR_AP_PAY', 'Debit AP Payment'),

-- Cash Receipts
('CASH_RECEIPT', 'ASSET', 'D', 'DR_CASH', 'Debit Cash Account'),
('CASH_RECEIPT', 'ASSET', 'C', 'CR_AR_PAY', 'Credit AR Payment'),
('CASH_RECEIPT', 'REVENUE', 'C', 'CR_CASH_REV', 'Credit Cash Revenue'),

-- Material Issues
('MATERIAL_ISSUED_TO_PRODUCTION', 'ASSET', 'C', 'CR_INVENTORY', 'Credit Inventory'),
('MATERIAL_ISSUED_TO_PRODUCTION', 'EXPENSE', 'D', 'DR_PROD_COST', 'Debit Production Cost'),

-- FX Events
('FX_UNREALIZED_REVALUATION', 'ASSET', 'D', 'DR_FX_GAIN', 'Debit FX Unrealized Gain'),
('FX_UNREALIZED_REVALUATION', 'ASSET', 'C', 'CR_FX_LOSS', 'Credit FX Unrealized Loss'),
('FX_REALIZED_GAIN_LOSS', 'REVENUE', 'C', 'CR_FX_REAL_GAIN', 'Credit FX Realized Gain'),
('FX_REALIZED_GAIN_LOSS', 'EXPENSE', 'D', 'DR_FX_REAL_LOSS', 'Debit FX Realized Loss')
ON CONFLICT DO NOTHING;

-- 7. Create Index for Posting Key Mapping
CREATE INDEX IF NOT EXISTS idx_posting_key_mapping ON posting_key_mapping(event_type, gl_account_type);

-- 8. Create Trial Balance Function
CREATE OR REPLACE FUNCTION get_trial_balance(
    p_company_code VARCHAR(10),
    p_ledger VARCHAR(20),
    p_posting_date DATE
)
RETURNS TABLE (
    gl_account VARCHAR(20),
    account_name VARCHAR(255),
    account_type VARCHAR(20),
    debit_balance DECIMAL(15,2),
    credit_balance DECIMAL(15,2),
    net_balance DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        uj.gl_account,
        coa.account_name,
        coa.account_type,
        COALESCE(SUM(CASE WHEN uj.debit_credit = 'D' THEN uj.company_amount ELSE 0 END), 0) as debit_balance,
        COALESCE(SUM(CASE WHEN uj.debit_credit = 'C' THEN uj.company_amount ELSE 0 END), 0) as credit_balance,
        COALESCE(SUM(CASE WHEN uj.debit_credit = 'D' THEN uj.company_amount ELSE -uj.company_amount END), 0) as net_balance
    FROM universal_journal uj
    JOIN chart_of_accounts coa ON uj.gl_account = coa.account_code AND uj.company_code = coa.company_code
    WHERE uj.company_code = p_company_code
      AND uj.ledger = p_ledger
      AND uj.posting_date <= p_posting_date
    GROUP BY uj.gl_account, coa.account_name, coa.account_type
    ORDER BY uj.gl_account;
END;
$$ LANGUAGE plpgsql;

-- 9. Verification Queries
SELECT 'Universal Journal Table Created' as status, 
       COUNT(*) as column_count 
FROM information_schema.columns 
WHERE table_name = 'universal_journal';

SELECT 'Posting Key Mappings Loaded' as status, 
       COUNT(*) as mapping_count 
FROM posting_key_mapping;

SELECT 'FX Rates Loaded' as status, 
       COUNT(*) as rate_count 
FROM fx_rates;

-- Success message
SELECT 'FINANCE ENGINE DEPLOYMENT COMPLETE' as message,
       'Ready for event processing' as status;