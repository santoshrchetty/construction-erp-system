-- Check existing chart_of_accounts structure and fix setup
-- ======================================================

-- First, let's see what columns exist in chart_of_accounts
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'chart_of_accounts' 
ORDER BY ordinal_position;

-- Check if we need to add account_code column or if it has a different name
DO $$
DECLARE
    has_account_code BOOLEAN;
    has_code BOOLEAN;
BEGIN
    -- Check for account_code column
    SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'chart_of_accounts' AND column_name = 'account_code'
    ) INTO has_account_code;
    
    -- Check for code column (might be named differently)
    SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'chart_of_accounts' AND column_name = 'code'
    ) INTO has_code;
    
    RAISE NOTICE 'Has account_code column: %', has_account_code;
    RAISE NOTICE 'Has code column: %', has_code;
    
    -- Add account_code column if it doesn't exist
    IF NOT has_account_code THEN
        IF has_code THEN
            -- Rename code to account_code
            ALTER TABLE chart_of_accounts RENAME COLUMN code TO account_code;
            RAISE NOTICE 'Renamed code column to account_code';
        ELSE
            -- Add account_code column
            ALTER TABLE chart_of_accounts ADD COLUMN account_code VARCHAR(20) UNIQUE;
            RAISE NOTICE 'Added account_code column';
        END IF;
    END IF;
END $$;

-- Now create financial_documents table
CREATE TABLE IF NOT EXISTS financial_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_number VARCHAR(20) UNIQUE NOT NULL,
    document_type VARCHAR(10) NOT NULL,
    posting_date DATE NOT NULL,
    document_date DATE NOT NULL,
    reference_document VARCHAR(50),
    total_amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    company_code VARCHAR(4) DEFAULT 'C001',
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create journal_entries table (now that account_code exists)
CREATE TABLE IF NOT EXISTS journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES financial_documents(id) ON DELETE CASCADE,
    line_item INTEGER NOT NULL,
    account_code VARCHAR(20) NOT NULL,
    debit_amount DECIMAL(15,2) DEFAULT 0,
    credit_amount DECIMAL(15,2) DEFAULT 0,
    project_code VARCHAR(20),
    wbs_element VARCHAR(50),
    cost_center VARCHAR(20),
    description TEXT,
    reference_key VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(document_id, line_item)
);

-- Add foreign key constraint after table creation
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM information_schema.table_constraints 
        WHERE constraint_name = 'journal_entries_account_code_fkey'
    ) THEN
        ALTER TABLE journal_entries 
        ADD CONSTRAINT journal_entries_account_code_fkey 
        FOREIGN KEY (account_code) REFERENCES chart_of_accounts(account_code);
        RAISE NOTICE 'Added foreign key constraint for account_code';
    END IF;
END $$;

-- Add missing columns to chart_of_accounts
ALTER TABLE chart_of_accounts 
ADD COLUMN IF NOT EXISTS cost_element_category VARCHAR(2),
ADD COLUMN IF NOT EXISTS cost_category VARCHAR(20),
ADD COLUMN IF NOT EXISTS balance_sheet_account BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS cost_relevant BOOLEAN DEFAULT false;

-- Create sequence and function
CREATE SEQUENCE IF NOT EXISTS financial_doc_seq START 1000001;

CREATE OR REPLACE FUNCTION generate_document_number(doc_type VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
    RETURN doc_type || '-' || TO_CHAR(nextval('financial_doc_seq'), 'FM0000000');
END;
$$ LANGUAGE plpgsql;

-- Insert sample accounts (update existing or insert new)
INSERT INTO chart_of_accounts (account_code, account_name, account_type, cost_element_category, cost_category, balance_sheet_account, cost_relevant) 
VALUES
    ('110000', 'Cash and Bank', 'ASSET', NULL, NULL, true, false),
    ('140000', 'Raw Materials Inventory', 'ASSET', NULL, NULL, true, false),
    ('200000', 'Accounts Payable', 'LIABILITY', NULL, NULL, true, false),
    ('201000', 'GR/IR Clearing Account', 'LIABILITY', NULL, NULL, true, false),
    ('400100', 'Raw Materials Consumed', 'EXPENSE', '1', 'MATERIAL', false, true),
    ('450100', 'Subcontractor - Civil Work', 'EXPENSE', '1', 'SUBCONTRACT', false, true),
    ('600100', 'Direct Labor - Site Workers', 'EXPENSE', '1', 'LABOR', false, true),
    ('650100', 'Equipment Rental', 'EXPENSE', '1', 'EQUIPMENT', false, true),
    ('800100', 'Construction Revenue', 'REVENUE', NULL, NULL, false, false)
ON CONFLICT (account_code) DO UPDATE SET
    account_name = EXCLUDED.account_name,
    cost_element_category = EXCLUDED.cost_element_category,
    cost_category = EXCLUDED.cost_category,
    balance_sheet_account = EXCLUDED.balance_sheet_account,
    cost_relevant = EXCLUDED.cost_relevant;

-- Create project_line_items view
CREATE OR REPLACE VIEW project_line_items AS
SELECT 
    je.id,
    je.document_id,
    fd.document_number,
    fd.document_type,
    fd.posting_date,
    EXTRACT(YEAR FROM fd.posting_date) as period_year,
    EXTRACT(MONTH FROM fd.posting_date) as period_month,
    je.account_code as cost_element_code,
    coa.account_name as cost_element_name,
    coa.cost_category,
    je.project_code,
    je.wbs_element,
    je.cost_center,
    CASE 
        WHEN je.debit_amount > 0 THEN je.debit_amount 
        ELSE -je.credit_amount 
    END as amount,
    je.description,
    fd.reference_document,
    fd.created_by,
    je.created_at
FROM journal_entries je
JOIN financial_documents fd ON je.document_id = fd.id
JOIN chart_of_accounts coa ON je.account_code = coa.account_code
WHERE coa.cost_relevant = true 
  AND je.project_code IS NOT NULL;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_journal_entries_project ON journal_entries(project_code, wbs_element);
CREATE INDEX IF NOT EXISTS idx_journal_entries_account ON journal_entries(account_code);
CREATE INDEX IF NOT EXISTS idx_financial_documents_date ON financial_documents(posting_date);

-- Verify setup
SELECT 'Finance setup completed!' as status;
SELECT COUNT(*) as accounts_count FROM chart_of_accounts;