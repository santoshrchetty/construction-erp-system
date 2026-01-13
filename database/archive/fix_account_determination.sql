-- Simple Account Determination Population
-- Check if we have the required data first
SELECT COUNT(*) as company_count FROM company_codes;
SELECT COUNT(*) as valuation_count FROM valuation_classes;
SELECT COUNT(*) as account_key_count FROM account_keys;
SELECT COUNT(*) as gl_account_count FROM gl_accounts;

-- Clear existing data
DELETE FROM account_determination;

-- Insert basic account determination entries
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id, is_active)
SELECT 
    cc.id,
    vc.id,
    ak.id,
    gl.id,
    true
FROM company_codes cc
CROSS JOIN valuation_classes vc
CROSS JOIN account_keys ak
CROSS JOIN gl_accounts gl
WHERE cc.company_code = '1000'
  AND vc.class_code IN ('3000', '7900', '7920', '9000')
  AND ak.account_key_code IN ('BSX', 'GBB', 'WRX')
  AND gl.account_code IN ('140000', '160000', '500000', '150000', '510000', '530000')
  AND (
    (vc.class_code = '3000' AND ak.account_key_code = 'BSX' AND gl.account_code = '140000') OR
    (vc.class_code = '3000' AND ak.account_key_code = 'GBB' AND gl.account_code = '160000') OR
    (vc.class_code = '3000' AND ak.account_key_code = 'WRX' AND gl.account_code = '500000') OR
    (vc.class_code = '7900' AND ak.account_key_code = 'BSX' AND gl.account_code = '140000') OR
    (vc.class_code = '7900' AND ak.account_key_code = 'GBB' AND gl.account_code = '160000') OR
    (vc.class_code = '7900' AND ak.account_key_code = 'WRX' AND gl.account_code = '510000') OR
    (vc.class_code = '7920' AND ak.account_key_code = 'BSX' AND gl.account_code = '150000') OR
    (vc.class_code = '7920' AND ak.account_key_code = 'GBB' AND gl.account_code = '160000') OR
    (vc.class_code = '9000' AND ak.account_key_code = 'WRX' AND gl.account_code = '530000')
  );

-- Verify the results
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