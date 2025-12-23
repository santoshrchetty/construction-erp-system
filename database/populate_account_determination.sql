-- Populate Account Determination directly
-- First check what data we have
SELECT 'Company Codes:' as table_name, company_code, id FROM company_codes
UNION ALL
SELECT 'Valuation Classes:', class_code, id FROM valuation_classes  
UNION ALL
SELECT 'Account Keys:', account_key_code, id FROM account_keys
UNION ALL
SELECT 'GL Accounts:', account_code, id FROM gl_accounts WHERE account_code IN ('140000', '160000', '500000', '150000', '510000', '530000');

-- Delete existing account determination
DELETE FROM account_determination;

-- Insert account determination with actual IDs
WITH company AS (SELECT id as company_id FROM company_codes WHERE company_code = '1000' LIMIT 1),
     val_3000 AS (SELECT id as val_id FROM valuation_classes WHERE class_code = '3000' LIMIT 1),
     val_7900 AS (SELECT id as val_id FROM valuation_classes WHERE class_code = '7900' LIMIT 1), 
     val_7920 AS (SELECT id as val_id FROM valuation_classes WHERE class_code = '7920' LIMIT 1),
     val_9000 AS (SELECT id as val_id FROM valuation_classes WHERE class_code = '9000' LIMIT 1),
     key_bsx AS (SELECT id as key_id FROM account_keys WHERE account_key_code = 'BSX' LIMIT 1),
     key_gbb AS (SELECT id as key_id FROM account_keys WHERE account_key_code = 'GBB' LIMIT 1),
     key_wrx AS (SELECT id as key_id FROM account_keys WHERE account_key_code = 'WRX' LIMIT 1),
     gl_140000 AS (SELECT id as gl_id FROM gl_accounts WHERE account_code = '140000' LIMIT 1),
     gl_160000 AS (SELECT id as gl_id FROM gl_accounts WHERE account_code = '160000' LIMIT 1),
     gl_500000 AS (SELECT id as gl_id FROM gl_accounts WHERE account_code = '500000' LIMIT 1),
     gl_150000 AS (SELECT id as gl_id FROM gl_accounts WHERE account_code = '150000' LIMIT 1),
     gl_510000 AS (SELECT id as gl_id FROM gl_accounts WHERE account_code = '510000' LIMIT 1),
     gl_530000 AS (SELECT id as gl_id FROM gl_accounts WHERE account_code = '530000' LIMIT 1)

INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id) 
SELECT company_id, val_id, key_id, gl_id FROM company, val_3000, key_bsx, gl_140000
UNION ALL
SELECT company_id, val_id, key_id, gl_id FROM company, val_3000, key_gbb, gl_160000
UNION ALL  
SELECT company_id, val_id, key_id, gl_id FROM company, val_3000, key_wrx, gl_500000
UNION ALL
SELECT company_id, val_id, key_id, gl_id FROM company, val_7900, key_bsx, gl_140000
UNION ALL
SELECT company_id, val_id, key_id, gl_id FROM company, val_7900, key_gbb, gl_160000
UNION ALL
SELECT company_id, val_id, key_id, gl_id FROM company, val_7900, key_wrx, gl_510000
UNION ALL
SELECT company_id, val_id, key_id, gl_id FROM company, val_7920, key_bsx, gl_150000
UNION ALL
SELECT company_id, val_id, key_id, gl_id FROM company, val_7920, key_gbb, gl_160000
UNION ALL
SELECT company_id, val_id, key_id, gl_id FROM company, val_9000, key_wrx, gl_530000;

-- Verify the data
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
ORDER BY vc.class_code, ak.account_key_code;