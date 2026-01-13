-- SIMPLE FINANCE ENGINE TEST
-- Clean up first
DELETE FROM universal_journal WHERE source_document_id IN ('TS-TEST', 'INV-TEST', 'MD-TEST');

-- Test 1: Project Labor Cost
INSERT INTO universal_journal (
    event_id, event_type, event_timestamp, source_system,
    source_document_type, source_document_id,
    company_code, ledger, posting_date, document_date,
    gl_account, posting_key, debit_credit,
    transaction_currency, transaction_amount,
    company_currency, company_amount,
    cost_center, profit_center, project_code, employee_id,
    created_by
) VALUES 
(gen_random_uuid(), 'PROJECT_LABOR_COST', NOW(), 'HR',
 'TIMESHEET', 'TS-TEST', 'C001', 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
 '510000', 'DR_LABOR_EXP', 'D', 'USD', 800.00, 'USD', 800.00,
 'CC-HR', 'PC-TECH', 'P100', 'E4567', gen_random_uuid()),
(gen_random_uuid(), 'PROJECT_LABOR_COST', NOW(), 'HR',
 'TIMESHEET', 'TS-TEST', 'C001', 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
 '210000', 'CR_PAYROLL_LIAB', 'C', 'USD', 800.00, 'USD', 800.00,
 'CC-HR', 'PC-TECH', 'P100', 'E4567', gen_random_uuid());

-- Test 2: Customer Invoice
INSERT INTO universal_journal (
    event_id, event_type, event_timestamp, source_system,
    source_document_type, source_document_id,
    company_code, ledger, posting_date, document_date,
    gl_account, posting_key, debit_credit,
    transaction_currency, transaction_amount,
    company_currency, company_amount,
    customer_code, project_code, profit_center,
    created_by
) VALUES 
(gen_random_uuid(), 'CUSTOMER_INVOICE_POSTED', NOW(), 'SD',
 'INVOICE', 'INV-TEST', 'C001', 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
 '130000', 'DR_AR', 'D', 'USD', 10000.00, 'USD', 10000.00,
 'CUST-001', 'P100', 'PC-SALES', gen_random_uuid()),
(gen_random_uuid(), 'CUSTOMER_INVOICE_POSTED', NOW(), 'SD',
 'INVOICE', 'INV-TEST', 'C001', 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
 '400000', 'CR_REVENUE', 'C', 'USD', 10000.00, 'USD', 10000.00,
 'CUST-001', 'P100', 'PC-SALES', gen_random_uuid());

-- Test 3: Material Issue
INSERT INTO universal_journal (
    event_id, event_type, event_timestamp, source_system,
    source_document_type, source_document_id,
    company_code, ledger, posting_date, document_date,
    gl_account, posting_key, debit_credit,
    transaction_currency, transaction_amount,
    company_currency, company_amount,
    material_number, project_code, cost_center,
    created_by
) VALUES 
(gen_random_uuid(), 'MATERIAL_ISSUED_TO_PRODUCTION', NOW(), 'MM',
 'MATERIAL_DOCUMENT', 'MD-TEST', 'C001', 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
 '140000', 'CR_INVENTORY', 'C', 'USD', 5000.00, 'USD', 5000.00,
 'MAT-STEEL-001', 'P100', 'CC-PROD', gen_random_uuid()),
(gen_random_uuid(), 'MATERIAL_ISSUED_TO_PRODUCTION', NOW(), 'MM',
 'MATERIAL_DOCUMENT', 'MD-TEST', 'C001', 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
 '520000', 'DR_PROD_COST', 'D', 'USD', 5000.00, 'USD', 5000.00,
 'MAT-STEEL-001', 'P100', 'CC-PROD', gen_random_uuid());

-- Verification: Count entries
SELECT 'Test Entries Created' as status, COUNT(*) as entry_count
FROM universal_journal 
WHERE source_document_id IN ('TS-TEST', 'INV-TEST', 'MD-TEST');

-- Verification: Balance check
SELECT 
    source_document_id,
    event_type,
    SUM(CASE WHEN debit_credit = 'D' THEN company_amount ELSE 0 END) as debits,
    SUM(CASE WHEN debit_credit = 'C' THEN company_amount ELSE 0 END) as credits,
    SUM(CASE WHEN debit_credit = 'D' THEN company_amount ELSE -company_amount END) as balance
FROM universal_journal 
WHERE source_document_id IN ('TS-TEST', 'INV-TEST', 'MD-TEST')
GROUP BY source_document_id, event_type
ORDER BY source_document_id;

-- Verification: GL Account Summary
SELECT 
    gl_account,
    posting_key,
    SUM(CASE WHEN debit_credit = 'D' THEN company_amount ELSE 0 END) as debits,
    SUM(CASE WHEN debit_credit = 'C' THEN company_amount ELSE 0 END) as credits
FROM universal_journal 
WHERE source_document_id IN ('TS-TEST', 'INV-TEST', 'MD-TEST')
GROUP BY gl_account, posting_key
ORDER BY gl_account;

SELECT 'FINANCE ENGINE TEST COMPLETE' as message;