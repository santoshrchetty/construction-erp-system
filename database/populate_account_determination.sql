-- Account Determination Data Population
-- Run this after schema alignment fixes to populate account determination

-- Insert sample GL accounts if missing
INSERT INTO public.chart_of_accounts (id, coa_code, account_code, account_name, account_type, company_code) VALUES
(gen_random_uuid(), 'INCA', '140000', 'Raw Materials Inventory', 'ASSET', 'C001'),
(gen_random_uuid(), 'INCA', '150000', 'Finished Goods Inventory', 'ASSET', 'C001'),
(gen_random_uuid(), 'INCA', '500000', 'Material Consumption', 'EXPENSE', 'C001'),
(gen_random_uuid(), 'INCA', '510000', 'Cost of Goods Sold', 'EXPENSE', 'C001'),
(gen_random_uuid(), 'INCA', '540000', 'Price Differences', 'EXPENSE', 'C001'),
(gen_random_uuid(), 'INCA', '191000', 'GR/IR Clearing', 'LIABILITY', 'C001'),
(gen_random_uuid(), 'INCA', '130000', 'Work in Progress', 'ASSET', 'C001')
ON CONFLICT (account_code) DO NOTHING;

-- Insert valuation classes if missing
INSERT INTO public.valuation_classes (id, class_code, class_name, description) VALUES
(gen_random_uuid(), 'MAT001', 'Raw Materials', 'Construction raw materials - cement, steel, aggregates'),
(gen_random_uuid(), 'MAT002', 'Finished Goods', 'Prefab components and completed assemblies')
ON CONFLICT (class_code) DO NOTHING;

-- Insert account keys if missing
INSERT INTO public.account_keys (id, account_key_code, account_key_name, description, debit_credit_indicator) VALUES
(gen_random_uuid(), 'BSX', 'Stock Account', 'Stock valuation for inventory', 'D'),
(gen_random_uuid(), 'GBB', 'Consumption Account', 'Direct consumption/cost allocation', 'C'),
(gen_random_uuid(), 'PRD', 'Price Difference', 'Purchase price variances', 'D'),
(gen_random_uuid(), 'INV', 'GR/IR Clearing', 'Goods receipt/invoice receipt clearing', 'C'),
(gen_random_uuid(), 'WIP', 'Work in Progress', 'Project material allocation', 'D')
ON CONFLICT (account_key_code) DO NOTHING;

-- Get company code ID
WITH company AS (SELECT id FROM public.company_codes WHERE company_code = 'C001' LIMIT 1),
     val_raw AS (SELECT id FROM public.valuation_classes WHERE class_code = 'MAT001' LIMIT 1),
     val_fin AS (SELECT id FROM public.valuation_classes WHERE class_code = 'MAT002' LIMIT 1),
     acc_bsx AS (SELECT id FROM public.account_keys WHERE account_key_code = 'BSX' LIMIT 1),
     acc_gbb AS (SELECT id FROM public.account_keys WHERE account_key_code = 'GBB' LIMIT 1),
     acc_prd AS (SELECT id FROM public.account_keys WHERE account_key_code = 'PRD' LIMIT 1),
     acc_inv AS (SELECT id FROM public.account_keys WHERE account_key_code = 'INV' LIMIT 1),
     acc_wip AS (SELECT id FROM public.account_keys WHERE account_key_code = 'WIP' LIMIT 1),
     gl_140 AS (SELECT id FROM public.chart_of_accounts WHERE account_code = '140000' LIMIT 1),
     gl_150 AS (SELECT id FROM public.chart_of_accounts WHERE account_code = '150000' LIMIT 1),
     gl_500 AS (SELECT id FROM public.chart_of_accounts WHERE account_code = '500000' LIMIT 1),
     gl_510 AS (SELECT id FROM public.chart_of_accounts WHERE account_code = '510000' LIMIT 1),
     gl_540 AS (SELECT id FROM public.chart_of_accounts WHERE account_code = '540000' LIMIT 1),
     gl_191 AS (SELECT id FROM public.chart_of_accounts WHERE account_code = '191000' LIMIT 1),
     gl_130 AS (SELECT id FROM public.chart_of_accounts WHERE account_code = '130000' LIMIT 1)

-- Insert account determination mappings
INSERT INTO public.account_determination (company_code_id, valuation_class_id, account_key_id, gl_account_id, is_active) 
SELECT * FROM (
    -- Raw Materials (MAT001) mappings
    SELECT company.id, val_raw.id, acc_bsx.id, gl_140.id, true FROM company, val_raw, acc_bsx, gl_140
    UNION ALL
    SELECT company.id, val_raw.id, acc_gbb.id, gl_500.id, true FROM company, val_raw, acc_gbb, gl_500
    UNION ALL
    SELECT company.id, val_raw.id, acc_prd.id, gl_540.id, true FROM company, val_raw, acc_prd, gl_540
    UNION ALL
    SELECT company.id, val_raw.id, acc_inv.id, gl_191.id, true FROM company, val_raw, acc_inv, gl_191
    UNION ALL
    SELECT company.id, val_raw.id, acc_wip.id, gl_130.id, true FROM company, val_raw, acc_wip, gl_130
    UNION ALL
    -- Finished Goods (MAT002) mappings
    SELECT company.id, val_fin.id, acc_bsx.id, gl_150.id, true FROM company, val_fin, acc_bsx, gl_150
    UNION ALL
    SELECT company.id, val_fin.id, acc_gbb.id, gl_510.id, true FROM company, val_fin, acc_gbb, gl_510
    UNION ALL
    SELECT company.id, val_fin.id, acc_prd.id, gl_540.id, true FROM company, val_fin, acc_prd, gl_540
    UNION ALL
    SELECT company.id, val_fin.id, acc_inv.id, gl_191.id, true FROM company, val_fin, acc_inv, gl_191
    UNION ALL
    SELECT company.id, val_fin.id, acc_wip.id, gl_130.id, true FROM company, val_fin, acc_wip, gl_130
) AS mappings
ON CONFLICT (company_code_id, valuation_class_id, account_key_id) DO NOTHING;

-- Verify data was inserted
SELECT 'Account Determination populated successfully!' as status,
       COUNT(*) as total_mappings
FROM public.account_determination;