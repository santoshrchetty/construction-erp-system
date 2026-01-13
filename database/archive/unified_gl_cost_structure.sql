-- Unified GL Account / Cost Element Structure for Construction SaaS
-- ================================================================

-- Chart of Accounts (GL = Cost Element)
CREATE TABLE chart_of_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_code VARCHAR(20) UNIQUE NOT NULL,
    account_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(20) NOT NULL, -- 'ASSET', 'LIABILITY', 'EXPENSE', 'REVENUE'
    cost_element_category VARCHAR(2), -- '1' = Primary, '21' = Secondary, NULL = No CO
    cost_category VARCHAR(20), -- 'MATERIAL', 'LABOR', 'EQUIPMENT', 'OVERHEAD', 'SUBCONTRACT'
    balance_sheet_account BOOLEAN DEFAULT false,
    cost_relevant BOOLEAN DEFAULT false,
    company_code VARCHAR(4) DEFAULT 'C001',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Financial Documents (FI Documents)
CREATE TABLE financial_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_number VARCHAR(20) UNIQUE NOT NULL,
    document_type VARCHAR(10) NOT NULL, -- 'GR', 'GI', 'INV', 'PAY', 'JE'
    posting_date DATE NOT NULL,
    document_date DATE NOT NULL,
    reference_document VARCHAR(50), -- PO, GRN, Invoice number
    total_amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    company_code VARCHAR(4) DEFAULT 'C001',
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Journal Entries (FI Line Items)
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES financial_documents(id) ON DELETE CASCADE,
    line_item INTEGER NOT NULL,
    account_code VARCHAR(20) NOT NULL REFERENCES chart_of_accounts(account_code),
    debit_amount DECIMAL(15,2) DEFAULT 0,
    credit_amount DECIMAL(15,2) DEFAULT 0,
    -- Project dimensions for cost-relevant accounts
    project_code VARCHAR(20),
    wbs_element VARCHAR(50),
    cost_center VARCHAR(20),
    -- Additional fields
    description TEXT,
    reference_key VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(document_id, line_item)
);

-- Project Line Items (CO Line Items - CJI3 equivalent)
CREATE VIEW project_line_items AS
SELECT 
    je.id,
    je.document_id,
    fd.document_number,
    fd.document_type,
    fd.posting_date,
    EXTRACT(YEAR FROM fd.posting_date) as period_year,
    EXTRACT(MONTH FROM fd.posting_date) as period_month,
    je.account_code as cost_element_code,
    coa.account_name as cost_element_name,
    coa.cost_category,
    je.project_code,
    je.wbs_element,
    je.cost_center,
    CASE 
        WHEN je.debit_amount > 0 THEN je.debit_amount 
        ELSE -je.credit_amount 
    END as amount,
    je.description,
    fd.reference_document,
    fd.created_by,
    je.created_at
FROM journal_entries je
JOIN financial_documents fd ON je.document_id = fd.id
JOIN chart_of_accounts coa ON je.account_code = coa.account_code
WHERE coa.cost_relevant = true 
  AND je.project_code IS NOT NULL;

-- Construction Chart of Accounts
INSERT INTO chart_of_accounts (account_code, account_name, account_type, cost_element_category, cost_category, balance_sheet_account, cost_relevant) VALUES
-- Balance Sheet Accounts
('110000', 'Cash and Bank', 'ASSET', NULL, NULL, true, false),
('140000', 'Raw Materials Inventory', 'ASSET', NULL, NULL, true, false),
('141000', 'Work in Progress', 'ASSET', NULL, NULL, true, false),
('150000', 'Equipment and Machinery', 'ASSET', NULL, NULL, true, false),
('200000', 'Accounts Payable', 'LIABILITY', NULL, NULL, true, false),
('201000', 'GR/IR Clearing Account', 'LIABILITY', NULL, NULL, true, false),

