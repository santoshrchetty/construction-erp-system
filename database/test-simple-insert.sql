-- Test insert with error capture
DO $$
BEGIN
    INSERT INTO universal_journal (
        event_id, event_type, event_timestamp, source_system,
        company_code, ledger, posting_date, document_date,
        gl_account, posting_key, debit_credit,
        transaction_currency, transaction_amount, company_currency, company_amount,
        fiscal_year, period
    ) VALUES (
        uuid_generate_v4(), 'TEST', NOW(), 'TEST',
        'C001', 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
        '500000', '40', 'D',
        'INR', 1000.00, 'INR', 1000.00,
        2024, 12
    );
    RAISE NOTICE 'SUCCESS!';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'ERROR: %', SQLERRM;
END $$;
