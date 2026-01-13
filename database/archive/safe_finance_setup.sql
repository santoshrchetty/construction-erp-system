-- Safe Finance Setup - Only creates missing components
-- ====================================================

-- Check and create financial_documents table if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'financial_documents') THEN
        CREATE TABLE financial_documents (
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
        RAISE NOTICE 'Created financial_documents table';
    ELSE
        RAISE NOTICE 'financial_documents table already exists';
    END IF;
END $$;

-- Check and create journal_entries table if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'journal_entries') THEN
        CREATE TABLE journal_entries (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            document_id UUID NOT NULL REFERENCES financial_documents(id) ON DELETE CASCADE,
            line_item INTEGER NOT NULL,
            account_code VARCHAR(20) NOT NULL REFERENCES chart_of_accounts(account_code),
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
        RAISE NOTICE 'Created journal_entries table';
    ELSE
        RAISE NOTICE 'journal_entries table already exists';
    END IF;
END $$;

-- Add missing columns to chart_of_accounts if they don't exist
DO $$
BEGIN
    -- Add cost_element_category column
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'chart_of_accounts' AND column_name = 'cost_element_category') THEN
        ALTER TABLE chart_of_accounts ADD COLUMN cost_element_category VARCHAR(2);
        RAISE NOTICE 'Added cost_element_category column';
    END IF;
    
    -- Add cost_category column
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'chart_of_accounts' AND column_name = 'cost_category') THEN
        ALTER TABLE chart_of_accounts ADD COLUMN cost_category VARCHAR(20);
        RAISE NOTICE 'Added cost_category column';
    END IF;
    
    -- Add balance_sheet_account column
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'chart_of_accounts' AND column_name = 'balance_sheet_account') THEN
        ALTER TABLE chart_of_accounts ADD COLUMN balance_sheet_account BOOLEAN DEFAULT false;
        RAISE NOTICE 'Added balance_sheet_account column';
    END IF;
    
    -- Add cost_relevant column
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'chart_of_accounts' AND column_name = 'cost_relevant') THEN
        ALTER TABLE chart_of_accounts ADD COLUMN cost_relevant BOOLEAN DEFAULT false;
        RAISE NOTICE 'Added cost_relevant column';
    END IF;
END $$;

-- Insert sample chart of accounts data (only if not exists)
INSERT INTO chart_of_accounts (account_code, account_name, account_type, cost_element_category, cost_category, balance_sheet_account, cost_relevant) 
SELECT * FROM (VALUES
    ('110000', 'Cash and Bank', 'ASSET', NULL, NULL, true, false),
    ('140000', 'Raw Materials Inventory', 'ASSET', NULL, NULL, true, false),
    ('200000', 'Accounts Payable', 'LIABILITY', NULL, NULL, true, false),
    ('201000', 'GR/IR Clearing Account', 'LIABILITY', NULL, NULL, true, false),
    ('400100', 'Raw Materials Consumed', 'EXPENSE', '1', 'MATERIAL', false, true),
    ('450100', 'Subcontractor - Civil Work', 'EXPENSE', '1', 'SUBCONTRACT', false, true),
    ('600100', 'Direct Labor - Site Workers', 'EXPENSE', '1', 'LABOR', false, true),
    ('650100', 'Equipment Rental', 'EXPENSE', '1', 'EQUIPMENT', false, true),
    ('800100', 'Construction Revenue', 'REVENUE', NULL, NULL, false, false)
) AS new_accounts(account_code, account_name, account_type, cost_element_category, cost_category, balance_sheet_account, cost_relevant)
WHERE NOT EXISTS (
    SELECT 1 FROM chart_of_accounts WHERE chart_of_accounts.account_code = new_accounts.account_code
);

-- Create project_line_items view (replace if exists)
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

-- Create sequence if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.sequences WHERE sequence_name = 'financial_doc_seq') THEN
        CREATE SEQUENCE financial_doc_seq START 1000001;
        RAISE NOTICE 'Created financial_doc_seq sequence';
    END IF;
END $$;

-- Create document number function
CREATE OR REPLACE FUNCTION generate_document_number(doc_type VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
    RETURN doc_type || '-' || TO_CHAR(nextval('financial_doc_seq'), 'FM0000000');
END;
$$ LANGUAGE plpgsql;

-- Create indexes if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_indexes WHERE indexname = 'idx_journal_entries_project') THEN
        CREATE INDEX idx_journal_entries_project ON journal_entries(project_code, wbs_element);
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_indexes WHERE indexname = 'idx_journal_entries_account') THEN
        CREATE INDEX idx_journal_entries_account ON journal_entries(account_code);
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_indexes WHERE indexname = 'idx_financial_documents_date') THEN
        CREATE INDEX idx_financial_documents_date ON financial_documents(posting_date);
    END IF;
END $$;

-- Verify setup
SELECT 'Finance setup completed successfully!' as status;
SELECT COUNT(*) as chart_of_accounts_count FROM chart_of_accounts;
SELECT COUNT(*) as financial_documents_count FROM financial_documents;
SELECT COUNT(*) as journal_entries_count FROM journal_entries;