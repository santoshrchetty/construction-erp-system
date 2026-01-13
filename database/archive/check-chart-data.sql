-- Check Chart of Accounts data for copy test
-- Source: C001, Destination: B001

-- Check existing data in C001 (source)
SELECT 'C001 Source Data' as info, count(*) as record_count 
FROM chart_of_accounts 
WHERE company_code = 'C001';

SELECT account_code, account_name, account_type, company_code 
FROM chart_of_accounts 
WHERE company_code = 'C001' 
ORDER BY account_code 
LIMIT 10;

-- Check existing data in B001 (destination - should be empty before copy)
SELECT 'B001 Destination Data (Before)' as info, count(*) as record_count 
FROM chart_of_accounts 
WHERE company_code = 'B001';

SELECT account_code, account_name, account_type, company_code 
FROM chart_of_accounts 
WHERE company_code = 'B001' 
ORDER BY account_code 
LIMIT 10;