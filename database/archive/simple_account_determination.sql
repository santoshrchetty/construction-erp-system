-- Simple Account Determination Population
-- Run each section separately to debug

-- Step 1: Add valuation classes
INSERT INTO public.valuation_classes (class_code, class_name, description) VALUES
('M001', 'Raw Materials', 'Construction raw materials'),
('M002', 'Finished Goods', 'Finished construction materials')
ON CONFLICT (class_code) DO NOTHING;

-- Step 2: Add account keys  
INSERT INTO public.account_keys (account_key_code, account_key_name, description, debit_credit_indicator) VALUES
('BSX', 'Stock Account', 'Stock valuation', 'D'),
('GBB', 'Consumption Account', 'Material consumption', 'C')
ON CONFLICT (account_key_code) DO NOTHING;

-- Step 3: Check what we have
SELECT 'Company Codes:' as type, company_code, id FROM public.company_codes LIMIT 1;
SELECT 'Valuation Classes:' as type, class_code, id FROM public.valuation_classes;
SELECT 'Account Keys:' as type, account_key_code, id FROM public.account_keys;
SELECT 'GL Accounts:' as type, account_code, id FROM public.chart_of_accounts WHERE account_code IN ('130000', '400000', '401000');

-- Step 4: Manual insert (replace UUIDs with actual IDs from step 3)
-- INSERT INTO public.account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id, is_active) VALUES
-- ('your-company-id', 'your-valuation-class-id', 'your-account-key-id', 'your-gl-account-id', true);