-- 1. Update posting dates to current year
UPDATE financial_documents SET 
    posting_date = '2025-01-15',
    document_date = '2025-01-15'
WHERE reference_document = 'REF-001';

UPDATE financial_documents SET 
    posting_date = '2025-01-20',
    document_date = '2025-01-20'
WHERE reference_document = 'REF-002';

UPDATE financial_documents SET 
    posting_date = '2025-02-01',
    document_date = '2025-02-01'
WHERE reference_document = 'REF-003';

UPDATE financial_documents SET 
    posting_date = '2025-02-10',
    document_date = '2025-02-10'
WHERE reference_document = 'REF-004';

UPDATE financial_documents SET 
    posting_date = '2025-02-15',
    document_date = '2025-02-15'
WHERE reference_document = 'REF-005';

-- 2. Fix trial balance function to show all data when no to_date specified
DROP FUNCTION IF EXISTS get_trial_balance(character varying,date,date);

CREATE OR REPLACE FUNCTION get_trial_balance(
    p_company_code VARCHAR(4),
    p_from_date DATE DEFAULT NULL,
    p_to_date DATE DEFAULT NULL
)
RETURNS TABLE (
    account_number VARCHAR(10),
    account_name VARCHAR(100),
    account_type VARCHAR(20),
    debit_balance DECIMAL(15,2),
    credit_balance DECIMAL(15,2),
    net_balance DECIMAL(15,2),
    first_posting_date DATE,
    last_posting_date DATE,
    transaction_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        coa.account_code,
        coa.account_name,
        coa.account_type,
        COALESCE(SUM(je.debit_amount), 0) as debit_balance,
        COALESCE(SUM(je.credit_amount), 0) as credit_balance,
        COALESCE(SUM(je.debit_amount), 0) - COALESCE(SUM(je.credit_amount), 0) as net_balance,
        MIN(fd.posting_date) as first_posting_date,
        MAX(fd.posting_date) as last_posting_date,
        COUNT(je.id)::INTEGER as transaction_count
    FROM chart_of_accounts coa
    LEFT JOIN journal_entries je ON coa.account_code = je.account_code
    LEFT JOIN financial_documents fd ON je.document_id = fd.id
    WHERE coa.company_code = p_company_code
    AND coa.is_active = true
    AND (p_from_date IS NULL OR fd.posting_date >= p_from_date)
    AND (p_to_date IS NULL OR fd.posting_date <= p_to_date)
    GROUP BY coa.account_code, coa.account_name, coa.account_type
    HAVING COALESCE(SUM(je.debit_amount), 0) > 0 OR COALESCE(SUM(je.credit_amount), 0) > 0
    ORDER BY coa.account_code;
END;
$$ LANGUAGE plpgsql;

-- 3. Test the function
SELECT * FROM get_trial_balance('C001', NULL, NULL);