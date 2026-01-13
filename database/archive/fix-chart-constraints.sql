-- Fix chart_of_accounts table to add unique constraint
-- Run this first, then run the universal journal table script

-- 1. Add unique constraint on account_code + company_code
ALTER TABLE chart_of_accounts 
ADD CONSTRAINT uk_chart_accounts_code_company 
UNIQUE (account_code, company_code);

-- 2. Optionally, if you want account_code to be unique across all companies:
-- ALTER TABLE chart_of_accounts ADD CONSTRAINT uk_chart_accounts_code UNIQUE (account_code);

-- 3. Now you can run the universal-journal-table.sql script