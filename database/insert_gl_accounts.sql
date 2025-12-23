-- Insert comprehensive GL accounts for construction project reporting
INSERT INTO gl_accounts (account_code, account_name, account_type, description) VALUES
-- ASSETS
('100000', 'Cash and Bank', 'ASSET', 'Cash and Bank Accounts'),
('110000', 'Accounts Receivable', 'ASSET', 'Trade Receivables'),
('120000', 'Retention Receivable', 'ASSET', 'Retention Money Receivable'),
('130000', 'Advances to Suppliers', 'ASSET', 'Advances Paid to Suppliers'),
('140000', 'Raw Materials', 'ASSET', 'Raw Materials Inventory'),
('141000', 'Work in Progress', 'ASSET', 'Work in Progress Inventory'),
('142000', 'Finished Goods', 'ASSET', 'Finished Goods Inventory'),
('150000', 'Plant & Equipment', 'ASSET', 'Plant and Equipment'),
('151000', 'Accumulated Depreciation', 'ASSET', 'Accumulated Depreciation'),
('160000', 'GR/IR Clearing', 'ASSET', 'Goods Receipt/Invoice Receipt Clearing'),
-- LIABILITIES
('200000', 'Accounts Payable', 'LIABILITY', 'Trade Payables'),
('210000', 'Retention Payable', 'LIABILITY', 'Retention Money Payable'),
('220000', 'Advances from Customers', 'LIABILITY', 'Customer Advances Received'),
('230000', 'Accrued Expenses', 'LIABILITY', 'Accrued Expenses'),
('240000', 'Bank Loans', 'LIABILITY', 'Bank Loans and Overdrafts'),
-- REVENUE
('400000', 'Project Revenue', 'REVENUE', 'Construction Project Revenue'),
('410000', 'Variation Revenue', 'REVENUE', 'Project Variation Revenue'),
('420000', 'Retention Revenue', 'REVENUE', 'Retention Revenue'),
('430000', 'Other Revenue', 'REVENUE', 'Other Operating Revenue'),
-- DIRECT COSTS
('500000', 'Material Costs', 'EXPENSE', 'Direct Material Costs'),
('501000', 'Cement & Concrete', 'EXPENSE', 'Cement and Concrete Costs'),
('502000', 'Steel & Reinforcement', 'EXPENSE', 'Steel and Reinforcement Costs'),
('503000', 'Electrical Materials', 'EXPENSE', 'Electrical Materials Costs'),
('504000', 'Plumbing Materials', 'EXPENSE', 'Plumbing Materials Costs'),
('505000', 'Finishing Materials', 'EXPENSE', 'Finishing Materials Costs'),
('510000', 'Labor Costs', 'EXPENSE', 'Direct Labor Costs'),
('511000', 'Skilled Labor', 'EXPENSE', 'Skilled Labor Costs'),
('512000', 'Unskilled Labor', 'EXPENSE', 'Unskilled Labor Costs'),
('513000', 'Overtime Costs', 'EXPENSE', 'Overtime Labor Costs'),
('520000', 'Subcontractor Costs', 'EXPENSE', 'Subcontractor Costs'),
('521000', 'Civil Subcontractors', 'EXPENSE', 'Civil Work Subcontractors'),
('522000', 'MEP Subcontractors', 'EXPENSE', 'MEP Work Subcontractors'),
('523000', 'Finishing Subcontractors', 'EXPENSE', 'Finishing Work Subcontractors'),
('530000', 'Equipment Costs', 'EXPENSE', 'Equipment and Machinery Costs'),
('531000', 'Equipment Rental', 'EXPENSE', 'Equipment Rental Costs'),
('532000', 'Equipment Fuel', 'EXPENSE', 'Equipment Fuel Costs'),
('533000', 'Equipment Maintenance', 'EXPENSE', 'Equipment Maintenance Costs'),
-- INDIRECT COSTS
('600000', 'Site Overhead', 'EXPENSE', 'Site Overhead Costs'),
('601000', 'Site Office Expenses', 'EXPENSE', 'Site Office Running Expenses'),
('602000', 'Site Utilities', 'EXPENSE', 'Site Utilities Costs'),
('603000', 'Site Security', 'EXPENSE', 'Site Security Costs'),
('604000', 'Site Insurance', 'EXPENSE', 'Site Insurance Costs'),
('610000', 'Project Management', 'EXPENSE', 'Project Management Costs'),
('611000', 'Project Staff Salaries', 'EXPENSE', 'Project Staff Salaries'),
('612000', 'Project Consultancy', 'EXPENSE', 'Project Consultancy Fees'),
('620000', 'General Overhead', 'EXPENSE', 'General Administrative Overhead'),
('621000', 'Head Office Expenses', 'EXPENSE', 'Head Office Administrative Costs'),
('622000', 'Marketing Expenses', 'EXPENSE', 'Marketing and Business Development'),
('623000', 'Finance Costs', 'EXPENSE', 'Interest and Finance Charges'),
-- WIP ACCOUNTS
('700000', 'WIP - Materials', 'WIP', 'Work in Progress - Materials'),
('701000', 'WIP - Labor', 'WIP', 'Work in Progress - Labor'),
('702000', 'WIP - Subcontractors', 'WIP', 'Work in Progress - Subcontractors'),
('703000', 'WIP - Equipment', 'WIP', 'Work in Progress - Equipment'),
('704000', 'WIP - Overheads', 'WIP', 'Work in Progress - Overheads'),
-- COST OF SALES
('800000', 'Cost of Sales - Materials', 'COGS', 'Cost of Sales - Materials'),
('801000', 'Cost of Sales - Labor', 'COGS', 'Cost of Sales - Labor'),
('802000', 'Cost of Sales - Subcontractors', 'COGS', 'Cost of Sales - Subcontractors'),
('803000', 'Cost of Sales - Equipment', 'COGS', 'Cost of Sales - Equipment'),
('804000', 'Cost of Sales - Overheads', 'COGS', 'Cost of Sales - Overheads')
ON CONFLICT (account_code) DO NOTHING;

-- Insert sample valuation classes
INSERT INTO valuation_classes (class_code, class_name, description) VALUES
('3000', 'Raw Materials', 'Valuation class for raw materials'),
('7920', 'Finished Products', 'Valuation class for finished products'),
('7900', 'Trading Goods', 'Valuation class for trading goods'),
('9000', 'Services', 'Valuation class for services')
ON CONFLICT (class_code) DO NOTHING;