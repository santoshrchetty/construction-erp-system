-- Quick test to verify chart_of_accounts table and data
-- Run this in your Supabase SQL editor

-- Check table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'chart_of_accounts' 
ORDER BY ordinal_position;

-- Check actual data
SELECT company_code, COUNT(*) as account_count
FROM chart_of_accounts 
GROUP BY company_code 
ORDER BY company_code;

-- Check specific data for C001
SELECT account_code, account_name, account_type, company_code
FROM chart_of_accounts 
WHERE company_code = 'C001' 
ORDER BY account_code 
LIMIT 10;