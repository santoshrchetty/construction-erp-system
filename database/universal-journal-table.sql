-- Modern Event-Based Finance Engine - Universal Journal (ACDOCA-Type)
-- Single table for all financial postings across all modules

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
    
    -- Indexes for performance
    CONSTRAINT fk_company_code FOREIGN KEY (company_code) REFERENCES company_codes(company_code)
    -- Note: Removed FK constraint to chart_of_accounts due to missing unique constraint
    -- CONSTRAINT fk_gl_account FOREIGN KEY (gl_account) REFERENCES chart_of_accounts(account_code)
);

-- Performance Indexes
CREATE INDEX idx_universal_journal_event ON universal_journal(event_id, event_type);
CREATE INDEX idx_universal_journal_company_ledger ON universal_journal(company_code, ledger);
CREATE INDEX idx_universal_journal_posting_date ON universal_journal(posting_date);
CREATE INDEX idx_universal_journal_gl_account ON universal_journal(gl_account);
CREATE INDEX idx_universal_journal_dimensions ON universal_journal(cost_center, profit_center, project_code);
CREATE INDEX idx_universal_journal_source ON universal_journal(source_system, source_document_type, source_document_id);