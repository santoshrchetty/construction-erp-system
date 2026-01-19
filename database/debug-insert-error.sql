-- Debug Insert with Error Display
DO $$
DECLARE
    v_company_code VARCHAR(10) := 'C001';
    v_error_msg TEXT;
BEGIN
    -- Test single insert
    INSERT INTO universal_journal (
        event_id, event_type, event_timestamp, source_system,
        company_code, ledger, posting_date, document_date,
        gl_account, cost_element, posting_key, debit_credit,
        transaction_currency, transaction_amount, company_currency, company_amount,
        project_code, wbs_element, activity_code
    ) VALUES (
        uuid_generate_v4(), 'MATERIAL_ISSUE', NOW(), 'MM',
        v_company_code, 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
        '501000', '501000', '40', 'D',
        'INR', 125000.00, 'INR', 125000.00,
        'HW-0001', 'HW-0001.01', 'HW-0001.01-A01'
    );
    
    RAISE NOTICE 'Insert successful!';
    
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_msg = MESSAGE_TEXT;
        RAISE NOTICE 'Error: %', v_error_msg;
        RAISE NOTICE 'Detail: %', SQLERRM;
END $$;

-- Check if it inserted
SELECT COUNT(*) as entries FROM universal_journal WHERE project_code = 'HW-0001';
