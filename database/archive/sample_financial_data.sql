-- Sample Financial Documents and Journal Entries for Testing Reports

-- Insert sample financial documents
INSERT INTO financial_documents (company_code, document_type, posting_date, document_date, reference, header_text, total_amount, status) VALUES
('C001', 'SA', '2024-01-15', '2024-01-15', 'REF-001', 'Material Purchase', 50000.00, 'posted'),
('C001', 'SA', '2024-01-20', '2024-01-20', 'REF-002', 'Labor Costs', 25000.00, 'posted'),
('C001', 'SA', '2024-02-01', '2024-02-01', 'REF-003', 'Equipment Rental', 15000.00, 'posted'),
('C001', 'SA', '2024-02-10', '2024-02-10', 'REF-004', 'Project Revenue', 100000.00, 'posted'),
('C001', 'SA', '2024-02-15', '2024-02-15', 'REF-005', 'Subcontractor Payment', 35000.00, 'posted');

-- Get document IDs for journal entries
DO $$
DECLARE
    doc1_id UUID;
    doc2_id UUID;
    doc3_id UUID;
    doc4_id UUID;
    doc5_id UUID;
BEGIN
    -- Get document IDs
    SELECT id INTO doc1_id FROM financial_documents WHERE reference = 'REF-001';
    SELECT id INTO doc2_id FROM financial_documents WHERE reference = 'REF-002';
    SELECT id INTO doc3_id FROM financial_documents WHERE reference = 'REF-003';
    SELECT id INTO doc4_id FROM financial_documents WHERE reference = 'REF-004';
    SELECT id INTO doc5_id FROM financial_documents WHERE reference = 'REF-005';

    -- Journal entries for Material Purchase (REF-001)
    INSERT INTO journal_entries (document_id, line_number, gl_account, debit_amount, credit_amount, cost_center, description) VALUES
    (doc1_id, 1, '400100', 50000.00, 0, 'CC-PROJ01', 'Raw Materials Consumed'),
    (doc1_id, 2, '110000', 0, 50000.00, NULL, 'Cash Payment');

    -- Journal entries for Labor Costs (REF-002)
    INSERT INTO journal_entries (document_id, line_number, gl_account, debit_amount, credit_amount, cost_center, description) VALUES
    (doc2_id, 1, '600100', 25000.00, 0, 'CC-PROJ01', 'Direct Labor - Site Workers'),
    (doc2_id, 2, '110000', 0, 25000.00, NULL, 'Cash Payment');

    -- Journal entries for Equipment Rental (REF-003)
    INSERT INTO journal_entries (document_id, line_number, gl_account, debit_amount, credit_amount, cost_center, description) VALUES
    (doc3_id, 1, '650100', 15000.00, 0, 'CC-PROJ01', 'Equipment Rental'),
    (doc3_id, 2, '110000', 0, 15000.00, NULL, 'Cash Payment');

    -- Journal entries for Project Revenue (REF-004)
    INSERT INTO journal_entries (document_id, line_number, gl_account, debit_amount, credit_amount, cost_center, description) VALUES
    (doc4_id, 1, '110000', 100000.00, 0, NULL, 'Cash Receipt'),
    (doc4_id, 2, '800100', 0, 100000.00, 'CC-PROJ01', 'Construction Revenue');

    -- Journal entries for Subcontractor Payment (REF-005)
    INSERT INTO journal_entries (document_id, line_number, gl_account, debit_amount, credit_amount, cost_center, description) VALUES
    (doc5_id, 1, '450100', 35000.00, 0, 'CC-PROJ01', 'Subcontractor - Civil Work'),
    (doc5_id, 2, '110000', 0, 35000.00, NULL, 'Cash Payment');

END $$;