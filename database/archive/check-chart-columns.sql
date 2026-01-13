-- Check current chart_of_accounts table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'chart_of_accounts' 
ORDER BY ordinal_position;

-- Suggested additional columns for enterprise Chart of Accounts
-- Add these columns if they don't exist:

-- ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
-- ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id);
-- ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS updated_by UUID REFERENCES auth.users(id);
-- ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS parent_account VARCHAR(20);
-- ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS account_level INTEGER DEFAULT 1;
-- ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS reconciliation_account BOOLEAN DEFAULT FALSE;
-- ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS blocked_for_posting BOOLEAN DEFAULT FALSE;
-- ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS tax_category VARCHAR(10);
-- ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS currency_code VARCHAR(3) DEFAULT 'USD';
-- ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS sort_key VARCHAR(20);
-- ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS functional_area VARCHAR(10);
-- ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS profit_center VARCHAR(10);
-- ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS segment VARCHAR(10);

-- Create indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_chart_accounts_company_type ON chart_of_accounts(company_code, account_type);
-- CREATE INDEX IF NOT EXISTS idx_chart_accounts_parent ON chart_of_accounts(parent_account);
-- CREATE INDEX IF NOT EXISTS idx_chart_accounts_active ON chart_of_accounts(is_active) WHERE is_active = true;