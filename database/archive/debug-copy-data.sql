-- Test query to check what data exists for copying
-- Run this to see what the copy function should find

-- Check source company C001 data
SELECT 'Source Company C001' as info, COUNT(*) as account_count
FROM chart_of_accounts 
WHERE company_code = 'C001';

SELECT account_code, account_name, account_type, company_code
FROM chart_of_accounts 
WHERE company_code = 'C001' 
ORDER BY account_code 
LIMIT 5;

-- Check destination company B001 data (before copy)
SELECT 'Destination Company B001 (Before)' as info, COUNT(*) as account_count
FROM chart_of_accounts 
WHERE company_code = 'B001';

-- Check if companies exist in company_codes table
SELECT company_code, company_name, is_active
FROM company_codes 
WHERE company_code IN ('C001', 'B001')
ORDER BY company_code;