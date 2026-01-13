-- Populate GL Posting Master Data
-- Step 3: Sample Data Population

-- Insert Cost Centers
INSERT INTO cost_centers (company_code, cost_center_code, cost_center_name, cost_center_type, responsible_person, profit_center_code) VALUES
-- C001 (India) Cost Centers
('C001', 'CC001', 'Administration', 'OVERHEAD', 'Admin Manager', 'PC001'),
('C001', 'CC002', 'Construction Site 1', 'PROJECT', 'Site Manager A', 'PC002'),
('C001', 'CC003', 'Construction Site 2', 'PROJECT', 'Site Manager B', 'PC002'),
('C001', 'CC004', 'Equipment Pool', 'SERVICE', 'Equipment Manager', 'PC003'),
('C001', 'CC005', 'Quality Control', 'SERVICE', 'QC Manager', 'PC003'),
('C001', 'CC006', 'Safety Department', 'SERVICE', 'Safety Manager', 'PC003'),
-- B001 (USA) Cost Centers
('B001', 'CC001', 'Administration', 'OVERHEAD', 'Admin Manager US', 'PC001'),
('B001', 'CC002', 'Infrastructure Project', 'PROJECT', 'Project Manager US', 'PC002'),
('B001', 'CC003', 'Equipment Maintenance', 'SERVICE', 'Maintenance Head US', 'PC003')
ON CONFLICT (company_code, cost_center_code) DO NOTHING;

-- Insert Profit Centers with proper company_code_id
INSERT INTO profit_centers (company_code, profit_center_code, profit_center_name, profit_center_type, responsible_person, company_code_id)
SELECT 
    'C001',
    'PC001-C001',
    'Corporate Administration',
    'OVERHEAD',
    'CFO India',
    cc.id
FROM company_codes cc
WHERE cc.company_code = 'C001'
ON CONFLICT (profit_center_code) DO NOTHING;

INSERT INTO profit_centers (company_code, profit_center_code, profit_center_name, profit_center_type, responsible_person, company_code_id)
SELECT 
    'C001',
    'PC002-C001',
    'Construction Projects',
    'REVENUE',
    'Construction Head',
    cc.id
FROM company_codes cc
WHERE cc.company_code = 'C001'
ON CONFLICT (profit_center_code) DO NOTHING;

INSERT INTO profit_centers (company_code, profit_center_code, profit_center_name, profit_center_type, responsible_person, company_code_id)
SELECT 
    'C001',
    'PC003-C001',
    'Support Services',
    'SERVICE',
    'Operations Manager',
    cc.id
FROM company_codes cc
WHERE cc.company_code = 'C001'
ON CONFLICT (profit_center_code) DO NOTHING;

INSERT INTO profit_centers (company_code, profit_center_code, profit_center_name, profit_center_type, responsible_person, company_code_id)
SELECT 
    'B001',
    'PC001-B001',
    'Corporate Administration',
    'OVERHEAD',
    'CFO USA',
    cc.id
FROM company_codes cc
WHERE cc.company_code = 'B001'
ON CONFLICT (profit_center_code) DO NOTHING;

INSERT INTO profit_centers (company_code, profit_center_code, profit_center_name, profit_center_type, responsible_person, company_code_id)
SELECT 
    'B001',
    'PC002-B001',
    'Infrastructure Projects',
    'REVENUE',
    'Infrastructure Head',
    cc.id
FROM company_codes cc
WHERE cc.company_code = 'B001'
ON CONFLICT (profit_center_code) DO NOTHING;

INSERT INTO profit_centers (company_code, profit_center_code, profit_center_name, profit_center_type, responsible_person, company_code_id)
SELECT 
    'B001',
    'PC003-B001',
    'Support Services',
    'SERVICE',
    'Operations Manager US',
    cc.id
FROM company_codes cc
WHERE cc.company_code = 'B001'
ON CONFLICT (profit_center_code) DO NOTHING;

