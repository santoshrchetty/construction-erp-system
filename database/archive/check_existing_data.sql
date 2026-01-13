-- Check Existing Data Before Populating Account Determination
-- Run this first to see what data already exists

-- Check existing data
SELECT 'Company Codes' as table_name, COUNT(*) as count FROM public.company_codes
UNION ALL
SELECT 'Chart of Accounts', COUNT(*) FROM public.chart_of_accounts  
UNION ALL
SELECT 'Valuation Classes', COUNT(*) FROM public.valuation_classes
UNION ALL
SELECT 'Account Keys', COUNT(*) FROM public.account_keys
UNION ALL
SELECT 'Account Determination', COUNT(*) FROM public.account_determination;

-- Show existing valuation classes
SELECT 'Existing Valuation Classes:' as info, class_code, class_name FROM public.valuation_classes;

-- Show existing account keys  
SELECT 'Existing Account Keys:' as info, account_key_code, account_key_name FROM public.account_keys;

-- Show existing GL accounts
SELECT 'Existing GL Accounts:' as info, account_code, account_name FROM public.chart_of_accounts LIMIT 10;