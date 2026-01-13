-- Add missing accounts to chart_of_accounts
INSERT INTO chart_of_accounts (coa_code, coa_name, account_code, account_name, account_type, company_code, is_active, cost_relevant) VALUES
('4001', 'Raw Materials Consumed', '400100', 'Raw Materials Consumed', 'EXPENSE', 'C001', true, true),
('4501', 'Subcontractor - Civil Work', '450100', 'Subcontractor - Civil Work', 'EXPENSE', 'C001', true, true),
('6001', 'Direct Labor - Site Workers', '600100', 'Direct Labor - Site Workers', 'EXPENSE', 'C001', true, true),
('6501', 'Equipment Rental', '650100', 'Equipment Rental', 'EXPENSE', 'C001', true, true),
('8001', 'Construction Revenue', '800100', 'Construction Revenue', 'REVENUE', 'C001', true, false);