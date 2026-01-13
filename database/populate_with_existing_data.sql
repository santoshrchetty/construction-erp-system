-- Populate Account Determination Using EXISTING Data Only
-- This uses your existing GL accounts and creates minimal missing master data

-- First, check what valuation classes and account keys exist
SELECT 'Existing Valuation Classes:' as type, class_code, class_name FROM public.valuation_classes
UNION ALL
SELECT 'Existing Account Keys:', account_key_code, account_key_name FROM public.account_keys;

-- Add minimal missing valuation classes (only if none exist)
INSERT INTO public.valuation_classes (class_code, class_name, description) 
SELECT 'M001', 'Raw Materials', 'Construction raw materials'
WHERE NOT EXISTS (SELECT 1 FROM public.valuation_classes WHERE class_code = 'M001');

INSERT INTO public.valuation_classes (class_code, class_name, description) 
SELECT 'M002', 'Finished Goods', 'Finished construction materials'  
WHERE NOT EXISTS (SELECT 1 FROM public.valuation_classes WHERE class_code = 'M002');

-- Add minimal missing account keys (only if none exist)
INSERT INTO public.account_keys (account_key_code, account_key_name, description, debit_credit_indicator) 
SELECT 'BSX', 'Stock Account', 'Stock valuation', 'D'
WHERE NOT EXISTS (SELECT 1 FROM public.account_keys WHERE account_key_code = 'BSX');

INSERT INTO public.account_keys (account_key_code, account_key_name, description, debit_credit_indicator) 
SELECT 'GBB', 'Consumption Account', 'Material consumption', 'C'
WHERE NOT EXISTS (SELECT 1 FROM public.account_keys WHERE account_key_code = 'GBB');

-- Create account determination using YOUR existing GL accounts
WITH company AS (SELECT id FROM public.company_codes LIMIT 1),
     val_raw AS (SELECT id FROM public.valuation_classes WHERE class_code = 'M001'),
     val_fin AS (SELECT id FROM public.valuation_classes WHERE class_code = 'M002'),
     acc_bsx AS (SELECT id FROM public.account_keys WHERE account_key_code = 'BSX'),
     acc_gbb AS (SELECT id FROM public.account_keys WHERE account_key_code = 'GBB'),
     gl_130 AS (SELECT id FROM public.chart_of_accounts WHERE account_code = '130000'), -- Raw Materials Inventory
     gl_202 AS (SELECT id FROM public.chart_of_accounts WHERE account_code = '202000'), -- GR/IR Clearing
     gl_400 AS (SELECT id FROM public.chart_of_accounts WHERE account_code = '400000'), -- Raw Materials Consumed
     gl_401 AS (SELECT id FROM public.chart_of_accounts WHERE account_code = '401000'), -- Concrete Materials
     gl_402 AS (SELECT id FROM public.chart_of_accounts WHERE account_code = '402000')  -- Steel Materials

INSERT INTO public.account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id, is_active)
SELECT company.id, val_raw.id, acc_bsx.id, gl_130.id, true 
FROM company, val_raw, acc_bsx, gl_130
WHERE company.id IS NOT NULL AND val_raw.id IS NOT NULL AND acc_bsx.id IS NOT NULL AND gl_130.id IS NOT NULL
UNION ALL
SELECT company.id, val_raw.id, acc_gbb.id, gl_400.id, true 
FROM company, val_raw, acc_gbb, gl_400
WHERE company.id IS NOT NULL AND val_raw.id IS NOT NULL AND acc_gbb.id IS NOT NULL AND gl_400.id IS NOT NULL
UNION ALL
SELECT company.id, val_fin.id, acc_bsx.id, gl_130.id, true 
FROM company, val_fin, acc_bsx, gl_130
WHERE company.id IS NOT NULL AND val_fin.id IS NOT NULL AND acc_bsx.id IS NOT NULL AND gl_130.id IS NOT NULL
UNION ALL
SELECT company.id, val_fin.id, acc_gbb.id, gl_401.id, true 
FROM company, val_fin, acc_gbb, gl_401
WHERE company.id IS NOT NULL AND val_fin.id IS NOT NULL AND acc_gbb.id IS NOT NULL AND gl_401.id IS NOT NULL
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Verify results
SELECT 'Account Determination Created:' as status, COUNT(*) as mappings FROM public.account_determination;