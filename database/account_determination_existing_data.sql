-- Account Determination Data Using Existing Database Values
-- This script uses only the data that exists in the unified schema

-- First, let's insert some basic sample data that should exist
-- Company Codes (from unified schema)
INSERT INTO company_codes (company_code, company_name, legal_entity_name, currency, country) VALUES
('C001', 'Construction Corp Ltd', 'Construction Corporation Limited', 'USD', 'US'),
('C002', 'Infrastructure Solutions Inc', 'Infrastructure Solutions Incorporated', 'USD', 'US')
ON CONFLICT (company_code) DO NOTHING;

-- Chart of Accounts (basic accounts that should exist)
INSERT INTO chart_of_accounts (company_code, coa_code, account_code, account_name, account_type, cost_relevant) VALUES
('C001', 'COA001', '140000', 'Raw Materials Inventory', 'ASSET', true),
('C001', 'COA001', '150000', 'Finished Goods Inventory', 'ASSET', true),
('C001', 'COA001', '191000', 'GR/IR Clearing Account', 'ASSET', false),
('C001', 'COA001', '500000', 'Material Consumption', 'EXPENSE', true),
('C001', 'COA001', '510000', 'Cost of Goods Sold', 'EXPENSE', true),
('C001', 'COA001', '520000', 'Freight and Transportation', 'EXPENSE', true),
('C001', 'COA001', '540000', 'Material Price Variances', 'EXPENSE', true),
('C001', 'COA001', '130000', 'Work in Progress', 'ASSET', true),
('C002', 'COA002', '140000', 'Raw Materials Inventory', 'ASSET', true),
('C002', 'COA002', '150000', 'Finished Goods Inventory', 'ASSET', true),
('C002', 'COA002', '500000', 'Material Consumption', 'EXPENSE', true),
('C002', 'COA002', '510000', 'Cost of Goods Sold', 'EXPENSE', true)
ON CONFLICT (account_code) DO NOTHING;

-- Valuation Classes (from ERP config tables)
INSERT INTO valuation_classes (class_code, class_name, description) VALUES
('MAT001', 'Raw Materials', 'Raw construction materials like cement, steel, aggregates'),
('MAT002', 'Finished Goods', 'Finished construction products and assemblies')
ON CONFLICT (class_code) DO NOTHING;

-- Account Keys (from ERP config tables)
INSERT INTO account_keys (account_key_code, account_key_name, description) VALUES
('BSX', 'Stock Account', 'Inventory stock account for material valuation'),
('GBB', 'Stock Offset', 'Inventory offset account for goods movements'),
('PRD', 'Price Difference', 'Price difference account for purchase price variances'),
('INV', 'Inventory Clearing', 'Inventory clearing account for goods receipt/invoice receipt'),
('WIP', 'Work in Progress', 'WIP account for project materials')
ON CONFLICT (account_key_code) DO NOTHING;

-- Now create Account Determination mappings using existing IDs
-- Raw Materials (MAT001) + Stock Account (BSX) → Raw Materials Inventory (140000)
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id as company_code_id,
    vc.id as valuation_class_id, 
    ak.id as account_key_id,
    coa.id as gl_account_id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C001'
  AND vc.class_code = 'MAT001'
  AND ak.account_key_code = 'BSX'
  AND coa.account_code = '140000'
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Raw Materials (MAT001) + Stock Offset (GBB) → Material Consumption (500000)
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C001' AND vc.class_code = 'MAT001' 
  AND ak.account_key_code = 'GBB' AND coa.account_code = '500000'
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Raw Materials (MAT001) + Price Difference (PRD) → Material Price Variances (540000)
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C001' AND vc.class_code = 'MAT001' 
  AND ak.account_key_code = 'PRD' AND coa.account_code = '540000'
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Raw Materials (MAT001) + Inventory Clearing (INV) → GR/IR Clearing (191000)
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C001' AND vc.class_code = 'MAT001' 
  AND ak.account_key_code = 'INV' AND coa.account_code = '191000'
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Finished Goods (MAT002) + Stock Account (BSX) → Finished Goods Inventory (150000)
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C001' AND vc.class_code = 'MAT002' 
  AND ak.account_key_code = 'BSX' AND coa.account_code = '150000'
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Finished Goods (MAT002) + Stock Offset (GBB) → Cost of Goods Sold (510000)
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C001' AND vc.class_code = 'MAT002' 
  AND ak.account_key_code = 'GBB' AND coa.account_code = '510000'
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Finished Goods (MAT002) + WIP → Work in Progress (130000)
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C001' AND vc.class_code = 'MAT002' 
  AND ak.account_key_code = 'WIP' AND coa.account_code = '130000'
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Add mappings for Company C002
-- Raw Materials for C002
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C002' AND vc.class_code = 'MAT001' 
  AND ak.account_key_code = 'BSX' AND coa.account_code = '140000'
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C002' AND vc.class_code = 'MAT001' 
  AND ak.account_key_code = 'GBB' AND coa.account_code = '500000'
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Finished Goods for C002
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C002' AND vc.class_code = 'MAT002' 
  AND ak.account_key_code = 'BSX' AND coa.account_code = '150000'
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C002' AND vc.class_code = 'MAT002' 
  AND ak.account_key_code = 'GBB' AND coa.account_code = '510000'
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Verify the data was inserted
SELECT 
    cc.company_code,
    vc.class_code,
    ak.account_key_code,
    coa.account_code,
    coa.account_name
FROM account_determination ad
JOIN company_codes cc ON ad.company_code_id = cc.id
JOIN valuation_classes vc ON ad.valuation_class_id = vc.id
JOIN account_keys ak ON ad.account_key_id = ak.id
JOIN chart_of_accounts coa ON ad.gl_account_id = coa.id
ORDER BY cc.company_code, vc.class_code, ak.account_key_code;