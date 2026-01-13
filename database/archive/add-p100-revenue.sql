-- Add Legitimate Revenue Entries for P100 Project
-- Progress billing and customer payments

-- Entry 4: Progress Billing #1 (Site Preparation Complete - 20% of project)
INSERT INTO universal_journal (
    event_id, event_type, event_timestamp, source_system, company_code, ledger,
    posting_date, document_date, gl_account, posting_key, debit_credit,
    transaction_currency, transaction_amount, company_currency, company_amount,
    fiscal_year, period, project_code, wbs_element, cost_center, created_at
) VALUES 
-- Accounts Receivable (Debit)
(gen_random_uuid(), 'PROGRESS_BILLING', NOW(), 'CONSTRUCTION_ERP', 'C001', '0L',
 '2024-04-30', '2024-04-30', '130000', '01', 'D',
 'USD', 1000000.00, 'USD', 1000000.00,
 2024, 4, 'P100', 'P100.1', 'CC001', NOW()),
-- Project Revenue (Credit)
(gen_random_uuid(), 'PROGRESS_BILLING', NOW(), 'CONSTRUCTION_ERP', 'C001', '0L',
 '2024-04-30', '2024-04-30', '400000', '50', 'C',
 'USD', 1000000.00, 'USD', 1000000.00,
 2024, 4, 'P100', 'P100.1', 'CC001', NOW()),

-- Entry 5: Customer Payment on Progress Bill #1
-- Cash Receipt (Debit)
(gen_random_uuid(), 'CUSTOMER_PAYMENT', NOW(), 'CONSTRUCTION_ERP', 'C001', '0L',
 '2024-05-15', '2024-05-15', '110000', '01', 'D',
 'USD', 950000.00, 'USD', 950000.00,
 2024, 5, 'P100', 'P100.1', 'CC001', NOW()),
-- Retention Held (Debit)
(gen_random_uuid(), 'CUSTOMER_PAYMENT', NOW(), 'CONSTRUCTION_ERP', 'C001', '0L',
 '2024-05-15', '2024-05-15', '135000', '01', 'D',
 'USD', 50000.00, 'USD', 50000.00,
 2024, 5, 'P100', 'P100.1', 'CC001', NOW()),
-- Accounts Receivable (Credit)
(gen_random_uuid(), 'CUSTOMER_PAYMENT', NOW(), 'CONSTRUCTION_ERP', 'C001', '0L',
 '2024-05-15', '2024-05-15', '130000', '50', 'C',
 'USD', 1000000.00, 'USD', 1000000.00,
 2024, 5, 'P100', 'P100.1', 'CC001', NOW()),

-- Entry 6: Progress Billing #2 (Structure Work - Additional 30% of project)
-- Accounts Receivable (Debit)
(gen_random_uuid(), 'PROGRESS_BILLING', NOW(), 'CONSTRUCTION_ERP', 'C001', '0L',
 '2024-08-31', '2024-08-31', '130000', '01', 'D',
 'USD', 1500000.00, 'USD', 1500000.00,
 2024, 8, 'P100', 'P100.2', 'CC001', NOW()),
-- Project Revenue (Credit)
(gen_random_uuid(), 'PROGRESS_BILLING', NOW(), 'CONSTRUCTION_ERP', 'C001', '0L',
 '2024-08-31', '2024-08-31', '400000', '50', 'C',
 'USD', 1500000.00, 'USD', 1500000.00,
 2024, 8, 'P100', 'P100.2', 'CC001', NOW());

-- Verify all P100 postings including revenue
SELECT 
    posting_date,
    event_type,
    gl_account,
    debit_credit,
    company_amount,
    wbs_element,
    CASE 
        WHEN gl_account IN ('400000', '410000') THEN 'Revenue'
        WHEN gl_account IN ('510000', '520000', '530000') THEN 'Project Costs'
        WHEN gl_account IN ('130000', '135000') THEN 'Receivables'
        WHEN gl_account = '110000' THEN 'Cash'
        WHEN gl_account IN ('140000', '150000') THEN 'Inventory/Assets'
        WHEN gl_account IN ('210000', '220000') THEN 'Payables'
        ELSE 'Other'
    END as account_type
FROM universal_journal 
WHERE project_code = 'P100'
ORDER BY posting_date, id;

-- Summary by account type
SELECT 
    CASE 
        WHEN gl_account IN ('400000', '410000') THEN 'Revenue'
        WHEN gl_account IN ('510000', '520000', '530000') THEN 'Project Costs'
        WHEN gl_account IN ('130000', '135000') THEN 'Receivables'
        WHEN gl_account = '110000' THEN 'Cash'
        WHEN gl_account IN ('140000', '150000') THEN 'Inventory/Assets'
        WHEN gl_account IN ('210000', '220000') THEN 'Payables'
        ELSE 'Other'
    END as account_type,
    debit_credit,
    SUM(company_amount) as total_amount
FROM universal_journal 
WHERE project_code = 'P100'
GROUP BY 
    CASE 
        WHEN gl_account IN ('400000', '410000') THEN 'Revenue'
        WHEN gl_account IN ('510000', '520000', '530000') THEN 'Project Costs'
        WHEN gl_account IN ('130000', '135000') THEN 'Receivables'
        WHEN gl_account = '110000' THEN 'Cash'
        WHEN gl_account IN ('140000', '150000') THEN 'Inventory/Assets'
        WHEN gl_account IN ('210000', '220000') THEN 'Payables'
        ELSE 'Other'
    END,
    debit_credit
ORDER BY account_type, debit_credit;