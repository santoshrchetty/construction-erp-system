-- DEPLOYMENT SCRIPT - Run in Supabase SQL Editor in this order:

-- 1. First, add missing columns to company_codes table
ALTER TABLE company_codes ADD COLUMN IF NOT EXISTS local_currency VARCHAR(3) DEFAULT 'USD';
ALTER TABLE company_codes ADD COLUMN IF NOT EXISTS reporting_currency VARCHAR(3) DEFAULT 'USD';

-- 2. Create FX rates table (simplified)
CREATE TABLE IF NOT EXISTS fx_rates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_currency VARCHAR(3) NOT NULL,
    to_currency VARCHAR(3) NOT NULL,
    rate_date DATE NOT NULL,
    exchange_rate DECIMAL(12,6) NOT NULL,
    rate_source VARCHAR(20) DEFAULT 'SYSTEM',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert sample FX rates
INSERT INTO fx_rates (from_currency, to_currency, rate_date, exchange_rate) VALUES
('EUR', 'USD', '2026-01-01', 1.0500),
('GBP', 'USD', '2026-01-01', 1.2500),
('AED', 'USD', '2026-01-01', 0.2722);

-- 3. Run universal-journal-table.sql
-- 4. Run posting-key-mapping.sql

-- 5. Create trial balance function
CREATE OR REPLACE FUNCTION get_trial_balance(
    p_company_code VARCHAR(10),
    p_ledger VARCHAR(20),
    p_posting_date DATE
)
RETURNS TABLE (
    gl_account VARCHAR(20),
    account_name VARCHAR(255),
    account_type VARCHAR(20),
    debit_balance DECIMAL(15,2),
    credit_balance DECIMAL(15,2),
    net_balance DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        uj.gl_account,
        coa.account_name,
        coa.account_type,
        COALESCE(SUM(CASE WHEN uj.debit_credit = 'D' THEN uj.company_amount ELSE 0 END), 0) as debit_balance,
        COALESCE(SUM(CASE WHEN uj.debit_credit = 'C' THEN uj.company_amount ELSE 0 END), 0) as credit_balance,
        COALESCE(SUM(CASE WHEN uj.debit_credit = 'D' THEN uj.company_amount ELSE -uj.company_amount END), 0) as net_balance
    FROM universal_journal uj
    JOIN chart_of_accounts coa ON uj.gl_account = coa.account_code
    WHERE uj.company_code = p_company_code
      AND uj.ledger = p_ledger
      AND uj.posting_date <= p_posting_date
    GROUP BY uj.gl_account, coa.account_name, coa.account_type
    ORDER BY uj.gl_account;
END;
$$ LANGUAGE plpgsql;