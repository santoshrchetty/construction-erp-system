-- Minimal fix for Chart of Accounts and Valuation Classes
DROP TABLE IF EXISTS chart_of_accounts CASCADE;
DROP TABLE IF EXISTS gl_accounts CASCADE;
DROP TABLE IF EXISTS valuation_classes CASCADE;

-- Create Chart of Accounts
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

-- Create GL Accounts
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

-- Create Valuation Classes
CREATE TABLE valuation_classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_code VARCHAR(4) UNIQUE NOT NULL,
    class_name VARCHAR(40) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert Chart of Accounts
INSERT INTO chart_of_accounts (coa_code, coa_name, country, currency, description) VALUES
('INT1', 'International IFRS', 'XX', 'USD', 'International Financial Reporting Standards');

-- Insert Valuation Classes
INSERT INTO valuation_classes (class_code, class_name, description) VALUES
('3000', 'Raw Materials', 'Valuation class for raw materials'),
('7920', 'Finished Products', 'Valuation class for finished products'),
('7900', 'Trading Goods', 'Valuation class for trading goods'),
('9000', 'Services', 'Valuation class for services');