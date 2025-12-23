-- PHASE 1: ERP Foundation - Material Types, Valuation Classes, Movement Types
-- Enterprise-grade posting logic without hardcoded GL accounts

-- =====================================================
-- MATERIAL MASTER ENHANCEMENTS
-- =====================================================

-- Material Types (like SAP T134)
CREATE TABLE IF NOT EXISTS material_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_type_code VARCHAR(4) UNIQUE NOT NULL, -- ROH, HALB, FERT, HAWA
    material_type_name VARCHAR(255) NOT NULL,
    description TEXT,
    inventory_managed BOOLEAN DEFAULT true,
    quantity_update BOOLEAN DEFAULT true,
    value_update BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true
);

-- Valuation Classes (like SAP T025)
CREATE TABLE IF NOT EXISTS valuation_classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    valuation_class_code VARCHAR(4) UNIQUE NOT NULL, -- 3000, 7920, etc.
    valuation_class_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

-- Material Type to Valuation Class Assignment
CREATE TABLE IF NOT EXISTS material_type_valuation_assignment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_type_id UUID NOT NULL REFERENCES material_types(id),
    valuation_class_id UUID NOT NULL REFERENCES valuation_classes(id),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    is_default BOOLEAN DEFAULT false,
    UNIQUE(material_type_id, company_code_id)
);

-- Add Material Type to stock_items
ALTER TABLE stock_items 
ADD COLUMN IF NOT EXISTS material_type_id UUID REFERENCES material_types(id),
ADD COLUMN IF NOT EXISTS valuation_class_id UUID REFERENCES valuation_classes(id);

-- =====================================================
-- MOVEMENT TYPES & ACCOUNT DETERMINATION
-- =====================================================

-- Movement Types (like SAP T156)
CREATE TABLE IF NOT EXISTS movement_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_type_code VARCHAR(3) UNIQUE NOT NULL, -- 101, 261, 301, etc.
    movement_type_name VARCHAR(255) NOT NULL,
    movement_indicator VARCHAR(1) NOT NULL, -- '+' Receipt, '-' Issue
    special_stock_indicator VARCHAR(1), -- 'Q' Project Stock
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

-- Account Keys (like SAP T030)
CREATE TABLE IF NOT EXISTS account_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_key_code VARCHAR(3) UNIQUE NOT NULL, -- BSX, GBB, WRX, PRD
    account_key_name VARCHAR(255) NOT NULL,
    description TEXT,
    debit_credit_indicator VARCHAR(1) NOT NULL, -- 'D' Debit, 'C' Credit
    is_active BOOLEAN DEFAULT true
);

-- Movement Type to Account Key Assignment
CREATE TABLE IF NOT EXISTS movement_type_account_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_type_id UUID NOT NULL REFERENCES movement_types(id),
    account_key_id UUID NOT NULL REFERENCES account_keys(id),
    sequence_number INTEGER DEFAULT 1,
    UNIQUE(movement_type_id, account_key_id)
);

-- =====================================================
-- CHART OF ACCOUNTS & ACCOUNT DETERMINATION
-- =====================================================

-- Chart of Accounts
CREATE TABLE IF NOT EXISTS chart_of_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chart_code VARCHAR(4) UNIQUE NOT NULL, -- CAIN, CAUS, etc.
    chart_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

-- GL Accounts Master
CREATE TABLE IF NOT EXISTS gl_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chart_id UUID NOT NULL REFERENCES chart_of_accounts(id),
    account_number VARCHAR(10) NOT NULL,
    account_name VARCHAR(255) NOT NULL,
    account_type VARCHAR(1) NOT NULL, -- 'A' Asset, 'L' Liability, 'E' Expense, 'R' Revenue
    account_group VARCHAR(4),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(chart_id, account_number)
);

-- Account Determination (Core ERP Logic)
CREATE TABLE IF NOT EXISTS account_determination (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    valuation_class_id UUID NOT NULL REFERENCES valuation_classes(id),
    account_key_id UUID NOT NULL REFERENCES account_keys(id),
    gl_account_id UUID NOT NULL REFERENCES gl_accounts(id),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(company_code_id, valuation_class_id, account_key_id)
);

-- =====================================================
-- SAMPLE CONFIGURATION DATA
-- =====================================================

-- Material Types
INSERT INTO material_types (material_type_code, material_type_name, description) VALUES
('ROH', 'Raw Materials', 'Raw materials for construction'),
('HALB', 'Semi-Finished', 'Semi-finished construction materials'),
('FERT', 'Finished Goods', 'Finished construction products'),
('HAWA', 'Trading Goods', 'Trading/resale materials')
ON CONFLICT (material_type_code) DO NOTHING;

-- Valuation Classes
INSERT INTO valuation_classes (valuation_class_code, valuation_class_name, description) VALUES
('3000', 'Raw Materials', 'Raw materials valuation'),
('7920', 'Finished Products', 'Finished products valuation'),
('7900', 'Trading Goods', 'Trading goods valuation'),
('9000', 'Project Materials', 'Project-specific materials')
ON CONFLICT (valuation_class_code) DO NOTHING;

