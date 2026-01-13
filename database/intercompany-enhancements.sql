-- Intercompany Enhancements for Multi-Company Architecture
-- Supports transactions between company codes within same company

-- 1. Add intercompany fields to projects table
ALTER TABLE projects 
ADD COLUMN IF NOT EXISTS intercompany_codes JSONB,
ADD COLUMN IF NOT EXISTS lead_company_code VARCHAR(10),
ADD COLUMN IF NOT EXISTS intercompany_type VARCHAR(20) DEFAULT 'SINGLE'; -- SINGLE, MULTI, SHARED

-- 2. Add intercompany fields to universal_journal
ALTER TABLE universal_journal 
ADD COLUMN IF NOT EXISTS partner_company_code VARCHAR(10),
ADD COLUMN IF NOT EXISTS intercompany_reference VARCHAR(50),
ADD COLUMN IF NOT EXISTS elimination_flag BOOLEAN DEFAULT false;

-- 3. Create intercompany transaction types
CREATE TABLE IF NOT EXISTS intercompany_transaction_types (
    company_id UUID NOT NULL REFERENCES companies(company_id),
    transaction_type VARCHAR(30) NOT NULL,
    description VARCHAR(200),
    auto_elimination BOOLEAN DEFAULT true,
    gl_account_mapping JSONB, -- {"receivable": "130000", "payable": "210000"}
    is_active BOOLEAN DEFAULT true,
    PRIMARY KEY (company_id, transaction_type)
);

-- 4. Insert standard intercompany transaction types
INSERT INTO intercompany_transaction_types (company_id, transaction_type, description, gl_account_mapping) VALUES
-- ABC Construction Group
((SELECT company_id FROM companies WHERE company_name = 'ABC Construction Group'), 
 'SHARED_SERVICES', 'Shared services allocation', 
 '{"receivable": "130000", "payable": "210000", "expense": "700000", "revenue": "400000"}'),
((SELECT company_id FROM companies WHERE company_name = 'ABC Construction Group'), 
 'MANAGEMENT_FEE', 'Management fee charges', 
 '{"receivable": "130100", "payable": "210100", "expense": "710000", "revenue": "410000"}'),
((SELECT company_id FROM companies WHERE company_name = 'ABC Construction Group'), 
 'LOAN_INTEREST', 'Intercompany loan interest', 
 '{"receivable": "130200", "payable": "210200", "expense": "720000", "revenue": "420000"}'),
-- XYZ Engineering Corp
((SELECT company_id FROM companies WHERE company_name = 'XYZ Engineering Corp'), 
 'SHARED_SERVICES', 'Shared services allocation', 
 '{"receivable": "130000", "payable": "210000", "expense": "700000", "revenue": "400000"}');

-- 5. Create intercompany elimination view
CREATE OR REPLACE VIEW intercompany_elimination AS
SELECT 
    uj1.company_code as company_a,
    uj1.partner_company_code as company_b,
    uj1.project_code,
    uj1.gl_account as account_a,
    uj2.gl_account as account_b,
    uj1.amount,
    uj1.document_date,
    CASE 
        WHEN uj1.amount = uj2.amount THEN 'BALANCED'
        ELSE 'UNBALANCED'
    END as elimination_status
FROM universal_journal uj1
JOIN universal_journal uj2 ON 
    uj1.partner_company_code = uj2.company_code AND
    uj1.company_code = uj2.partner_company_code AND
    uj1.intercompany_reference = uj2.intercompany_reference
WHERE uj1.partner_company_code IS NOT NULL;

-- 6. Create intercompany posting function
CREATE OR REPLACE FUNCTION post_intercompany_transaction(
    from_company VARCHAR(10),
    to_company VARCHAR(10),
    transaction_type VARCHAR(30),
    project_code VARCHAR(20),
    amount DECIMAL(15,2),
    description TEXT
) RETURNS VOID AS $$
DECLARE
    company_uuid UUID;
    gl_mapping JSONB;
    reference_id VARCHAR(50);
BEGIN
    -- Validate companies belong to same parent company
    SELECT DISTINCT c.company_id INTO company_uuid
    FROM company_codes cc1
    JOIN company_codes cc2 ON cc1.company_id = cc2.company_id
    JOIN companies c ON cc1.company_id = c.company_id
    WHERE cc1.company_code = from_company AND cc2.company_code = to_company;
    
    IF company_uuid IS NULL THEN
        RAISE EXCEPTION 'Companies % and % do not belong to same parent company', from_company, to_company;
    END IF;
    
    -- Get GL account mapping
    SELECT gl_account_mapping INTO gl_mapping
    FROM intercompany_transaction_types
    WHERE company_id = company_uuid AND transaction_type = transaction_type;
    
    IF gl_mapping IS NULL THEN
        RAISE EXCEPTION 'Transaction type % not found for company', transaction_type;
    END IF;
    
    -- Generate unique reference
    reference_id := 'IC-' || to_char(NOW(), 'YYYYMMDD') || '-' || nextval('intercompany_seq');
    
    -- Post to sending company (Debit Receivable, Credit Revenue)
    INSERT INTO universal_journal (
        company_code, partner_company_code, project_code,
        gl_account, debit_credit, amount, document_type,
        intercompany_reference, description, document_date
    ) VALUES 
    (from_company, to_company, project_code,
     gl_mapping->>'receivable', 'D', amount, 'INTERCO_CHARGE',
     reference_id, description, CURRENT_DATE),
    (from_company, to_company, project_code,
     gl_mapping->>'revenue', 'C', amount, 'INTERCO_CHARGE',
     reference_id, description, CURRENT_DATE);
    
    -- Post to receiving company (Debit Expense, Credit Payable)
    INSERT INTO universal_journal (
        company_code, partner_company_code, project_code,
        gl_account, debit_credit, amount, document_type,
        intercompany_reference, description, document_date
    ) VALUES 
    (to_company, from_company, project_code,
     gl_mapping->>'expense', 'D', amount, 'INTERCO_PAYABLE',
     reference_id, description, CURRENT_DATE),
    (to_company, from_company, project_code,
     gl_mapping->>'payable', 'C', amount, 'INTERCO_PAYABLE',
     reference_id, description, CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

-- 7. Create sequence for intercompany references
CREATE SEQUENCE IF NOT EXISTS intercompany_seq START 1000;

-- 8. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_universal_journal_intercompany ON universal_journal(partner_company_code, intercompany_reference);
CREATE INDEX IF NOT EXISTS idx_projects_intercompany ON projects(lead_company_code);

-- 9. Example intercompany transactions
-- Shared services from C001 to C002
-- SELECT post_intercompany_transaction('C001', 'C002', 'SHARED_SERVICES', 'P500', 25000, 'IT Services Q1 2024');

-- Management fee from C001 to C003  
-- SELECT post_intercompany_transaction('C001', 'C003', 'MANAGEMENT_FEE', 'P500', 15000, 'Management Fee Q1 2024');