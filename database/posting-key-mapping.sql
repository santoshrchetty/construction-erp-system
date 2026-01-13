-- Posting Key Mapping Table - Auto-derives Debit/Credit from Event Type + GL Account Type
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

-- Insert standard posting key mappings
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
('FX_REALIZED_GAIN_LOSS', 'EXPENSE', 'D', 'DR_FX_REAL_LOSS', 'Debit FX Realized Loss');

-- Index for fast lookup
CREATE INDEX idx_posting_key_mapping ON posting_key_mapping(event_type, gl_account_type);