-- Primary Cost Elements (Expense Accounts)
('400100', 'Raw Materials Consumed', 'EXPENSE', '1', 'MATERIAL', false, true),
('400200', 'Construction Materials', 'EXPENSE', '1', 'MATERIAL', false, true),
('400300', 'Equipment and Tools', 'EXPENSE', '1', 'MATERIAL', false, true),
('450100', 'Subcontractor - Civil Work', 'EXPENSE', '1', 'SUBCONTRACT', false, true),
('450200', 'Subcontractor - MEP Work', 'EXPENSE', '1', 'SUBCONTRACT', false, true),
('450300', 'Subcontractor - Finishing', 'EXPENSE', '1', 'SUBCONTRACT', false, true),
('600100', 'Direct Labor - Site Workers', 'EXPENSE', '1', 'LABOR', false, true),
('600200', 'Direct Labor - Engineers', 'EXPENSE', '1', 'LABOR', false, true),
('600300', 'Direct Labor - Supervisors', 'EXPENSE', '1', 'LABOR', false, true),
('650100', 'Equipment Rental', 'EXPENSE', '1', 'EQUIPMENT', false, true),
('650200', 'Equipment Depreciation', 'EXPENSE', '1', 'EQUIPMENT', false, true),
('650300', 'Equipment Maintenance', 'EXPENSE', '1', 'EQUIPMENT', false, true),

-- Secondary Cost Elements (Internal Allocations)
('900100', 'Project Management Overhead', 'EXPENSE', '21', 'OVERHEAD', false, true),
('900200', 'Site Administration', 'EXPENSE', '21', 'OVERHEAD', false, true),
('900300', 'Quality Control Overhead', 'EXPENSE', '21', 'OVERHEAD', false, true),
('900400', 'Safety and Compliance', 'EXPENSE', '21', 'OVERHEAD', false, true),

-- Revenue Accounts
('800100', 'Construction Revenue', 'REVENUE', NULL, NULL, false, false),
('800200', 'Variation Order Revenue', 'REVENUE', NULL, NULL, false, false);

-- Project Cost Summary View (CJI3 Summary)
CREATE VIEW project_cost_summary AS
SELECT 
    pli.project_code,
    p.name as project_name,
    pli.wbs_element,
    wbs.name as wbs_name,
    pli.cost_category,
    pli.cost_element_code,
    pli.cost_element_name,
    COUNT(*) as transaction_count,
    SUM(pli.amount) as total_cost,
    MIN(pli.posting_date) as first_posting,
    MAX(pli.posting_date) as last_posting
FROM project_line_items pli
LEFT JOIN projects p ON pli.project_code = p.code
LEFT JOIN wbs_nodes wbs ON pli.wbs_element = wbs.code
GROUP BY pli.project_code, p.name, pli.wbs_element, wbs.name, 
         pli.cost_category, pli.cost_element_code, pli.cost_element_name;

-- Period-wise Project Costs
CREATE VIEW project_period_costs AS
SELECT 
    project_code,
    wbs_element,
    period_year,
    period_month,
    cost_category,
    SUM(amount) as period_cost,
    COUNT(*) as transaction_count
FROM project_line_items
GROUP BY project_code, wbs_element, period_year, period_month, cost_category;

-- Indexes for performance
CREATE INDEX idx_journal_entries_project ON journal_entries(project_code, wbs_element);
CREATE INDEX idx_journal_entries_account ON journal_entries(account_code);
CREATE INDEX idx_financial_documents_date ON financial_documents(posting_date);
CREATE INDEX idx_financial_documents_type ON financial_documents(document_type);

-- Document number sequences
CREATE SEQUENCE financial_doc_seq START 1000001;

-- Function to generate document numbers
CREATE OR REPLACE FUNCTION generate_document_number(doc_type VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
    RETURN doc_type || '-' || TO_CHAR(nextval('financial_doc_seq'), 'FM0000000');
END;
$$ LANGUAGE plpgsql;