-- Movement Types
INSERT INTO movement_types (movement_type_code, movement_type_name, movement_indicator, description) VALUES
('101', 'GR Purchase Order', '+', 'Goods Receipt from Purchase Order'),
('102', 'GR Reversal', '-', 'Goods Receipt Reversal'),
('261', 'Issue to Project', '-', 'Goods Issue to Project/Cost Center'),
('262', 'Issue Reversal', '+', 'Goods Issue Reversal'),
('301', 'Transfer Posting', '-', 'Plant to Plant Transfer (Issuing)'),
('302', 'Transfer Posting', '+', 'Plant to Plant Transfer (Receiving)'),
('311', 'SLoc Transfer', '-', 'Storage Location Transfer (Issuing)'),
('312', 'SLoc Transfer', '+', 'Storage Location Transfer (Receiving)')
ON CONFLICT (movement_type_code) DO NOTHING;

-- Account Keys
INSERT INTO account_keys (account_key_code, account_key_name, debit_credit_indicator, description) VALUES
('BSX', 'Inventory Account', 'D', 'Stock/Inventory Account'),
('GBB', 'Stock Clearing', 'C', 'Goods Receipt/Issue Clearing'),
('WRX', 'Consumption', 'D', 'Material Consumption Account'),
('PRD', 'Price Difference', 'D', 'Price Difference Account'),
('AUM', 'Offsetting Entry', 'C', 'Offsetting Entry for Consumption')
ON CONFLICT (account_key_code) DO NOTHING;

-- Chart of Accounts
INSERT INTO chart_of_accounts (chart_code, chart_name, description) VALUES
('CAIN', 'India Chart of Accounts', 'Standard Indian Chart of Accounts')
ON CONFLICT (chart_code) DO NOTHING;

-- Sample GL Accounts
INSERT INTO gl_accounts (chart_id, account_number, account_name, account_type) VALUES
((SELECT id FROM chart_of_accounts WHERE chart_code = 'CAIN'), '140000', 'Raw Materials Inventory', 'A'),
((SELECT id FROM chart_of_accounts WHERE chart_code = 'CAIN'), '150000', 'Finished Goods Inventory', 'A'),
((SELECT id FROM chart_of_accounts WHERE chart_code = 'CAIN'), '160000', 'Trading Goods Inventory', 'A'),
((SELECT id FROM chart_of_accounts WHERE chart_code = 'CAIN'), '500000', 'Material Consumption', 'E'),
((SELECT id FROM chart_of_accounts WHERE chart_code = 'CAIN'), '191000', 'GR/IR Clearing', 'L'),
((SELECT id FROM chart_of_accounts WHERE chart_code = 'CAIN'), '510000', 'Price Differences', 'E')
ON CONFLICT (chart_id, account_number) DO NOTHING;

-- Movement Type to Account Key Assignments
INSERT INTO movement_type_account_keys (movement_type_id, account_key_id) VALUES
((SELECT id FROM movement_types WHERE movement_type_code = '101'), (SELECT id FROM account_keys WHERE account_key_code = 'BSX')),
((SELECT id FROM movement_types WHERE movement_type_code = '101'), (SELECT id FROM account_keys WHERE account_key_code = 'GBB')),
((SELECT id FROM movement_types WHERE movement_type_code = '261'), (SELECT id FROM account_keys WHERE account_key_code = 'WRX')),
((SELECT id FROM movement_types WHERE movement_type_code = '261'), (SELECT id FROM account_keys WHERE account_key_code = 'BSX'))
ON CONFLICT (movement_type_id, account_key_id) DO NOTHING;

-- Account Determination Setup
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id) VALUES
((SELECT id FROM company_codes WHERE company_code = 'C001'), 
 (SELECT id FROM valuation_classes WHERE valuation_class_code = '3000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'),
 (SELECT id FROM gl_accounts WHERE account_number = '140000')),
((SELECT id FROM company_codes WHERE company_code = 'C001'), 
 (SELECT id FROM valuation_classes WHERE valuation_class_code = '3000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'),
 (SELECT id FROM gl_accounts WHERE account_number = '500000')),
((SELECT id FROM company_codes WHERE company_code = 'C001'), 
 (SELECT id FROM valuation_classes WHERE valuation_class_code = '3000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'GBB'),
 (SELECT id FROM gl_accounts WHERE account_number = '191000'))
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Update existing materials with default material type
UPDATE stock_items 
SET material_type_id = (SELECT id FROM material_types WHERE material_type_code = 'ROH' LIMIT 1),
    valuation_class_id = (SELECT id FROM valuation_classes WHERE valuation_class_code = '3000' LIMIT 1)
WHERE material_type_id IS NULL;

-- Performance Indexes
CREATE INDEX IF NOT EXISTS idx_stock_items_material_type ON stock_items(material_type_id);
CREATE INDEX IF NOT EXISTS idx_stock_items_valuation_class ON stock_items(valuation_class_id);
CREATE INDEX IF NOT EXISTS idx_account_determination_lookup ON account_determination(company_code_id, valuation_class_id, account_key_id);
CREATE INDEX IF NOT EXISTS idx_movement_types_code ON movement_types(movement_type_code);
CREATE INDEX IF NOT EXISTS idx_gl_accounts_number ON gl_accounts(chart_id, account_number);