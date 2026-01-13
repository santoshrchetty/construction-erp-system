-- Fix Chart of Accounts structure
-- Drop and recreate with correct column names

DROP TABLE IF EXISTS chart_of_accounts CASCADE;
DROP TABLE IF EXISTS gl_accounts CASCADE;

-- Create Chart of Accounts master table
CREATE TABLE chart_of_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coa_code VARCHAR(4) UNIQUE NOT NULL,
    coa_name VARCHAR(50) NOT NULL,
    country VARCHAR(2),
    currency VARCHAR(3),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create GL Accounts table with COA reference
CREATE TABLE gl_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chart_of_accounts_id UUID NOT NULL REFERENCES chart_of_accounts(id),
    account_code VARCHAR(10) NOT NULL,
    account_name VARCHAR(50) NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(chart_of_accounts_id, account_code)
);

-- Insert sample Chart of Accounts
INSERT INTO chart_of_accounts (coa_code, coa_name, country, currency, description) VALUES
('INT1', 'International IFRS', 'XX', 'USD', 'International Financial Reporting Standards'),
('IN01', 'Indian Accounting Standards', 'IN', 'INR', 'Indian Accounting Standards (Ind AS)'),
('US01', 'US GAAP', 'US', 'USD', 'United States Generally Accepted Accounting Principles'),
('UAE1', 'UAE Local Standards', 'AE', 'AED', 'UAE Local Accounting Standards');

-- Insert sample valuation classes
INSERT INTO valuation_classes (class_code, class_name, description) VALUES
('3000', 'Raw Materials', 'Valuation class for raw materials'),
('7920', 'Finished Products', 'Valuation class for finished products'),
('7900', 'Trading Goods', 'Valuation class for trading goods'),
('9000', 'Services', 'Valuation class for services')
ON CONFLICT (class_code) DO NOTHING;