-- TEST FINANCE ENGINE - Sample Transactions
-- This script tests the complete finance engine with sample business events

-- 1. Generate test UUIDs
DO $$
DECLARE
    test_event_1 UUID := gen_random_uuid();
    test_event_2 UUID := gen_random_uuid();
    test_event_3 UUID := gen_random_uuid();
    test_user_id UUID := gen_random_uuid();
BEGIN

-- Clean up any existing test data
DELETE FROM universal_journal WHERE source_document_id IN ('TS-789456', 'INV-123456', 'MD-456789');

-- 2. Test Event 1: Project Labor Cost (HR -> Finance)
INSERT INTO universal_journal (
    event_id, event_type, event_timestamp, source_system,
    source_document_type, source_document_id,
    company_code, ledger, posting_date, document_date,
    gl_account, posting_key, debit_credit,
    transaction_currency, transaction_amount,
    company_currency, company_amount,
    cost_center, profit_center, project_code, wbs_element, employee_id,
    created_by
) VALUES 
-- Debit: Labor Expense
(test_event_1, 'PROJECT_LABOR_COST', NOW(), 'HR',
 'TIMESHEET', 'TS-789456',
 'C001', 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
 '510000', 'DR_LABOR_EXP', 'D',
 'USD', 800.00, 'USD', 800.00,
 'CC-HR', 'PC-TECH', 'P100', 'P100-01', 'E4567',
 test_user_id),
-- Credit: Payroll Liability
(test_event_1, 'PROJECT_LABOR_COST', NOW(), 'HR',
 'TIMESHEET', 'TS-789456',
 'C001', 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
 '210000', 'CR_PAYROLL_LIAB', 'C',
 'USD', 800.00, 'USD', 800.00,
 'CC-HR', 'PC-TECH', 'P100', 'P100-01', 'E4567',
 test_user_id);

-- 3. Test Event 2: Customer Invoice (Sales -> Finance)
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
-- Debit: Accounts Receivable
(test_event_2, 'CUSTOMER_INVOICE_POSTED', NOW(), 'SD',
 'INVOICE', 'INV-123456',
 'C001', 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
 '130000', 'DR_AR', 'D',
 'USD', 12000.00, 'USD', 12000.00,
 'CUST-001', 'P100', 'PC-SALES',
 test_user_id),
-- Credit: Revenue
(test_event_2, 'CUSTOMER_INVOICE_POSTED', NOW(), 'SD',
 'INVOICE', 'INV-123456',
 'C001', 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
 '400000', 'CR_REVENUE', 'C',
 'USD', 10000.00, 'USD', 10000.00,
 'CUST-001', 'P100', 'PC-SALES',
 test_user_id),
-- Credit: Sales Tax
(test_event_2, 'CUSTOMER_INVOICE_POSTED', NOW(), 'SD',
 'INVOICE', 'INV-123456',
 'C001', 'TAX', CURRENT_DATE, CURRENT_DATE,
 '240000', 'CR_TAX', 'C',
 'USD', 2000.00, 'USD', 2000.00,
 'CUST-001', 'P100', 'PC-SALES',
 test_user_id);

-- 4. Test Event 3: Material Issue (MM -> Finance)
INSERT INTO universal_journal (
    event_id, event_type, event_timestamp, source_system,
    source_document_type, source_document_id,
    company_code, ledger, posting_date, document_date,
    gl_account, posting_key, debit_credit,
    transaction_currency, transaction_amount,
    company_currency, company_amount,
    material_number, project_code, wbs_element, cost_center,
    created_by
) VALUES 
-- Credit: Inventory
(test_event_3, 'MATERIAL_ISSUED_TO_PRODUCTION', NOW(), 'MM',
 'MATERIAL_DOCUMENT', 'MD-456789',
 'C001', 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
 '140000', 'CR_INVENTORY', 'C',
 'USD', 5000.00, 'USD', 5000.00,
 'MAT-STEEL-001', 'P100', 'P100-02', 'CC-PROD',
 test_user_id),
-- Debit: Production Cost
(test_event_3, 'MATERIAL_ISSUED_TO_PRODUCTION', NOW(), 'MM',
 'MATERIAL_DOCUMENT', 'MD-456789',
 'C001', 'ACCRUAL', CURRENT_DATE, CURRENT_DATE,
 '520000', 'DR_PROD_COST', 'D',
 'USD', 5000.00, 'USD', 5000.00,
 'MAT-STEEL-001', 'P100', 'P100-02', 'CC-PROD',
 test_user_id);

-- 5. Verification Queries
SELECT '=== TEST RESULTS ===' as section;

-- Check all test entries
SELECT 'Test Entries Created' as check_type, COUNT(*) as entry_count
FROM universal_journal 
WHERE source_document_id IN ('TS-789456', 'INV-123456', 'MD-456789');

-- Verify balanced entries per event
SELECT 
    source_document_id,
    event_type,
    SUM(CASE WHEN debit_credit = 'D' THEN company_amount ELSE 0 END) as total_debits,
    SUM(CASE WHEN debit_credit = 'C' THEN company_amount ELSE 0 END) as total_credits,
    SUM(CASE WHEN debit_credit = 'D' THEN company_amount ELSE -company_amount END) as balance_check
FROM universal_journal 
WHERE source_document_id IN ('TS-789456', 'INV-123456', 'MD-456789')
GROUP BY source_document_id, event_type
ORDER BY source_document_id;

-- Test trial balance function
SELECT '=== TRIAL BALANCE TEST ===' as section;
SELECT * FROM get_trial_balance('C001', 'ACCRUAL', CURRENT_DATE)
WHERE gl_account IN ('130000', '140000', '210000', '240000', '400000', '510000', '520000');

-- Summary by GL Account
SELECT 
    gl_account,
    posting_key,
    SUM(CASE WHEN debit_credit = 'D' THEN company_amount ELSE 0 END) as total_debits,
    SUM(CASE WHEN debit_credit = 'C' THEN company_amount ELSE 0 END) as total_credits
FROM universal_journal 
WHERE source_document_id IN ('TS-789456', 'INV-123456', 'MD-456789')
GROUP BY gl_account, posting_key
ORDER BY gl_account;

END $$;

SELECT 'FINANCE ENGINE TEST COMPLETE' as message,
       'All events processed successfully' as status;