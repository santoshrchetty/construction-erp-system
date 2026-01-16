-- Migrate account_determination table to use company_code string
-- This is the most complex table due to composite keys

-- Add company_code column
ALTER TABLE account_determination ADD COLUMN IF NOT EXISTS company_code VARCHAR(10);

-- Populate from existing company_code_id
UPDATE account_determination 
SET company_code = cc.company_code
FROM company_codes cc 
WHERE account_determination.company_code_id = cc.id 
AND account_determination.company_code IS NULL;

-- Create new unique constraint with company_code
ALTER TABLE account_determination 
DROP CONSTRAINT IF EXISTS account_determination_unique_key;

ALTER TABLE account_determination 
ADD CONSTRAINT account_determination_company_code_unique 
UNIQUE (company_code, valuation_class_id, account_key_id);

-- Add foreign key constraint
ALTER TABLE account_determination 
ADD CONSTRAINT account_determination_company_code_fkey 
FOREIGN KEY (company_code) REFERENCES company_codes(company_code);

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_account_determination_company_code ON account_determination(company_code);

-- Add NOT NULL constraint after population
ALTER TABLE account_determination 
ALTER COLUMN company_code SET NOT NULL;

-- Verify migration
SELECT 
    COUNT(*) as total_records,
    COUNT(company_code_id) as with_uuid,
    COUNT(company_code) as with_string,
    COUNT(CASE WHEN company_code_id IS NOT NULL AND company_code IS NOT NULL THEN 1 END) as both_populated
FROM account_determination;

-- After verification, drop old column and constraint
-- ALTER TABLE account_determination DROP COLUMN company_code_id;
-- ALTER TABLE account_determination DROP CONSTRAINT IF EXISTS account_determination_company_code_id_fkey;