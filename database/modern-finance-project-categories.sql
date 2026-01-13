-- Modern Finance Engine Project Categories
-- Settlement-free, real-time posting with auto-derived posting keys

-- 1. Simplified project categories aligned with Universal Journal
CREATE TABLE IF NOT EXISTS modern_project_categories (
    category_code VARCHAR(20) PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    posting_logic VARCHAR(50) NOT NULL, -- How transactions are posted
    gl_account_determination VARCHAR(100), -- Auto-posting key logic
    real_time_recognition BOOLEAN DEFAULT true,
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

-- 2. Insert settlement-free project categories
INSERT INTO modern_project_categories VALUES
-- Revenue Projects - Direct posting to revenue/cost accounts
('CUSTOMER', 'Customer Project', 'DIRECT_POSTING', 'Revenue: 400000-499999, Costs: 500000-599999', true, 'Direct revenue/cost posting via auto-derived posting keys'),
('CONTRACT', 'Contract Project', 'DIRECT_POSTING', 'Contract Revenue: 410000-419999, Project Costs: 510000-519999', true, 'Contract-specific GL accounts with real-time recognition'),

-- Capital Projects - Direct posting to asset accounts (no CIP)
('CAPITAL', 'Capital Project', 'DIRECT_POSTING', 'Fixed Assets: 150000-159999, Construction Costs: 600000-699999', true, 'Direct asset posting without Construction-in-Progress'),
('FACILITY', 'Facility Project', 'DIRECT_POSTING', 'Buildings: 151000-151999, Facility Costs: 610000-619999', true, 'Direct facility asset creation'),

-- Overhead Projects - Direct posting to cost centers
('OVERHEAD', 'Overhead Project', 'DIRECT_POSTING', 'Cost Centers: 700000-799999', true, 'Direct cost center posting without allocation'),
('MAINTENANCE', 'Maintenance Project', 'DIRECT_POSTING', 'Maintenance Expense: 520000-529999', true, 'Direct maintenance expense posting'),

-- R&D Projects - Direct posting to R&D or IP assets
('RND', 'R&D Project', 'DIRECT_POSTING', 'R&D Expense: 540000-549999 or IP Assets: 160000-169999', true, 'Direct R&D posting with conditional capitalization');

-- 3. Update projects table to align with modern finance engine
ALTER TABLE projects DROP COLUMN IF EXISTS settlement_type;
ALTER TABLE projects DROP COLUMN IF EXISTS revenue_recognition;
ALTER TABLE projects DROP COLUMN IF EXISTS capitalization_flag;

-- Add modern finance engine columns
ALTER TABLE projects ADD COLUMN IF NOT EXISTS posting_logic VARCHAR(50) DEFAULT 'DIRECT_POSTING';
ALTER TABLE projects ADD COLUMN IF NOT EXISTS gl_determination_rule VARCHAR(100);
ALTER TABLE projects ADD COLUMN IF NOT EXISTS real_time_posting BOOLEAN DEFAULT true;

-- 4. Create posting key mapping for project categories
CREATE TABLE IF NOT EXISTS project_posting_keys (
    project_category VARCHAR(20),
    event_type VARCHAR(50),
    gl_account_type VARCHAR(20),
    debit_credit CHAR(1),
    posting_key VARCHAR(10),
    gl_account_range VARCHAR(50),
    description TEXT,
    FOREIGN KEY (project_category) REFERENCES modern_project_categories(category_code)
);

-- 5. Insert posting key mappings for automatic GL determination
INSERT INTO project_posting_keys VALUES
-- Customer Project Posting Keys
('CUSTOMER', 'REVENUE_RECOGNITION', 'REVENUE', 'C', '800', '400000-499999', 'Customer project revenue posting'),
('CUSTOMER', 'COST_POSTING', 'EXPENSE', 'D', '400', '500000-599999', 'Customer project cost posting'),
('CUSTOMER', 'RECEIVABLE_POSTING', 'RECEIVABLE', 'D', '140', '110000-119999', 'Customer receivable posting'),

-- Capital Project Posting Keys  
('CAPITAL', 'ASSET_ACQUISITION', 'FIXED_ASSET', 'D', '700', '150000-159999', 'Direct fixed asset posting'),
('CAPITAL', 'CONSTRUCTION_COST', 'EXPENSE', 'D', '400', '600000-699999', 'Construction cost posting'),
('CAPITAL', 'VENDOR_PAYABLE', 'PAYABLE', 'C', '310', '200000-209999', 'Vendor payable posting'),

-- Overhead Project Posting Keys
('OVERHEAD', 'OVERHEAD_COST', 'EXPENSE', 'D', '400', '700000-799999', 'Direct overhead cost posting'),
('OVERHEAD', 'COST_ALLOCATION', 'EXPENSE', 'D', '400', '750000-759999', 'Cost center allocation posting'),

-- R&D Project Posting Keys
('RND', 'RD_EXPENSE', 'EXPENSE', 'D', '400', '540000-549999', 'R&D expense posting'),
('RND', 'IP_ASSET', 'INTANGIBLE_ASSET', 'D', '750', '160000-169999', 'Intellectual property asset posting');

-- 6. Update P100 project with modern finance engine approach
UPDATE projects 
SET 
    project_category = 'CUSTOMER',
    posting_logic = 'DIRECT_POSTING',
    gl_determination_rule = 'Revenue: 400000-499999, Costs: 500000-599999',
    real_time_posting = true
WHERE code = 'P100';

-- 7. Verify alignment with Universal Journal
SELECT 
    p.code,
    p.name,
    p.project_category,
    mpc.posting_logic,
    p.gl_determination_rule,
    p.real_time_posting,
    COUNT(uj.id) as journal_entries
FROM projects p
LEFT JOIN modern_project_categories mpc ON p.project_category = mpc.category_code
LEFT JOIN universal_journal uj ON p.code = uj.project_code
WHERE p.code = 'P100'
GROUP BY p.code, p.name, p.project_category, mpc.posting_logic, p.gl_determination_rule, p.real_time_posting;