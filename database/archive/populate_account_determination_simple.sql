-- Populate Account Determination Data
-- This script ensures account determination table has data

-- First, ensure we have the required master data
INSERT INTO company_codes (company_code, company_name, legal_entity_name, currency, country) VALUES
('1000', 'Construction Corp Ltd', 'Construction Corp Ltd', 'USD', 'US')
ON CONFLICT (company_code) DO NOTHING;

-- Clear and repopulate account determination
DELETE FROM account_determination;

-- Insert account determination entries
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id, is_active) VALUES
-- Raw Materials (3000) - Construction Materials
((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '3000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'),
 (SELECT id FROM gl_accounts WHERE account_code = '140000'), true),

((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '3000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'GBB'),
 (SELECT id FROM gl_accounts WHERE account_code = '160000'), true),

((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '3000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'),
 (SELECT id FROM gl_accounts WHERE account_code = '500000'), true),

-- Finished Products (7920) - Equipment/Assets
((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '7920'),
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'),
 (SELECT id FROM gl_accounts WHERE account_code = '150000'), true),

((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '7920'),
 (SELECT id FROM account_keys WHERE account_key_code = 'GBB'),
 (SELECT id FROM gl_accounts WHERE account_code = '160000'), true),

-- Trading Goods (7900) - Construction Materials
((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '7900'),
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'),
 (SELECT id FROM gl_accounts WHERE account_code = '140000'), true),

((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '7900'),
 (SELECT id FROM account_keys WHERE account_key_code = 'GBB'),
 (SELECT id FROM gl_accounts WHERE account_code = '160000'), true),

((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '7900'),
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'),
 (SELECT id FROM gl_accounts WHERE account_code = '510000'), true),

-- Services (9000) - External Services
((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '9000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'),
 (SELECT id FROM gl_accounts WHERE account_code = '530000'), true);

-- Verify the results
SELECT 
    'Account Determination populated:' as status,
    COUNT(*) as count
FROM account_determination;

-- Show the account determination entries
SELECT 
    cc.company_code,
    vc.class_code as valuation_class,
    ak.account_key_code as account_key,
    gl.account_code as gl_account,
    gl.account_name
FROM account_determination ad
JOIN company_codes cc ON ad.company_code_id = cc.id
JOIN valuation_classes vc ON ad.valuation_class_id = vc.id  
JOIN account_keys ak ON ad.account_key_id = ak.id
JOIN gl_accounts gl ON ad.gl_account_id = gl.id
WHERE ad.is_active = true
ORDER BY vc.class_code, ak.account_key_code;