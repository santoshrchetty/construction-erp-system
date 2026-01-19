-- Temporarily drop FK constraint to allow insert
ALTER TABLE universal_journal DROP CONSTRAINT IF EXISTS fk_uj_cost_element;

-- Insert data
DO $$
DECLARE
    v_company_code VARCHAR(10) := 'C001';
BEGIN
    INSERT INTO universal_journal (
        event_id, event_type, event_timestamp, source_system, source_document_type, source_document_id,
        company_code, ledger, posting_date, document_date,
        gl_account, cost_element, posting_key, debit_credit,
        transaction_currency, transaction_amount, company_currency, company_amount,
        project_code, wbs_element, activity_code, cost_center,
        fiscal_year, period
    ) VALUES
    (uuid_generate_v4(), 'MATERIAL_ISSUE', NOW() - INTERVAL '10 days', 'MM', 'GOODS_ISSUE', 'GI-2024-001',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 10, CURRENT_DATE - 10,
     '501000', '501000', '40', 'D',
     'INR', 125000.00, 'INR', 125000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A01', 'CC-SITE-01',
     2024, 12),
    
    (uuid_generate_v4(), 'MATERIAL_ISSUE', NOW() - INTERVAL '9 days', 'MM', 'GOODS_ISSUE', 'GI-2024-002',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 9, CURRENT_DATE - 9,
     '502000', '502000', '40', 'D',
     'INR', 85000.00, 'INR', 85000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A01', 'CC-SITE-01',
     2024, 12),
    
    (uuid_generate_v4(), 'TIMESHEET', NOW() - INTERVAL '8 days', 'HR', 'TIMESHEET', 'TS-2024-001',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 8, CURRENT_DATE - 8,
     '511000', '511000', '40', 'D',
     'INR', 45000.00, 'INR', 45000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A01', 'CC-SITE-01',
     2024, 12),
    
    (uuid_generate_v4(), 'EQUIPMENT_USAGE', NOW() - INTERVAL '7 days', 'PM', 'EQUIPMENT_LOG', 'EQ-2024-001',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 7, CURRENT_DATE - 7,
     '531000', '531000', '40', 'D',
     'INR', 32000.00, 'INR', 32000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A01', 'CC-SITE-01',
     2024, 12),
    
    (uuid_generate_v4(), 'INVOICE', NOW() - INTERVAL '6 days', 'MM', 'VENDOR_INVOICE', 'VI-2024-001',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 6, CURRENT_DATE - 6,
     '521000', '521000', '31', 'D',
     'INR', 150000.00, 'INR', 150000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A01', 'CC-SITE-01',
     2024, 12),
    
    (uuid_generate_v4(), 'MATERIAL_ISSUE', NOW() - INTERVAL '5 days', 'MM', 'GOODS_ISSUE', 'GI-2024-003',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 5, CURRENT_DATE - 5,
     '503000', '503000', '40', 'D',
     'INR', 65000.00, 'INR', 65000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A02', 'CC-SITE-01',
     2024, 12),
    
    (uuid_generate_v4(), 'TIMESHEET', NOW() - INTERVAL '4 days', 'HR', 'TIMESHEET', 'TS-2024-002',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 4, CURRENT_DATE - 4,
     '512000', '512000', '40', 'D',
     'INR', 28000.00, 'INR', 28000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A02', 'CC-SITE-01',
     2024, 12),
    
    (uuid_generate_v4(), 'INVOICE', NOW() - INTERVAL '3 days', 'FI', 'VENDOR_INVOICE', 'VI-2024-002',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 3, CURRENT_DATE - 3,
     '601000', '601000', '31', 'D',
     'INR', 15000.00, 'INR', 15000.00,
     'HW-0001', 'HW-0001.01', NULL, 'CC-SITE-01',
     2024, 12),
    
    (uuid_generate_v4(), 'INVOICE', NOW() - INTERVAL '2 days', 'FI', 'VENDOR_INVOICE', 'VI-2024-003',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 2, CURRENT_DATE - 2,
     '602000', '602000', '31', 'D',
     'INR', 8000.00, 'INR', 8000.00,
     'HW-0001', 'HW-0001.01', NULL, 'CC-SITE-01',
     2024, 12),
    
    (uuid_generate_v4(), 'ALLOCATION', NOW() - INTERVAL '1 day', 'CO', 'ALLOCATION', 'AL-2024-001',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 1, CURRENT_DATE - 1,
     '900000', '900000', '99', 'D',
     'INR', 12000.00, 'INR', 12000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A01', 'CC-SITE-01',
     2024, 12);
    
    RAISE NOTICE 'Inserted % rows', 10;
END $$;

-- Verify
SELECT COUNT(*) as entries FROM universal_journal WHERE project_code = 'HW-0001';

-- Re-add FK constraint (optional - only if all cost_elements exist)
-- ALTER TABLE universal_journal 
-- ADD CONSTRAINT fk_uj_cost_element 
-- FOREIGN KEY (cost_element) REFERENCES cost_elements(cost_element);
