-- Step 1: Add account assignment category column
ALTER TABLE account_determination ADD COLUMN IF NOT EXISTS account_assignment_category VARCHAR(1);

-- Step 2: Add project-specific GL accounts (check if they exist first)
INSERT INTO gl_accounts (account_code, account_name, account_type, description) 
SELECT '141000', 'Project Stock - Raw Materials', 'ASSET', 'Project-specific raw materials inventory'
WHERE NOT EXISTS (SELECT 1 FROM gl_accounts WHERE account_code = '141000');

INSERT INTO gl_accounts (account_code, account_name, account_type, description) 
SELECT '151000', 'Project Stock - Equipment', 'ASSET', 'Project-specific equipment inventory'
WHERE NOT EXISTS (SELECT 1 FROM gl_accounts WHERE account_code = '151000');

INSERT INTO gl_accounts (account_code, account_name, account_type, description) 
SELECT '501000', 'Project Material Consumption', 'EXPENSE', 'Direct material costs charged to projects'
WHERE NOT EXISTS (SELECT 1 FROM gl_accounts WHERE account_code = '501000');

-- Step 3: Add one project account determination entry at a time
-- BSX + 3000 + P = 141000 (Project Raw Materials Stock)
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id, account_assignment_category, is_active)
SELECT 
    (SELECT id FROM company_codes WHERE company_code = '1000'),
    (SELECT id FROM valuation_classes WHERE class_code = '3000'),
    (SELECT id FROM account_keys WHERE account_key_code = 'BSX'),
    (SELECT id FROM gl_accounts WHERE account_code = '141000'),
    'P',
    true
WHERE NOT EXISTS (
    SELECT 1 FROM account_determination 
    WHERE company_code_id = (SELECT id FROM company_codes WHERE company_code = '1000')
      AND valuation_class_id = (SELECT id FROM valuation_classes WHERE class_code = '3000')
      AND account_key_id = (SELECT id FROM account_keys WHERE account_key_code = 'BSX')
      AND account_assignment_category = 'P'
);

-- WRX + 3000 + P = 501000 (Project Material Consumption)
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id, account_assignment_category, is_active)
SELECT 
    (SELECT id FROM company_codes WHERE company_code = '1000'),
    (SELECT id FROM valuation_classes WHERE class_code = '3000'),
    (SELECT id FROM account_keys WHERE account_key_code = 'WRX'),
    (SELECT id FROM gl_accounts WHERE account_code = '501000'),
    'P',
    true
WHERE NOT EXISTS (
    SELECT 1 FROM account_determination 
    WHERE company_code_id = (SELECT id FROM company_codes WHERE company_code = '1000')
      AND valuation_class_id = (SELECT id FROM valuation_classes WHERE class_code = '3000')
      AND account_key_id = (SELECT id FROM account_keys WHERE account_key_code = 'WRX')
      AND account_assignment_category = 'P'
);

-- Show results
SELECT COUNT(*) as project_entries FROM account_determination WHERE account_assignment_category = 'P';