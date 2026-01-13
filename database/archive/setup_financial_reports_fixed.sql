-- Complete Financial Reports Setup Script
-- Run this in your Supabase SQL Editor

-- 1. Create cost_centers table
CREATE TABLE IF NOT EXISTS cost_centers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_code VARCHAR(4) NOT NULL,
    cost_center_code VARCHAR(10) NOT NULL,
    cost_center_name VARCHAR(100) NOT NULL,
    cost_center_type VARCHAR(20) DEFAULT 'STANDARD',
    responsible_person VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(company_code, cost_center_code)
);

-- 2. Insert cost centers
INSERT INTO cost_centers (company_code, cost_center_code, cost_center_name, cost_center_type, responsible_person) VALUES
('C001', 'CC-ADMIN', 'Administration', 'OVERHEAD', 'Admin Manager'),
('C001', 'CC-PROJ01', 'Project Alpha', 'PROJECT', 'Project Manager A'),
('C001', 'CC-PROJ02', 'Project Beta', 'PROJECT', 'Project Manager B'),
('C001', 'CC-MAINT', 'Equipment Maintenance', 'SERVICE', 'Maintenance Head'),
('C001', 'CC-SALES', 'Sales & Marketing', 'REVENUE', 'Sales Director'),
('C002', 'CC-ADMIN', 'Administration', 'OVERHEAD', 'Admin Manager EU'),
('C002', 'CC-PROJ03', 'Infrastructure Project', 'PROJECT', 'Project Manager EU')
ON CONFLICT (company_code, cost_center_code) DO NOTHING;

