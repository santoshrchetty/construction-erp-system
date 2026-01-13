-- Verification Script for Phase 1 ERP Foundation
-- Run this after executing phase1_erp_foundation.sql

-- Check table creation
SELECT 'Tables Created' as check_type, count(*) as count FROM information_schema.tables 
WHERE table_name IN ('material_types', 'valuation_classes', 'movement_types', 'account_keys', 'chart_of_accounts', 'gl_accounts', 'account_determination');

-- Check material types
SELECT 'Material Types' as check_type, material_type_code, material_type_name FROM material_types ORDER BY material_type_code;

-- Check valuation classes  
SELECT 'Valuation Classes' as check_type, valuation_class_code, valuation_class_name FROM valuation_classes ORDER BY valuation_class_code;

-- Check movement types
SELECT 'Movement Types' as check_type, movement_type_code, movement_type_name, movement_indicator FROM movement_types ORDER BY movement_type_code;

-- Check account keys
SELECT 'Account Keys' as check_type, account_key_code, account_key_name, debit_credit_indicator FROM account_keys ORDER BY account_key_code;

-- Check GL accounts
SELECT 'GL Accounts' as check_type, account_number, account_name, account_type FROM gl_accounts ORDER BY account_number;

-- Check account determination setup
SELECT 'Account Determination' as check_type, 
       cc.company_code,
       vc.valuation_class_code, 
       ak.account_key_code,
       gl.account_number
FROM account_determination ad
JOIN company_codes cc ON ad.company_code_id = cc.id
JOIN valuation_classes vc ON ad.valuation_class_id = vc.id  
JOIN account_keys ak ON ad.account_key_id = ak.id
JOIN gl_accounts gl ON ad.gl_account_id = gl.id;

-- Check stock_items columns added
SELECT 'Stock Items Columns' as check_type, 
       CASE WHEN column_name = 'material_type_id' THEN 'material_type_id added' 
            WHEN column_name = 'valuation_class_id' THEN 'valuation_class_id added' 
       END as status
FROM information_schema.columns 
WHERE table_name = 'stock_items' AND column_name IN ('material_type_id', 'valuation_class_id');