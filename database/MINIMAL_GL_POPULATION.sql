-- Minimal GL Posting Data Population
-- Only populate tables that exist with correct structure

-- Insert Cost Centers (this should work since we fixed it)
INSERT INTO cost_centers (company_code, cost_center_code, cost_center_name, cost_center_type, responsible_person) VALUES
('C001', 'CC001', 'Administration', 'OVERHEAD', 'Admin Manager'),
('C001', 'CC002', 'Construction Site 1', 'PROJECT', 'Site Manager A'),
('C001', 'CC003', 'Equipment Pool', 'SERVICE', 'Equipment Manager'),
('B001', 'CC001', 'Administration', 'OVERHEAD', 'Admin Manager US'),
('B001', 'CC002', 'Infrastructure Project', 'PROJECT', 'Project Manager US')
ON CONFLICT (company_code, cost_center_code) DO NOTHING;

-- Insert Document Types (this table should exist)
INSERT INTO document_types (document_type, document_type_name, number_range_object, account_type_allowed, requires_approval, approval_amount_limit) VALUES
('SA', 'General Ledger Document', 'RF_BELEG', 'ALL', true, 10000.00),
('AB', 'Accounting Document', 'RF_BELEG', 'ALL', true, 50000.00),
('KR', 'Vendor Invoice', 'RF_BELEG', 'ALL', true, 25000.00),
('DR', 'Customer Invoice', 'RF_BELEG', 'ALL', false, NULL)
ON CONFLICT (document_type) DO NOTHING;

-- Insert Document Number Ranges (this table should exist)
INSERT INTO document_number_ranges (company_code, document_type, number_range_object, from_number, to_number, current_number) VALUES
('C001', 'SA', 'RF_BELEG', 1000000000, 1999999999, 1000000000),
('C001', 'AB', 'RF_BELEG', 2000000000, 2999999999, 2000000000),
('B001', 'SA', 'RF_BELEG', 1000000000, 1999999999, 1000000000),
('B001', 'AB', 'RF_BELEG', 2000000000, 2999999999, 2000000000)
ON CONFLICT (company_code, document_type) DO NOTHING;

-- Insert sample GL Account Authorization (for demo user)
INSERT INTO gl_account_authorization (user_id, company_code, account_code, authorization_type, amount_limit)
SELECT 
    u.id,
    'C001',
    coa.account_code,
    'POST',
    100000.00
FROM users u
CROSS JOIN chart_of_accounts coa
WHERE u.email = 'engineer@construction.com'
AND coa.company_code = 'C001'
ON CONFLICT (user_id, company_code, account_code, authorization_type) DO NOTHING;

SELECT 'Basic GL posting data populated successfully' as status;