-- Insert WBS Elements
INSERT INTO wbs_elements (company_code, project_code, wbs_element, wbs_description, wbs_level, parent_wbs, project_manager, profit_center_code, project_start_date, project_end_date) VALUES
-- C001 (India) Projects
('C001', 'PROJ-001', 'PROJ-001', 'Office Building Construction', 1, NULL, 'Project Manager A', 'PC002', '2024-01-01', '2024-12-31'),
('C001', 'PROJ-001', 'PROJ-001.01', 'Foundation Work', 2, 'PROJ-001', 'Site Engineer A', 'PC002', '2024-01-01', '2024-03-31'),
('C001', 'PROJ-001', 'PROJ-001.02', 'Structure Work', 2, 'PROJ-001', 'Site Engineer B', 'PC002', '2024-04-01', '2024-09-30'),
('C001', 'PROJ-001', 'PROJ-001.03', 'Finishing Work', 2, 'PROJ-001', 'Site Engineer C', 'PC002', '2024-10-01', '2024-12-31'),
('C001', 'PROJ-002', 'PROJ-002', 'Highway Bridge Project', 1, NULL, 'Project Manager B', 'PC002', '2024-02-01', '2025-01-31'),
('C001', 'PROJ-002', 'PROJ-002.01', 'Bridge Foundation', 2, 'PROJ-002', 'Bridge Engineer A', 'PC002', '2024-02-01', '2024-06-30'),
('C001', 'PROJ-002', 'PROJ-002.02', 'Bridge Superstructure', 2, 'PROJ-002', 'Bridge Engineer B', 'PC002', '2024-07-01', '2025-01-31'),
-- B001 (USA) Projects
('B001', 'PROJ-003', 'PROJ-003', 'Infrastructure Development', 1, NULL, 'Project Manager US', 'PC002', '2024-03-01', '2025-02-28'),
('B001', 'PROJ-003', 'PROJ-003.01', 'Site Preparation', 2, 'PROJ-003', 'Site Engineer US', 'PC002', '2024-03-01', '2024-05-31'),
('B001', 'PROJ-003', 'PROJ-003.02', 'Infrastructure Build', 2, 'PROJ-003', 'Infrastructure Engineer', 'PC002', '2024-06-01', '2025-02-28')
ON CONFLICT (company_code, wbs_element) DO NOTHING;

