-- CJI3-Equivalent Project Report from Universal Journal
-- Shows project costs, revenues, and profitability

CREATE OR REPLACE FUNCTION get_project_report(
    p_company_code VARCHAR(10),
    p_project_code VARCHAR(20) DEFAULT NULL,
    p_from_date DATE DEFAULT NULL,
    p_to_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    project_code VARCHAR(20),
    wbs_element VARCHAR(30),
    gl_account VARCHAR(20),
    account_name VARCHAR(255),
    account_type VARCHAR(20),
    debit_amount DECIMAL(15,2),
    credit_amount DECIMAL(15,2),
    net_amount DECIMAL(15,2),
    cost_center VARCHAR(20),
    employee_id VARCHAR(20),
    material_number VARCHAR(40)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        uj.project_code,
        uj.wbs_element,
        uj.gl_account,
        coa.account_name,
        coa.account_type,
        COALESCE(SUM(CASE WHEN uj.debit_credit = 'D' THEN uj.company_amount ELSE 0 END), 0) as debit_amount,
        COALESCE(SUM(CASE WHEN uj.debit_credit = 'C' THEN uj.company_amount ELSE 0 END), 0) as credit_amount,
        COALESCE(SUM(CASE WHEN uj.debit_credit = 'D' THEN uj.company_amount ELSE -uj.company_amount END), 0) as net_amount,
        uj.cost_center,
        uj.employee_id,
        uj.material_number
    FROM universal_journal uj
    LEFT JOIN chart_of_accounts coa ON uj.gl_account = coa.account_code AND uj.company_code = coa.company_code
    WHERE uj.company_code = p_company_code
      AND uj.project_code IS NOT NULL
      AND (p_project_code IS NULL OR uj.project_code = p_project_code)
      AND (p_from_date IS NULL OR uj.posting_date >= p_from_date)
      AND uj.posting_date <= p_to_date
    GROUP BY uj.project_code, uj.wbs_element, uj.gl_account, coa.account_name, coa.account_type, 
             uj.cost_center, uj.employee_id, uj.material_number
    ORDER BY uj.project_code, uj.wbs_element, uj.gl_account;
END;
$$ LANGUAGE plpgsql;

-- Test the project report with your test data
SELECT * FROM get_project_report('C001', 'P100', NULL, '2026-01-03');

-- Project summary report
SELECT 
    project_code,
    COUNT(*) as transaction_count,
    SUM(debit_amount) as total_debits,
    SUM(credit_amount) as total_credits,
    SUM(net_amount) as project_balance
FROM get_project_report('C001', NULL, NULL, '2026-01-03')
GROUP BY project_code
ORDER BY project_code;