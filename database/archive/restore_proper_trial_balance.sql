-- 1. Delete existing journal entries
DELETE FROM journal_entries;

-- 2. Add missing GL accounts to chart_of_accounts
INSERT INTO chart_of_accounts (coa_code, coa_name, account_code, account_name, account_type, company_code, is_active, cost_relevant) VALUES
('4001', 'Raw Materials', '400100', 'Raw Materials Consumed', 'EXPENSE', 'C001', true, true),
('4501', 'Subcontractor', '450100', 'Subcontractor - Civil Work', 'EXPENSE', 'C001', true, true),
('6001', 'Direct Labor', '600100', 'Direct Labor - Site Workers', 'EXPENSE', 'C001', true, true),
('6501', 'Equipment', '650100', 'Equipment Rental', 'EXPENSE', 'C001', true, true),
('8001', 'Revenue', '800100', 'Construction Revenue', 'REVENUE', 'C001', true, false);

-- 3. Re-insert proper journal entries with correct accounts
DO $$
DECLARE
    doc1_id UUID;
    doc2_id UUID;
    doc3_id UUID;
    doc4_id UUID;
    doc5_id UUID;
BEGIN
    SELECT id INTO doc1_id FROM financial_documents WHERE reference_document = 'REF-001';
    SELECT id INTO doc2_id FROM financial_documents WHERE reference_document = 'REF-002';
    SELECT id INTO doc3_id FROM financial_documents WHERE reference_document = 'REF-003';
    SELECT id INTO doc4_id FROM financial_documents WHERE reference_document = 'REF-004';
    SELECT id INTO doc5_id FROM financial_documents WHERE reference_document = 'REF-005';

    INSERT INTO journal_entries (document_id, line_item, account_code, debit_amount, credit_amount, cost_center, description) VALUES
    (doc1_id, 1, '400100', 50000.00, 0, 'CC-PROJ01', 'Raw Materials Consumed'),
    (doc1_id, 2, '110000', 0, 50000.00, NULL, 'Cash Payment'),
    (doc2_id, 1, '600100', 25000.00, 0, 'CC-PROJ01', 'Direct Labor - Site Workers'),
    (doc2_id, 2, '110000', 0, 25000.00, NULL, 'Cash Payment'),
    (doc3_id, 1, '650100', 15000.00, 0, 'CC-PROJ01', 'Equipment Rental'),
    (doc3_id, 2, '110000', 0, 15000.00, NULL, 'Cash Payment'),
    (doc4_id, 1, '110000', 100000.00, 0, NULL, 'Cash Receipt'),
    (doc4_id, 2, '800100', 0, 100000.00, 'CC-PROJ01', 'Construction Revenue'),
    (doc5_id, 1, '450100', 35000.00, 0, 'CC-PROJ01', 'Subcontractor - Civil Work'),
    (doc5_id, 2, '110000', 0, 35000.00, NULL, 'Cash Payment');
END $$;

-- 4. Test trial balance
SELECT * FROM get_trial_balance('C001', NULL, '2024-12-31');