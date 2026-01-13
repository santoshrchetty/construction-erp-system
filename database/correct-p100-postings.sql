-- Correct P100 Financial Postings for Construction Project
-- Delete incorrect test entries
DELETE FROM universal_journal WHERE project_code = 'P100';

-- Insert correct construction project postings
-- Entry 1: Material Purchase and Issue to Project
INSERT INTO universal_journal (
    company_code, project_code, wbs_element, cost_center, gl_account, 
    debit_credit, company_amount, event_type, posting_date, 
    fiscal_year, period, created_at
) VALUES 
-- Material Cost to Project (Debit)
('C001', 'P100', 'P100.2.1', 'CC001', '520000', 'D', 5000.00, 'MATERIAL_ISSUED_TO_PRODUCTION', '2024-03-15', 2024, 3, NOW()),
-- Inventory Reduction (Credit)
('C001', 'P100', 'P100.2.1', 'CC001', '140000', 'C', 5000.00, 'MATERIAL_ISSUED_TO_PRODUCTION', '2024-03-15', 2024, 3, NOW()),

-- Entry 2: Labor Cost Posting
-- Labor Cost to Project (Debit)
('C001', 'P100', 'P100.1.1', 'CC001', '510000', 'D', 800.00, 'PROJECT_LABOR_COST', '2024-02-20', 2024, 2, NOW()),
-- Accrued Payroll (Credit)
('C001', 'P100', 'P100.1.1', 'CC001', '210000', 'C', 800.00, 'PROJECT_LABOR_COST', '2024-02-20', 2024, 2, NOW()),

-- Entry 3: Equipment/Subcontractor Cost
-- Equipment Rental Cost (Debit)
('C001', 'P100', 'P100.1.2', 'CC001', '530000', 'D', 2500.00, 'EQUIPMENT_RENTAL', '2024-03-01', 2024, 3, NOW()),
-- Accounts Payable (Credit)
('C001', 'P100', 'P100.1.2', 'CC001', '210000', 'C', 2500.00, 'EQUIPMENT_RENTAL', '2024-03-01', 2024, 3, NOW());

-- Verify corrected postings
SELECT 
    posting_date,
    event_type,
    gl_account,
    debit_credit,
    company_amount,
    wbs_element
FROM universal_journal 
WHERE project_code = 'P100'
ORDER BY posting_date, id;

-- Summary by debit/credit
SELECT 
    debit_credit,
    COUNT(*) as transaction_count,
    SUM(company_amount) as total_amount
FROM universal_journal 
WHERE project_code = 'P100'
GROUP BY debit_credit;