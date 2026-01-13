-- Insert sample account determination data
-- This requires existing company_codes, valuation_classes, account_keys, and chart_of_accounts

-- First, ensure we have the required reference data
INSERT INTO account_keys (account_key_code, account_key_name, description) VALUES
('BSX', 'Stock Account', 'Inventory stock account'),
('GBB', 'Stock Offset', 'Inventory offset account'),
('PRD', 'Price Difference', 'Price difference account'),
('INV', 'Inventory Account', 'Main inventory account')
ON CONFLICT (account_key_code) DO NOTHING;

-- Insert account determination mappings
-- This maps Company + Valuation Class + Account Key -> GL Account
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
  AND coa.account_code = '140000'
LIMIT 1
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

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
  AND ak.account_key_code = 'GBB'
  AND coa.account_code = '500000'
LIMIT 1
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

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
  AND vc.class_code = 'MAT002'
  AND ak.account_key_code = 'BSX'
  AND coa.account_code = '150000'
LIMIT 1
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;