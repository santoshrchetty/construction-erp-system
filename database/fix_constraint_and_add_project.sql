-- Step 1: Add account assignment category column
ALTER TABLE account_determination ADD COLUMN IF NOT EXISTS account_assignment_category VARCHAR(1);

-- Step 2: Drop the old unique constraint that doesn't include assignment category
ALTER TABLE account_determination DROP CONSTRAINT IF EXISTS account_determination_company_code_id_valuation_class_id_ac_key;

-- Step 3: Add new unique constraint that includes assignment category
ALTER TABLE account_determination ADD CONSTRAINT account_determination_unique 
UNIQUE(company_code_id, valuation_class_id, account_key_id, account_assignment_category);

-- Step 4: Add project-specific GL accounts
INSERT INTO gl_accounts (account_code, account_name, account_type, description) 
SELECT '141000', 'Project Stock - Raw Materials', 'ASSET', 'Project-specific raw materials inventory'
WHERE NOT EXISTS (SELECT 1 FROM gl_accounts WHERE account_code = '141000');

INSERT INTO gl_accounts (account_code, account_name, account_type, description) 
SELECT '151000', 'Project Stock - Equipment', 'ASSET', 'Project-specific equipment inventory'
WHERE NOT EXISTS (SELECT 1 FROM gl_accounts WHERE account_code = '151000');

INSERT INTO gl_accounts (account_code, account_name, account_type, description) 
SELECT '501000', 'Project Material Consumption', 'EXPENSE', 'Direct material costs charged to projects'
WHERE NOT EXISTS (SELECT 1 FROM gl_accounts WHERE account_code = '501000');

-- Step 5: Add project account determination entries
INSERT INTO account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id, account_assignment_category, is_active) VALUES
-- BSX + 3000 + P = 141000 (Project Raw Materials Stock)
((SELECT id FROM company_codes WHERE company_code = '1000'),
 (SELECT id FROM valuation_classes WHERE class_code = '3000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'BSX'),
 (SELECT id FROM gl_accounts WHERE account_code = '141000'), 'P', true),

-- WRX + 3000 + P = 501000 (Project Material Consumption)
((SELECT id FROM company_codes WHERE company_code = '1000'),
 (SELECT id FROM valuation_classes WHERE class_code = '3000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'WRX'),
 (SELECT id FROM gl_accounts WHERE account_code = '501000'), 'P', true),

-- GBB + 3000 + P = 160000 (GR/IR Clearing - same for both)
((SELECT id FROM company_codes WHERE company_code = '1000'),
 (SELECT id FROM valuation_classes WHERE class_code = '3000'),
 (SELECT id FROM account_keys WHERE account_key_code = 'GBB'),
 (SELECT id FROM gl_accounts WHERE account_code = '160000'), 'P', true);

-- Show results
SELECT 
    'Project Entries Added' as result,
    COUNT(*) as count 
FROM account_determination 
WHERE account_assignment_category = 'P';