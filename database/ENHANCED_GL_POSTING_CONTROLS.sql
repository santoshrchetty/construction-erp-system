-- Enhanced GL Posting Tables with Business Controls
-- Step 2: Enhanced GL Tables and Validation

-- Update GL Documents table with enhanced controls
ALTER TABLE gl_documents 
ADD COLUMN IF NOT EXISTS document_type VARCHAR(2) DEFAULT 'SA',
ADD COLUMN IF NOT EXISTS fiscal_year INTEGER,
ADD COLUMN IF NOT EXISTS fiscal_period INTEGER,
ADD COLUMN IF NOT EXISTS currency_code VARCHAR(3) DEFAULT 'USD',
ADD COLUMN IF NOT EXISTS exchange_rate DECIMAL(10,6) DEFAULT 1.0,
ADD COLUMN IF NOT EXISTS total_debit DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_credit DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS posted_by UUID,
ADD COLUMN IF NOT EXISTS posted_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS reversed_by UUID,
ADD COLUMN IF NOT EXISTS reversed_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS reversal_reason VARCHAR(500);

-- Update status to use proper enum
ALTER TABLE gl_documents 
DROP CONSTRAINT IF EXISTS gl_documents_status_check;

ALTER TABLE gl_documents 
ADD CONSTRAINT gl_documents_status_check 
CHECK (status IN ('DRAFT', 'POSTED', 'REVERSED', 'PARKED', 'CANCELLED'));

-- Update GL Entries table with enhanced fields
ALTER TABLE gl_entries 
ADD COLUMN IF NOT EXISTS profit_center VARCHAR(10),
ADD COLUMN IF NOT EXISTS wbs_element VARCHAR(24),
ADD COLUMN IF NOT EXISTS tax_code VARCHAR(2),
ADD COLUMN IF NOT EXISTS tax_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS base_amount DECIMAL(15,2),
ADD COLUMN IF NOT EXISTS currency_code VARCHAR(3) DEFAULT 'USD',
ADD COLUMN IF NOT EXISTS exchange_rate DECIMAL(10,6) DEFAULT 1.0,
ADD COLUMN IF NOT EXISTS assignment VARCHAR(18),
ADD COLUMN IF NOT EXISTS text VARCHAR(50),
ADD COLUMN IF NOT EXISTS reference_key VARCHAR(12);

-- Document Type Configuration
CREATE TABLE IF NOT EXISTS document_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_type VARCHAR(2) NOT NULL UNIQUE,
    document_type_name VARCHAR(50) NOT NULL,
    number_range_object VARCHAR(10) NOT NULL,
    account_type_allowed VARCHAR(10) DEFAULT 'ALL', -- ALL, BALANCE_SHEET, P&L
    requires_approval BOOLEAN DEFAULT false,
    approval_amount_limit DECIMAL(15,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Validation Functions
CREATE OR REPLACE FUNCTION validate_gl_posting(
    p_company_code VARCHAR(4),
    p_posting_date DATE,
    p_entries JSONB
) RETURNS TABLE(is_valid BOOLEAN, error_message TEXT) AS $$
DECLARE
    v_fiscal_period RECORD;
    v_entry JSONB;
    v_account RECORD;
    v_cost_center RECORD;
    v_wbs RECORD;
    v_total_debit DECIMAL(15,2) := 0;
    v_total_credit DECIMAL(15,2) := 0;
BEGIN
    -- Check fiscal period is open
    SELECT * INTO v_fiscal_period
    FROM fiscal_year_variants 
    WHERE company_code = p_company_code 
    AND p_posting_date BETWEEN period_start_date AND period_end_date
    AND is_open = true;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Posting period is closed or not found';
        RETURN;
    END IF;
    
    -- Validate each entry
    FOR v_entry IN SELECT * FROM jsonb_array_elements(p_entries)
    LOOP
        -- Check account exists and is active
        SELECT * INTO v_account
        FROM chart_of_accounts 
        WHERE company_code = p_company_code 
        AND account_code = (v_entry->>'account_code')
        AND is_active = true;
        
        IF NOT FOUND THEN
            RETURN QUERY SELECT false, 'Account ' || (v_entry->>'account_code') || ' not found or inactive';
            RETURN;
        END IF;
        
        -- Check cost center if provided
        IF v_entry->>'cost_center' IS NOT NULL AND v_entry->>'cost_center' != '' THEN
            SELECT * INTO v_cost_center
            FROM cost_centers 
            WHERE company_code = p_company_code 
            AND cost_center_code = (v_entry->>'cost_center')
            AND is_active = true;
            
            IF NOT FOUND THEN
                RETURN QUERY SELECT false, 'Cost center ' || (v_entry->>'cost_center') || ' not found or inactive';
                RETURN;
            END IF;
        END IF;
        
        -- Check WBS element if provided
        IF v_entry->>'wbs_element' IS NOT NULL AND v_entry->>'wbs_element' != '' THEN
            SELECT * INTO v_wbs
            FROM wbs_elements 
            WHERE company_code = p_company_code 
            AND wbs_element = (v_entry->>'wbs_element')
            AND is_active = true;
            
            IF NOT FOUND THEN
                RETURN QUERY SELECT false, 'WBS element ' || (v_entry->>'wbs_element') || ' not found or inactive';
                RETURN;
            END IF;
        END IF;
        
        -- Accumulate totals
        v_total_debit := v_total_debit + COALESCE((v_entry->>'debit_amount')::DECIMAL(15,2), 0);
        v_total_credit := v_total_credit + COALESCE((v_entry->>'credit_amount')::DECIMAL(15,2), 0);
    END LOOP;
    
    -- Check balance
    IF ABS(v_total_debit - v_total_credit) > 0.01 THEN
        RETURN QUERY SELECT false, 'Document is not balanced. Debit: ' || v_total_debit || ', Credit: ' || v_total_credit;
        RETURN;
    END IF;
    
    RETURN QUERY SELECT true, 'Validation successful';
END;
$$ LANGUAGE plpgsql;

-- Document Number Generation Function
CREATE OR REPLACE FUNCTION get_next_document_number(
    p_company_code VARCHAR(4),
    p_document_type VARCHAR(2)
) RETURNS VARCHAR(10) AS $$
DECLARE
    v_current_number INTEGER;
    v_next_number VARCHAR(10);
BEGIN
    -- Get and increment current number
    UPDATE document_number_ranges 
    SET current_number = current_number + 1,
        updated_at = NOW()
    WHERE company_code = p_company_code 
    AND document_type = p_document_type
    RETURNING current_number INTO v_current_number;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Number range not found for company % document type %', p_company_code, p_document_type;
    END IF;
    
    -- Format number with leading zeros
    v_next_number := LPAD(v_current_number::TEXT, 10, '0');
    
    RETURN v_next_number;
END;
$$ LANGUAGE plpgsql;

SELECT 'Enhanced GL posting tables and functions created successfully' as status;