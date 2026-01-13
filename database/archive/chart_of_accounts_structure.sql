-- Chart of Accounts Master Structure (Option 2)

-- Create Chart of Accounts master table
CREATE TABLE IF NOT EXISTS chart_of_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coa_code VARCHAR(4) UNIQUE NOT NULL,
    coa_name VARCHAR(50) NOT NULL,
    country VARCHAR(2),
    currency VARCHAR(3),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Drop existing gl_accounts table and recreate with COA reference
DROP TABLE IF EXISTS gl_accounts CASCADE;

CREATE TABLE gl_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chart_of_accounts_id UUID NOT NULL REFERENCES chart_of_accounts(id),
    account_code VARCHAR(10) NOT NULL,
    account_name VARCHAR(50) NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(chart_of_accounts_id, account_code)
);

-- Add chart_of_accounts_id to company_codes table
ALTER TABLE company_codes 
ADD COLUMN IF NOT EXISTS chart_of_accounts_id UUID REFERENCES chart_of_accounts(id);

-- Insert sample Chart of Accounts
INSERT INTO chart_of_accounts (coa_code, coa_name, country, currency, description) VALUES
('INT1', 'International IFRS', 'XX', 'USD', 'International Financial Reporting Standards'),
('IN01', 'Indian Accounting Standards', 'IN', 'INR', 'Indian Accounting Standards (Ind AS)'),
('US01', 'US GAAP', 'US', 'USD', 'United States Generally Accepted Accounting Principles'),
('UAE1', 'UAE Local Standards', 'AE', 'AED', 'UAE Local Accounting Standards')
ON CONFLICT (coa_code) DO NOTHING;

