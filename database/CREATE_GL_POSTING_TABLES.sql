-- GL Posting Tables - Following Chart of Accounts pattern
-- Create tables for GL documents and entries

-- GL Documents table
CREATE TABLE IF NOT EXISTS gl_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_code VARCHAR(10) NOT NULL,
    document_number VARCHAR(50) NOT NULL UNIQUE,
    posting_date DATE NOT NULL,
    document_date DATE NOT NULL,
    reference VARCHAR(100),
    header_text VARCHAR(500),
    status VARCHAR(20) DEFAULT 'DRAFT',
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- GL Entries table
CREATE TABLE IF NOT EXISTS gl_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL REFERENCES gl_documents(id) ON DELETE CASCADE,
    account_code VARCHAR(20) NOT NULL,
    debit_amount DECIMAL(15,2) DEFAULT 0,
    credit_amount DECIMAL(15,2) DEFAULT 0,
    cost_center VARCHAR(20),
    project_code VARCHAR(20),
    description VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_gl_documents_company ON gl_documents (company_code, posting_date);
CREATE INDEX IF NOT EXISTS idx_gl_entries_document ON gl_entries (document_id);
CREATE INDEX IF NOT EXISTS idx_gl_entries_account ON gl_entries (account_code);

-- Sample GL accounts for testing (if chart_of_accounts doesn't exist)
INSERT INTO chart_of_accounts (
    company_code, coa_code, coa_name, account_code, account_name, account_type, is_active
) VALUES 
('C001', 'COA001', 'Main Chart of Accounts', '110000', 'Cash and Bank', 'ASSET', true),
('C001', 'COA001', 'Main Chart of Accounts', '140000', 'Raw Materials Inventory', 'ASSET', true),
('C001', 'COA001', 'Main Chart of Accounts', '400100', 'Raw Materials Consumed', 'EXPENSE', true),
('C001', 'COA001', 'Main Chart of Accounts', '450100', 'Subcontractor - Civil Work', 'EXPENSE', true),
('C001', 'COA001', 'Main Chart of Accounts', '600100', 'Direct Labor - Site Workers', 'EXPENSE', true),
('C001', 'COA001', 'Main Chart of Accounts', '650100', 'Equipment Rental', 'EXPENSE', true),
('B001', 'COA001', 'Main Chart of Accounts', '110000', 'Cash and Bank', 'ASSET', true),
('B001', 'COA001', 'Main Chart of Accounts', '140000', 'Raw Materials Inventory', 'ASSET', true),
('B001', 'COA001', 'Main Chart of Accounts', '400100', 'Raw Materials Consumed', 'EXPENSE', true)
ON CONFLICT DO NOTHING;

SELECT 'GL Posting tables created successfully' as status;