-- 3. Create Trial Balance function
CREATE OR REPLACE FUNCTION get_trial_balance(
    p_company_code VARCHAR(4),
    p_from_date DATE DEFAULT NULL,
    p_to_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    account_number VARCHAR(10),
    account_name VARCHAR(100),
    account_type VARCHAR(20),
    debit_balance DECIMAL(15,2),
    credit_balance DECIMAL(15,2),
    net_balance DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    WITH account_balances AS (
        SELECT 
            coa.account_number,
            coa.account_name,
            coa.account_type,
            COALESCE(SUM(je.debit_amount), 0) as total_debit,
            COALESCE(SUM(je.credit_amount), 0) as total_credit
        FROM chart_of_accounts coa
        LEFT JOIN journal_entries je ON coa.account_number = je.account_code
        LEFT JOIN financial_documents fd ON je.document_id = fd.id
        WHERE coa.company_code = p_company_code
        AND coa.is_active = true
        AND (p_from_date IS NULL OR fd.posting_date >= p_from_date)
        AND fd.posting_date <= p_to_date
        GROUP BY coa.account_number, coa.account_name, coa.account_type
    )
    SELECT 
        ab.account_number,
        ab.account_name,
        ab.account_type,
        CASE WHEN ab.total_debit > ab.total_credit THEN ab.total_debit - ab.total_credit ELSE 0 END as debit_balance,
        CASE WHEN ab.total_credit > ab.total_debit THEN ab.total_credit - ab.total_debit ELSE 0 END as credit_balance,
        ab.total_debit - ab.total_credit as net_balance
    FROM account_balances ab
    WHERE ab.total_debit != 0 OR ab.total_credit != 0
    ORDER BY ab.account_number;
END;
$$ LANGUAGE plpgsql;

-- 4. Create Profit & Loss function
CREATE OR REPLACE FUNCTION get_profit_loss(
    p_company_code VARCHAR(4),
    p_from_date DATE DEFAULT NULL,
    p_to_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    section VARCHAR(20),
    account_number VARCHAR(10),
    account_name VARCHAR(100),
    amount DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    WITH pl_data AS (
        SELECT 
            CASE 
                WHEN coa.account_type = 'REVENUE' THEN 'REVENUE'
                WHEN coa.account_type = 'EXPENSE' THEN 'EXPENSE'
                ELSE 'OTHER'
            END as section,
            coa.account_number,
            coa.account_name,
            CASE 
                WHEN coa.account_type = 'REVENUE' THEN COALESCE(SUM(je.credit_amount - je.debit_amount), 0)
                WHEN coa.account_type = 'EXPENSE' THEN COALESCE(SUM(je.debit_amount - je.credit_amount), 0)
                ELSE 0
            END as amount
        FROM chart_of_accounts coa
        LEFT JOIN journal_entries je ON coa.account_number = je.account_code
        LEFT JOIN financial_documents fd ON je.document_id = fd.id
        WHERE coa.company_code = p_company_code
        AND coa.account_type IN ('REVENUE', 'EXPENSE')
        AND coa.is_active = true
        AND (p_from_date IS NULL OR fd.posting_date >= p_from_date)
        AND fd.posting_date <= p_to_date
        GROUP BY coa.account_number, coa.account_name, coa.account_type
    )
    SELECT 
        pd.section,
        pd.account_number,
        pd.account_name,
        pd.amount
    FROM pl_data pd
    WHERE pd.amount != 0
    ORDER BY pd.section DESC, pd.account_number;
END;
$$ LANGUAGE plpgsql;

-- 5. Insert sample financial data
INSERT INTO financial_documents (document_number, company_code, document_type, posting_date, document_date, reference_document, total_amount, created_by) VALUES
('SA-1000001', 'C001', 'SA', '2024-01-15', '2024-01-15', 'REF-001', 50000.00, '00000000-0000-0000-0000-000000000000'),
('SA-1000002', 'C001', 'SA', '2024-01-20', '2024-01-20', 'REF-002', 25000.00, '00000000-0000-0000-0000-000000000000'),
('SA-1000003', 'C001', 'SA', '2024-02-01', '2024-02-01', 'REF-003', 15000.00, '00000000-0000-0000-0000-000000000000'),
('SA-1000004', 'C001', 'SA', '2024-02-10', '2024-02-10', 'REF-004', 100000.00, '00000000-0000-0000-0000-000000000000'),
('SA-1000005', 'C001', 'SA', '2024-02-15', '2024-02-15', 'REF-005', 35000.00, '00000000-0000-0000-0000-000000000000')
ON CONFLICT DO NOTHING;

-- 6. Insert journal entries
DO $$
DECLARE
    doc1_id UUID;
    doc2_id UUID;
    doc3_id UUID;
    doc4_id UUID;
    doc5_id UUID;
BEGIN
    SELECT id INTO doc1_id FROM financial_documents WHERE reference_document = 'REF-001';
    SELECT id INTO doc2_id FROM financial_documents WHERE reference_document = 'REF-002';
    SELECT id INTO doc3_id FROM financial_documents WHERE reference_document = 'REF-003';
    SELECT id INTO doc4_id FROM financial_documents WHERE reference_document = 'REF-004';
    SELECT id INTO doc5_id FROM financial_documents WHERE reference_document = 'REF-005';

    INSERT INTO journal_entries (document_id, line_item, account_code, debit_amount, credit_amount, cost_center, description) VALUES
    (doc1_id, 1, '400100', 50000.00, 0, 'CC-PROJ01', 'Raw Materials Consumed'),
    (doc1_id, 2, '110000', 0, 50000.00, NULL, 'Cash Payment'),
    (doc2_id, 1, '600100', 25000.00, 0, 'CC-PROJ01', 'Direct Labor - Site Workers'),
    (doc2_id, 2, '110000', 0, 25000.00, NULL, 'Cash Payment'),
    (doc3_id, 1, '650100', 15000.00, 0, 'CC-PROJ01', 'Equipment Rental'),
    (doc3_id, 2, '110000', 0, 15000.00, NULL, 'Cash Payment'),
    (doc4_id, 1, '110000', 100000.00, 0, NULL, 'Cash Receipt'),
    (doc4_id, 2, '800100', 0, 100000.00, 'CC-PROJ01', 'Construction Revenue'),
    (doc5_id, 1, '450100', 35000.00, 0, 'CC-PROJ01', 'Subcontractor - Civil Work'),
    (doc5_id, 2, '110000', 0, 35000.00, NULL, 'Cash Payment')
    ON CONFLICT DO NOTHING;
END $$;

-- 7. Create indexes
CREATE INDEX IF NOT EXISTS idx_cost_centers_company ON cost_centers(company_code);
CREATE INDEX IF NOT EXISTS idx_cost_centers_active ON cost_centers(is_active);

-- Verification queries
SELECT 'Cost Centers Created:' as status, count(*) as count FROM cost_centers;
SELECT 'Financial Documents:' as status, count(*) as count FROM financial_documents;
SELECT 'Journal Entries:' as status, count(*) as count FROM journal_entries;