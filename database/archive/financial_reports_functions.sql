-- Trial Balance Function
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
        LEFT JOIN journal_entries je ON coa.account_number = je.gl_account
        LEFT JOIN financial_documents fd ON je.document_id = fd.id
        WHERE coa.company_code = p_company_code
        AND coa.is_active = true
        AND (p_from_date IS NULL OR fd.posting_date >= p_from_date)
        AND fd.posting_date <= p_to_date
        AND fd.status = 'posted'
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

-- Profit & Loss Function
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
        LEFT JOIN journal_entries je ON coa.account_number = je.gl_account
        LEFT JOIN financial_documents fd ON je.document_id = fd.id
        WHERE coa.company_code = p_company_code
        AND coa.account_type IN ('REVENUE', 'EXPENSE')
        AND coa.is_active = true
        AND (p_from_date IS NULL OR fd.posting_date >= p_from_date)
        AND fd.posting_date <= p_to_date
        AND fd.status = 'posted'
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