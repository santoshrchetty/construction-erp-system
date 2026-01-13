-- Add essential missing columns to chart_of_accounts table
-- Run these one by one to enhance your table structure

-- 1. Audit columns for compliance
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS created_by UUID;
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS updated_by UUID;

-- 2. Account hierarchy support
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS parent_account VARCHAR(20);
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS account_level INTEGER DEFAULT 1;

-- 3. Posting controls
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS blocked_for_posting BOOLEAN DEFAULT FALSE;
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS reconciliation_account BOOLEAN DEFAULT FALSE;

-- 4. Tax and currency handling
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS tax_category VARCHAR(10);
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS currency_code VARCHAR(3) DEFAULT 'USD';

-- 5. Business classification
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS functional_area VARCHAR(10);
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS profit_center VARCHAR(10);
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS sort_key VARCHAR(20);

-- 6. Create performance indexes
CREATE INDEX IF NOT EXISTS idx_chart_accounts_company_type ON chart_of_accounts(company_code, account_type);
CREATE INDEX IF NOT EXISTS idx_chart_accounts_parent ON chart_of_accounts(parent_account);
CREATE INDEX IF NOT EXISTS idx_chart_accounts_active ON chart_of_accounts(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_chart_accounts_code ON chart_of_accounts(company_code, account_code);

-- 7. Add triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_chart_accounts_updated_at 
    BEFORE UPDATE ON chart_of_accounts 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();