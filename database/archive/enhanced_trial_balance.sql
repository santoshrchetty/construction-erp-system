-- Drop and recreate Trial Balance function with posting date info
DROP FUNCTION IF EXISTS get_trial_balance(character varying,date,date);

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
    AND fd.posting_date <= p_to_date
    GROUP BY coa.account_code, coa.account_name, coa.account_type
    HAVING COALESCE(SUM(je.debit_amount), 0) > 0 OR COALESCE(SUM(je.credit_amount), 0) > 0
    ORDER BY coa.account_code;
END;
$$ LANGUAGE plpgsql;

-- Test the enhanced function
SELECT * FROM get_trial_balance('C001', NULL, '2024-12-31');