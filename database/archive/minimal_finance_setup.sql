-- Minimal Finance Setup - Respect existing constraints
-- ===================================================

-- Check existing data first
SELECT COUNT(*) as existing_accounts FROM chart_of_accounts;

-- Insert minimal sample data (include coa_name for NOT NULL constraint)
INSERT INTO chart_of_accounts (coa_code, coa_name, account_code, account_name, account_type, cost_relevant) 
VALUES
    ('1100', 'Cash', '1100', 'Cash', 'ASSET', false),
    ('1400', 'Inventory', '1400', 'Inventory', 'ASSET', false),
    ('2000', 'Payables', '2000', 'Payables', 'LIABILITY', false),
    ('4001', 'Materials', '4001', 'Materials', 'EXPENSE', true),
    ('6001', 'Labor', '6001', 'Labor', 'EXPENSE', true)
ON CONFLICT (coa_code) DO NOTHING;

-- Create basic view for project costs
CREATE OR REPLACE VIEW project_line_items AS
SELECT 
    je.id,
    fd.document_number,
    fd.posting_date,
    je.account_code as cost_element_code,
    je.project_code,
    je.wbs_element,
    CASE 
        WHEN je.debit_amount > 0 THEN je.debit_amount 
        ELSE -je.credit_amount 
    END as amount
FROM journal_entries je
JOIN financial_documents fd ON je.document_id = fd.id
JOIN chart_of_accounts coa ON je.account_code = coa.coa_code
WHERE coa.cost_relevant = true 
  AND je.project_code IS NOT NULL;

-- Verify
SELECT 'Finance setup completed!' as status;
SELECT coa_code, coa_name, cost_relevant FROM chart_of_accounts ORDER BY coa_code;