-- Account Determination Data for Construction Industry
-- This maps Company + Valuation Class + Account Key → GL Account
-- Following SAP MM Account Determination logic

-- First ensure all required master data exists
INSERT INTO account_keys (account_key_code, account_key_name, description) VALUES
('BSX', 'Stock Account', 'Inventory stock account for material valuation'),
('GBB', 'Stock Offset', 'Inventory offset account for goods movements'),
('PRD', 'Price Difference', 'Price difference account for purchase price variances'),
('INV', 'Inventory Clearing', 'Inventory clearing account for goods receipt/invoice receipt'),
('CON', 'Consumption', 'Direct consumption account for materials'),
('WIP', 'Work in Progress', 'WIP account for project materials'),
('VAR', 'Variance', 'Material price variance account'),
('FRE', 'Freight', 'Freight clearing account for material transportation')
ON CONFLICT (account_key_code) DO NOTHING;

-- Insert comprehensive account determination mappings
-- Raw Materials (MAT001) mappings for Company C001
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id as company_code_id,
    vc.id as valuation_class_id, 
    ak.id as account_key_id,
    coa.id as gl_account_id
FROM company_codes cc
CROSS JOIN valuation_classes vc
CROSS JOIN account_keys ak
CROSS JOIN chart_of_accounts coa
WHERE cc.company_code = 'C001'
  AND vc.class_code = 'MAT001'
  AND ak.account_key_code = 'BSX'
  AND coa.account_code = '140000'  -- Raw Materials Inventory
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C001' AND vc.class_code = 'MAT001' 
  AND ak.account_key_code = 'GBB' AND coa.account_code = '500000'  -- Material Consumption
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C001' AND vc.class_code = 'MAT001' 
  AND ak.account_key_code = 'PRD' AND coa.account_code = '540000'  -- Price Differences
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C001' AND vc.class_code = 'MAT001' 
  AND ak.account_key_code = 'INV' AND coa.account_code = '191000'  -- GR/IR Clearing
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Finished Goods (MAT002) mappings for Company C001
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C001' AND vc.class_code = 'MAT002' 
  AND ak.account_key_code = 'BSX' AND coa.account_code = '150000'  -- Finished Goods Inventory
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C001' AND vc.class_code = 'MAT002' 
  AND ak.account_key_code = 'GBB' AND coa.account_code = '510000'  -- Cost of Goods Sold
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C001' AND vc.class_code = 'MAT002' 
  AND ak.account_key_code = 'WIP' AND coa.account_code = '130000'  -- Work in Progress
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Add mappings for Company C002 if it exists
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

INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code = 'C002' AND vc.class_code = 'MAT002' 
  AND ak.account_key_code = 'BSX' AND coa.account_code = '150000'
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Add variance and clearing account mappings for both companies
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code IN ('C001', 'C002') 
  AND vc.class_code IN ('MAT001', 'MAT002')
  AND ak.account_key_code = 'VAR' 
  AND coa.account_code = '540000'  -- Material Variances
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id)
SELECT 
    cc.id, vc.id, ak.id, coa.id
FROM company_codes cc, valuation_classes vc, account_keys ak, chart_of_accounts coa
WHERE cc.company_code IN ('C001', 'C002') 
  AND vc.class_code IN ('MAT001', 'MAT002')
  AND ak.account_key_code = 'FRE' 
  AND coa.account_code = '520000'  -- Freight/Transportation
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;