-- Final Finance Setup - Handle existing table structure
-- ====================================================

-- First, let's see the actual table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'chart_of_accounts' 
ORDER BY ordinal_position;

-- Insert data with all required columns (including coa_code)
INSERT INTO chart_of_accounts (coa_code, account_code, account_name, account_type, cost_element_category, cost_category, balance_sheet_account, cost_relevant) 
VALUES
    ('110000', '110000', 'Cash and Bank', 'ASSET', NULL, NULL, true, false),
    ('140000', '140000', 'Raw Materials Inventory', 'ASSET', NULL, NULL, true, false),
    ('200000', '200000', 'Accounts Payable', 'LIABILITY', NULL, NULL, true, false),
    ('201000', '201000', 'GR/IR Clearing Account', 'LIABILITY', NULL, NULL, true, false),
    ('400100', '400100', 'Raw Materials Consumed', 'EXPENSE', '1', 'MATERIAL', false, true),
    ('450100', '450100', 'Subcontractor - Civil Work', 'EXPENSE', '1', 'SUBCONTRACT', false, true),
    ('600100', '600100', 'Direct Labor - Site Workers', 'EXPENSE', '1', 'LABOR', false, true),
    ('650100', '650100', 'Equipment Rental', 'EXPENSE', '1', 'EQUIPMENT', false, true),
    ('800100', '800100', 'Construction Revenue', 'REVENUE', NULL, NULL, false, false)
ON CONFLICT (coa_code) DO NOTHING;

-- Add foreign key constraint using the correct column
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM information_schema.table_constraints 
        WHERE constraint_name = 'journal_entries_account_code_fkey'
    ) THEN
        -- Try with account_code first, fallback to coa_code
        BEGIN
            ALTER TABLE journal_entries 
            ADD CONSTRAINT journal_entries_account_code_fkey 
            FOREIGN KEY (account_code) REFERENCES chart_of_accounts(account_code);
        EXCEPTION WHEN OTHERS THEN
            -- If account_code doesn't work, try coa_code
            ALTER TABLE journal_entries 
            ADD CONSTRAINT journal_entries_account_code_fkey 
            FOREIGN KEY (account_code) REFERENCES chart_of_accounts(coa_code);
        END;
    END IF;
END $$;

-- Create project_line_items view with flexible column reference
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
    COALESCE(coa.account_name, coa.coa_name) as cost_element_name,
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
JOIN chart_of_accounts coa ON (je.account_code = coa.account_code OR je.account_code = coa.coa_code)
WHERE coa.cost_relevant = true 
  AND je.project_code IS NOT NULL;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_journal_entries_project ON journal_entries(project_code, wbs_element);
CREATE INDEX IF NOT EXISTS idx_journal_entries_account ON journal_entries(account_code);
CREATE INDEX IF NOT EXISTS idx_financial_documents_date ON financial_documents(posting_date);

-- Verify setup
SELECT 'Finance system ready!' as status;
SELECT COUNT(*) as accounts_count FROM chart_of_accounts;

-- Show the accounts we just added
SELECT COALESCE(coa_code, account_code) as code, 
       COALESCE(account_name, coa_name) as name, 
       account_type, 
       cost_relevant 
FROM chart_of_accounts 
WHERE COALESCE(coa_code, account_code) IN ('110000', '140000', '400100', '600100')
ORDER BY COALESCE(coa_code, account_code);