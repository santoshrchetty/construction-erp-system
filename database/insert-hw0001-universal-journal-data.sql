-- Sample Universal Journal Data for HW-0001 Project
-- Demonstrates activity-level cost tracking with cost elements

-- Get project and activity IDs
DO $$
DECLARE
    v_project_id UUID;
    v_activity_a01_id UUID;
    v_activity_a02_id UUID;
    v_company_code VARCHAR(10) := 'C001';
BEGIN
    -- Get project ID
    SELECT id INTO v_project_id FROM projects WHERE code = 'HW-0001';
    
    -- Get activity IDs
    SELECT id INTO v_activity_a01_id FROM activities WHERE code = 'HW-0001.01-A01';
    SELECT id INTO v_activity_a02_id FROM activities WHERE code = 'HW-0001.01-A02';
    
    -- Direct Material Costs (Activity A01)
    INSERT INTO universal_journal (
        event_id, event_type, event_timestamp, source_system, source_document_type, source_document_id,
        company_code, ledger, posting_date, document_date,
        gl_account, cost_element, posting_key, debit_credit,
        transaction_currency, transaction_amount, company_currency, company_amount,
        project_code, wbs_element, activity_code, cost_center,
        fiscal_year, period
    ) VALUES
    -- Cement for Activity A01
    (uuid_generate_v4(), 'MATERIAL_ISSUE', NOW() - INTERVAL '10 days', 'MM', 'GOODS_ISSUE', 'GI-2024-001',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 10, CURRENT_DATE - 10,
     '501000', '501000', '40', 'D',
     'INR', 125000.00, 'INR', 125000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A01', 'CC-SITE-01',
     2024, 12),
    
    -- Steel for Activity A01
    (uuid_generate_v4(), 'MATERIAL_ISSUE', NOW() - INTERVAL '9 days', 'MM', 'GOODS_ISSUE', 'GI-2024-002',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 9, CURRENT_DATE - 9,
     '502000', '502000', '40', 'D',
     'INR', 85000.00, 'INR', 85000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A01', 'CC-SITE-01',
     2024, 12),
    
    -- Direct Labor Costs (Activity A01)
    (uuid_generate_v4(), 'TIMESHEET', NOW() - INTERVAL '8 days', 'HR', 'TIMESHEET', 'TS-2024-001',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 8, CURRENT_DATE - 8,
     '511000', '511000', '40', 'D',
     'INR', 45000.00, 'INR', 45000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A01', 'CC-SITE-01',
     2024, 12),
    
    -- Equipment Costs (Activity A01)
    (uuid_generate_v4(), 'EQUIPMENT_USAGE', NOW() - INTERVAL '7 days', 'PM', 'EQUIPMENT_LOG', 'EQ-2024-001',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 7, CURRENT_DATE - 7,
     '531000', '531000', '40', 'D',
     'INR', 32000.00, 'INR', 32000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A01', 'CC-SITE-01',
     2024, 12),
    
    -- Subcontractor Costs (Activity A01)
    (uuid_generate_v4(), 'INVOICE', NOW() - INTERVAL '6 days', 'MM', 'VENDOR_INVOICE', 'VI-2024-001',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 6, CURRENT_DATE - 6,
     '521000', '521000', '31', 'D',
     'INR', 150000.00, 'INR', 150000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A01', 'CC-SITE-01',
     2024, 12),
    
    -- Direct Material Costs (Activity A02)
    (uuid_generate_v4(), 'MATERIAL_ISSUE', NOW() - INTERVAL '5 days', 'MM', 'GOODS_ISSUE', 'GI-2024-003',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 5, CURRENT_DATE - 5,
     '503000', '503000', '40', 'D',
     'INR', 65000.00, 'INR', 65000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A02', 'CC-SITE-01',
     2024, 12),
    
    -- Direct Labor Costs (Activity A02)
    (uuid_generate_v4(), 'TIMESHEET', NOW() - INTERVAL '4 days', 'HR', 'TIMESHEET', 'TS-2024-002',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 4, CURRENT_DATE - 4,
     '512000', '512000', '40', 'D',
     'INR', 28000.00, 'INR', 28000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A02', 'CC-SITE-01',
     2024, 12),
    
    -- Indirect Costs (WBS Level - no specific activity)
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
    
    -- Secondary Cost Element - Overhead Allocation (Activity A01)
    (uuid_generate_v4(), 'ALLOCATION', NOW() - INTERVAL '1 day', 'CO', 'ALLOCATION', 'AL-2024-001',
     v_company_code, 'ACCRUAL', CURRENT_DATE - 1, CURRENT_DATE - 1,
     '900000', '900000', '99', 'D',
     'INR', 12000.00, 'INR', 12000.00,
     'HW-0001', 'HW-0001.01', 'HW-0001.01-A01', 'CC-SITE-01',
     2024, 12);
    
    RAISE NOTICE 'Sample universal journal data created for project HW-0001';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating sample data: %', SQLERRM;
END $$;
