-- Simple Finance Setup - Check existing structure first
-- ===================================================

-- Step 1: Check what columns exist in chart_of_accounts
SELECT 'Current chart_of_accounts structure:' as info;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'chart_of_accounts' 
ORDER BY ordinal_position;

-- Step 2: Add missing columns one by one
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS account_code VARCHAR(20);
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS account_name VARCHAR(100);
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS account_type VARCHAR(20);
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS cost_element_category VARCHAR(2);
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS cost_category VARCHAR(20);
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS balance_sheet_account BOOLEAN DEFAULT false;
ALTER TABLE chart_of_accounts ADD COLUMN IF NOT EXISTS cost_relevant BOOLEAN DEFAULT false;

-- Step 3: Create financial tables
CREATE TABLE IF NOT EXISTS financial_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_number VARCHAR(20) UNIQUE NOT NULL,
    document_type VARCHAR(10) NOT NULL,
    posting_date DATE NOT NULL,
    document_date DATE NOT NULL,
    reference_document VARCHAR(50),
    total_amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    company_code VARCHAR(4) DEFAULT 'C001',
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES financial_documents(id) ON DELETE CASCADE,
    line_item INTEGER NOT NULL,
    account_code VARCHAR(20) NOT NULL,
    debit_amount DECIMAL(15,2) DEFAULT 0,
    credit_amount DECIMAL(15,2) DEFAULT 0,
    project_code VARCHAR(20),
    wbs_element VARCHAR(50),
    cost_center VARCHAR(20),
    description TEXT,
    reference_key VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(document_id, line_item)
);

-- Step 4: Create sequence and function
CREATE SEQUENCE IF NOT EXISTS financial_doc_seq START 1000001;

CREATE OR REPLACE FUNCTION generate_document_number(doc_type VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
    RETURN doc_type || '-' || TO_CHAR(nextval('financial_doc_seq'), 'FM0000000');
END;
$$ LANGUAGE plpgsql;

-- Step 5: Show final structure
SELECT 'Updated chart_of_accounts structure:' as info;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'chart_of_accounts' 
ORDER BY ordinal_position;

SELECT 'Setup completed - ready for sample data!' as status;