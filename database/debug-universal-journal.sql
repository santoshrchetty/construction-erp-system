-- Debug: Check why universal journal insert failed

-- 1. Check if project exists
SELECT 'Project Check' as test;
SELECT id, code, name FROM projects WHERE code = 'HW-0001';

-- 2. Check if activities exist
SELECT 'Activities Check' as test;
SELECT id, code, name FROM activities WHERE code LIKE 'HW-0001.01-A%';

-- 3. Check if company code exists
SELECT 'Company Code Check' as test;
SELECT company_code, company_name FROM company_codes WHERE company_code = '1000';

-- 4. Check universal_journal structure
SELECT 'Universal Journal Columns' as test;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'universal_journal'
  AND column_name IN ('activity_code', 'cost_element', 'company_code')
ORDER BY column_name;

-- 5. Try simple insert
SELECT 'Attempting Simple Insert' as test;
INSERT INTO universal_journal (
    event_id, event_type, event_timestamp, source_system,
    company_code, ledger, posting_date, document_date,
    gl_account, cost_element, posting_key, debit_credit,
    transaction_currency, transaction_amount, company_currency, company_amount,
    project_code, wbs_element, activity_code
) VALUES (
    uuid_generate_v4(), 'TEST', NOW(), 'TEST',
    '1000', 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
    '500000', '500000', '40', 'D',
    'INR', 1000.00, 'INR', 1000.00,
    'HW-0001', 'HW-0001.01', 'HW-0001.01-A01'
) RETURNING id, project_code, activity_code, company_amount;
