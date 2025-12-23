-- Enhanced Account Determination for Project Support
-- Add account assignment category to account determination
ALTER TABLE account_determination ADD COLUMN IF NOT EXISTS account_assignment_category VARCHAR(1);

-- Add project-specific GL accounts for project stock
INSERT INTO gl_accounts (account_code, account_name, account_type, description) VALUES
('141000', 'Project Stock - Raw Materials', 'ASSET', 'Project-specific raw materials inventory'),
('151000', 'Project Stock - Equipment', 'ASSET', 'Project-specific equipment inventory'),
('501000', 'Project Material Consumption', 'EXPENSE', 'Direct material costs charged to projects')
ON CONFLICT (account_code) DO NOTHING;

-- Add project-specific account determination entries
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id, account_assignment_category, is_active) VALUES
-- Project Stock for Raw Materials (3000) with 'P' assignment
((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '3000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'),
 (SELECT id FROM gl_accounts WHERE account_code = '141000'), 'P', true),

-- Project Stock for Equipment (7920) with 'P' assignment  
((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '7920'),
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'),
 (SELECT id FROM gl_accounts WHERE account_code = '151000'), 'P', true),

-- Project Material Consumption with 'P' assignment
((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '3000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'),
 (SELECT id FROM gl_accounts WHERE account_code = '501000'), 'P', true),

((SELECT id FROM company_codes WHERE company_code = '1000'), 
 (SELECT id FROM valuation_classes WHERE class_code = '7920'),
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'),
 (SELECT id FROM gl_accounts WHERE account_code = '501000'), 'P', true)

ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Show the complete account determination logic
SELECT 
    cc.company_code,
    vc.class_code as valuation_class,
    ak.account_key_code as account_key,
    COALESCE(ad.account_assignment_category, 'Normal') as assignment_type,
    gl.account_code as gl_account,
    gl.account_name,
    CASE 
        WHEN ad.account_assignment_category = 'P' THEN 'Project Stock/WBS'
        ELSE 'Normal Stock/Cost Center'
    END as usage
FROM account_determination ad
JOIN company_codes cc ON ad.company_code_id = cc.id
JOIN valuation_classes vc ON ad.valuation_class_id = vc.id  
JOIN account_keys ak ON ad.account_key_id = ak.id
JOIN gl_accounts gl ON ad.gl_account_id = gl.id
WHERE ad.is_active = true
ORDER BY vc.class_code, ak.account_key_code, COALESCE(ad.account_assignment_category, 'Z');