-- Insert GL Accounts for International IFRS (INT1)
INSERT INTO gl_accounts (chart_of_accounts_id, account_code, account_name, account_type, description) VALUES
-- Get INT1 COA ID and insert accounts
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '100000', 'Cash and Bank', 'ASSET', 'Cash and Bank Accounts'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '110000', 'Accounts Receivable', 'ASSET', 'Trade Receivables'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '120000', 'Retention Receivable', 'ASSET', 'Retention Money Receivable'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '130000', 'Advances to Suppliers', 'ASSET', 'Advances Paid to Suppliers'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '140000', 'Raw Materials', 'ASSET', 'Raw Materials Inventory'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '141000', 'Work in Progress', 'ASSET', 'Work in Progress Inventory'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '142000', 'Finished Goods', 'ASSET', 'Finished Goods Inventory'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '150000', 'Plant & Equipment', 'ASSET', 'Plant and Equipment'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '151000', 'Accumulated Depreciation', 'ASSET', 'Accumulated Depreciation'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '160000', 'GR/IR Clearing', 'ASSET', 'Goods Receipt/Invoice Receipt Clearing'),
-- LIABILITIES
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '200000', 'Accounts Payable', 'LIABILITY', 'Trade Payables'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '210000', 'Retention Payable', 'LIABILITY', 'Retention Money Payable'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '220000', 'Advances from Customers', 'LIABILITY', 'Customer Advances Received'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '230000', 'Accrued Expenses', 'LIABILITY', 'Accrued Expenses'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '240000', 'Bank Loans', 'LIABILITY', 'Bank Loans and Overdrafts'),
-- REVENUE
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '400000', 'Project Revenue', 'REVENUE', 'Construction Project Revenue'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '410000', 'Variation Revenue', 'REVENUE', 'Project Variation Revenue'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '420000', 'Retention Revenue', 'REVENUE', 'Retention Revenue'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '430000', 'Other Revenue', 'REVENUE', 'Other Operating Revenue'),
-- DIRECT COSTS
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '500000', 'Material Costs', 'EXPENSE', 'Direct Material Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '501000', 'Cement & Concrete', 'EXPENSE', 'Cement and Concrete Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '502000', 'Steel & Reinforcement', 'EXPENSE', 'Steel and Reinforcement Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '503000', 'Electrical Materials', 'EXPENSE', 'Electrical Materials Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '504000', 'Plumbing Materials', 'EXPENSE', 'Plumbing Materials Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '505000', 'Finishing Materials', 'EXPENSE', 'Finishing Materials Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '510000', 'Labor Costs', 'EXPENSE', 'Direct Labor Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '511000', 'Skilled Labor', 'EXPENSE', 'Skilled Labor Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '512000', 'Unskilled Labor', 'EXPENSE', 'Unskilled Labor Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '513000', 'Overtime Costs', 'EXPENSE', 'Overtime Labor Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '520000', 'Subcontractor Costs', 'EXPENSE', 'Subcontractor Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '521000', 'Civil Subcontractors', 'EXPENSE', 'Civil Work Subcontractors'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '522000', 'MEP Subcontractors', 'EXPENSE', 'MEP Work Subcontractors'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '523000', 'Finishing Subcontractors', 'EXPENSE', 'Finishing Work Subcontractors'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '530000', 'Equipment Costs', 'EXPENSE', 'Equipment and Machinery Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '531000', 'Equipment Rental', 'EXPENSE', 'Equipment Rental Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '532000', 'Equipment Fuel', 'EXPENSE', 'Equipment Fuel Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '533000', 'Equipment Maintenance', 'EXPENSE', 'Equipment Maintenance Costs'),
-- INDIRECT COSTS
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '600000', 'Site Overhead', 'EXPENSE', 'Site Overhead Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '601000', 'Site Office Expenses', 'EXPENSE', 'Site Office Running Expenses'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '602000', 'Site Utilities', 'EXPENSE', 'Site Utilities Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '603000', 'Site Security', 'EXPENSE', 'Site Security Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '604000', 'Site Insurance', 'EXPENSE', 'Site Insurance Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '610000', 'Project Management', 'EXPENSE', 'Project Management Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '611000', 'Project Staff Salaries', 'EXPENSE', 'Project Staff Salaries'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '612000', 'Project Consultancy', 'EXPENSE', 'Project Consultancy Fees'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '620000', 'General Overhead', 'EXPENSE', 'General Administrative Overhead'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '621000', 'Head Office Expenses', 'EXPENSE', 'Head Office Administrative Costs'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '622000', 'Marketing Expenses', 'EXPENSE', 'Marketing and Business Development'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '623000', 'Finance Costs', 'EXPENSE', 'Interest and Finance Charges'),
-- WIP ACCOUNTS
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '700000', 'WIP - Materials', 'WIP', 'Work in Progress - Materials'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '701000', 'WIP - Labor', 'WIP', 'Work in Progress - Labor'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '702000', 'WIP - Subcontractors', 'WIP', 'Work in Progress - Subcontractors'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '703000', 'WIP - Equipment', 'WIP', 'Work in Progress - Equipment'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '704000', 'WIP - Overheads', 'WIP', 'Work in Progress - Overheads'),
-- COST OF SALES
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '800000', 'Cost of Sales - Materials', 'COGS', 'Cost of Sales - Materials'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '801000', 'Cost of Sales - Labor', 'COGS', 'Cost of Sales - Labor'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '802000', 'Cost of Sales - Subcontractors', 'COGS', 'Cost of Sales - Subcontractors'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '803000', 'Cost of Sales - Equipment', 'COGS', 'Cost of Sales - Equipment'),
((SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1'), '804000', 'Cost of Sales - Overheads', 'COGS', 'Cost of Sales - Overheads')
ON CONFLICT (chart_of_accounts_id, account_code) DO NOTHING;

-- Assign default COA to existing companies
UPDATE company_codes 
SET chart_of_accounts_id = (SELECT id FROM chart_of_accounts WHERE coa_code = 'INT1')
WHERE chart_of_accounts_id IS NULL;