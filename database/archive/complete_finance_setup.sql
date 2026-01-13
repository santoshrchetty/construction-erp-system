-- Complete Finance Setup - Add sample data and views
-- ==================================================

-- Add unique constraint on account_code first
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM information_schema.table_constraints 
        WHERE constraint_name = 'chart_of_accounts_account_code_key'
    ) THEN
        ALTER TABLE chart_of_accounts ADD CONSTRAINT chart_of_accounts_account_code_key UNIQUE (account_code);
    END IF;
END $$;

-- Add sample chart of accounts data
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
ON CONFLICT (account_code) DO NOTHING;

-- Add foreign key constraint for journal_entries
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM information_schema.table_constraints 
        WHERE constraint_name = 'journal_entries_account_code_fkey'
    ) THEN
        ALTER TABLE journal_entries 
        ADD CONSTRAINT journal_entries_account_code_fkey 
        FOREIGN KEY (account_code) REFERENCES chart_of_accounts(account_code);
    END IF;
END $$;

-- Create project_line_items view (CJI3 equivalent)
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

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_journal_entries_project ON journal_entries(project_code, wbs_element);
CREATE INDEX IF NOT EXISTS idx_journal_entries_account ON journal_entries(account_code);
CREATE INDEX IF NOT EXISTS idx_financial_documents_date ON financial_documents(posting_date);
CREATE INDEX IF NOT EXISTS idx_chart_of_accounts_code ON chart_of_accounts(account_code);

-- Verify setup
SELECT 'Finance system setup completed!' as status;
SELECT COUNT(*) as chart_of_accounts_count FROM chart_of_accounts;
SELECT COUNT(*) as financial_documents_count FROM financial_documents;
SELECT COUNT(*) as journal_entries_count FROM journal_entries;

-- Show sample accounts
SELECT account_code, account_name, account_type, cost_relevant 
FROM chart_of_accounts 
ORDER BY account_code;