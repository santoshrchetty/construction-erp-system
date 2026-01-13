-- Fix the unique constraint issue on chart_of_accounts table
-- The constraint should be on (coa_code, company_code) not just coa_code

-- 1. Drop the existing unique constraint on coa_code
ALTER TABLE chart_of_accounts DROP CONSTRAINT IF EXISTS chart_of_accounts_coa_code_key;

-- 2. Add the correct unique constraint on (coa_code, company_code)
ALTER TABLE chart_of_accounts ADD CONSTRAINT uk_chart_accounts_coa_company 
UNIQUE (coa_code, company_code);

-- 3. Verify the constraint
SELECT conname, contype, pg_get_constraintdef(oid) as definition
FROM pg_constraint 
WHERE conrelid = 'chart_of_accounts'::regclass 
AND contype = 'u';