-- Insert Fiscal Year Variants (2024) with all required fields
INSERT INTO fiscal_year_variants (company_code, fiscal_year_variant, fiscal_year, period_number, period_start_date, period_end_date, is_open, variant_code, variant_name, start_month, start_day) VALUES
-- C001 (India) - Calendar Year
('C001', 'K4', 2024, 1, '2024-01-01', '2024-01-31', true, 'K4', 'Calendar Year', 1, 1),
('C001', 'K4', 2024, 2, '2024-02-01', '2024-02-29', true, 'K4', 'Calendar Year', 1, 1),
('C001', 'K4', 2024, 3, '2024-03-01', '2024-03-31', true, 'K4', 'Calendar Year', 1, 1),
('C001', 'K4', 2024, 4, '2024-04-01', '2024-04-30', true, 'K4', 'Calendar Year', 1, 1),
('C001', 'K4', 2024, 5, '2024-05-01', '2024-05-31', true, 'K4', 'Calendar Year', 1, 1),
('C001', 'K4', 2024, 6, '2024-06-01', '2024-06-30', true, 'K4', 'Calendar Year', 1, 1),
('C001', 'K4', 2024, 7, '2024-07-01', '2024-07-31', true, 'K4', 'Calendar Year', 1, 1),
('C001', 'K4', 2024, 8, '2024-08-01', '2024-08-31', true, 'K4', 'Calendar Year', 1, 1),
('C001', 'K4', 2024, 9, '2024-09-01', '2024-09-30', true, 'K4', 'Calendar Year', 1, 1),
('C001', 'K4', 2024, 10, '2024-10-01', '2024-10-31', true, 'K4', 'Calendar Year', 1, 1),
('C001', 'K4', 2024, 11, '2024-11-01', '2024-11-30', true, 'K4', 'Calendar Year', 1, 1),
('C001', 'K4', 2024, 12, '2024-12-01', '2024-12-31', true, 'K4', 'Calendar Year', 1, 1),
-- B001 (USA) - Calendar Year
('B001', 'K4', 2024, 1, '2024-01-01', '2024-01-31', true, 'K4', 'Calendar Year', 1, 1),
('B001', 'K4', 2024, 2, '2024-02-01', '2024-02-29', true, 'K4', 'Calendar Year', 1, 1),
('B001', 'K4', 2024, 3, '2024-03-01', '2024-03-31', true, 'K4', 'Calendar Year', 1, 1),
('B001', 'K4', 2024, 4, '2024-04-01', '2024-04-30', true, 'K4', 'Calendar Year', 1, 1),
('B001', 'K4', 2024, 5, '2024-05-01', '2024-05-31', true, 'K4', 'Calendar Year', 1, 1),
('B001', 'K4', 2024, 6, '2024-06-01', '2024-06-30', true, 'K4', 'Calendar Year', 1, 1),
('B001', 'K4', 2024, 7, '2024-07-01', '2024-07-31', true, 'K4', 'Calendar Year', 1, 1),
('B001', 'K4', 2024, 8, '2024-08-01', '2024-08-31', true, 'K4', 'Calendar Year', 1, 1),
('B001', 'K4', 2024, 9, '2024-09-01', '2024-09-30', true, 'K4', 'Calendar Year', 1, 1),
('B001', 'K4', 2024, 10, '2024-10-01', '2024-10-31', true, 'K4', 'Calendar Year', 1, 1),
('B001', 'K4', 2024, 11, '2024-11-01', '2024-11-30', true, 'K4', 'Calendar Year', 1, 1),
('B001', 'K4', 2024, 12, '2024-12-01', '2024-12-31', true, 'K4', 'Calendar Year', 1, 1)
ON CONFLICT (variant_code) DO NOTHING;

-- Insert Document Number Ranges
INSERT INTO document_number_ranges (company_code, document_type, number_range_object, from_number, to_number, current_number) VALUES
('C001', 'SA', 'RF_BELEG', 1000000000, 1999999999, 1000000000),
('C001', 'AB', 'RF_BELEG', 2000000000, 2999999999, 2000000000),
('C001', 'KR', 'RF_BELEG', 3000000000, 3999999999, 3000000000),
('C001', 'DR', 'RF_BELEG', 4000000000, 4999999999, 4000000000),
('B001', 'SA', 'RF_BELEG', 1000000000, 1999999999, 1000000000),
('B001', 'AB', 'RF_BELEG', 2000000000, 2999999999, 2000000000),
('B001', 'KR', 'RF_BELEG', 3000000000, 3999999999, 3000000000),
('B001', 'DR', 'RF_BELEG', 4000000000, 4999999999, 4000000000)
ON CONFLICT (company_code, document_type) DO NOTHING;

-- Insert Document Types
INSERT INTO document_types (document_type, document_type_name, number_range_object, account_type_allowed, requires_approval, approval_amount_limit) VALUES
('SA', 'General Ledger Document', 'RF_BELEG', 'ALL', true, 10000.00),
('AB', 'Accounting Document', 'RF_BELEG', 'ALL', true, 50000.00),
('KR', 'Vendor Invoice', 'RF_BELEG', 'ALL', true, 25000.00),
('DR', 'Customer Invoice', 'RF_BELEG', 'ALL', false, NULL)
ON CONFLICT (document_type) DO NOTHING;

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

INSERT INTO gl_account_authorization (user_id, company_code, account_code, authorization_type, amount_limit)
SELECT 
    u.id,
    'B001',
    coa.account_code,
    'POST',
    100000.00
FROM users u
CROSS JOIN chart_of_accounts coa
WHERE u.email = 'engineer@construction.com'
AND coa.company_code = 'B001'
ON CONFLICT (user_id, company_code, account_code, authorization_type) DO NOTHING;

SELECT 'Master data populated successfully' as status;