-- Document Reversal Functions (SAP FB08/MIGO Reversal equivalent)
-- ==============================================================

-- Add reversal tracking fields to financial_documents
ALTER TABLE financial_documents ADD COLUMN IF NOT EXISTS reversed_by VARCHAR(20);
ALTER TABLE financial_documents ADD COLUMN IF NOT EXISTS reversal_date DATE;
ALTER TABLE financial_documents ADD COLUMN IF NOT EXISTS reversal_reason TEXT;
ALTER TABLE financial_documents ADD COLUMN IF NOT EXISTS is_reversed BOOLEAN DEFAULT false;

-- Function to reverse any financial document
CREATE OR REPLACE FUNCTION reverse_document(
    p_original_doc_number VARCHAR,
    p_reversal_reason TEXT,
    p_reversal_date DATE DEFAULT CURRENT_DATE,
    p_user_id UUID DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
    v_original_doc financial_documents%ROWTYPE;
    v_reversal_doc_id UUID;
    v_reversal_doc_number VARCHAR;
    v_je_record RECORD;
    v_result JSON;
BEGIN
    -- Get original document
    SELECT * INTO v_original_doc 
    FROM financial_documents 
    WHERE document_number = p_original_doc_number;
    
    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'error', 'Document not found');
    END IF;
    
    IF v_original_doc.is_reversed THEN
        RETURN json_build_object('success', false, 'error', 'Document already reversed');
    END IF;
    
    -- Generate reversal document number
    v_reversal_doc_number := generate_document_number('REV');
    
    -- Create reversal document
    INSERT INTO financial_documents (
        id, document_number, document_type, posting_date, document_date,
        reference_document, total_amount, currency, company_code, created_by
    ) VALUES (
        uuid_generate_v4(), v_reversal_doc_number, 'REV', p_reversal_date, p_reversal_date,
        'Reversal of ' || p_original_doc_number, -v_original_doc.total_amount, 
        v_original_doc.currency, v_original_doc.company_code, p_user_id
    ) RETURNING id INTO v_reversal_doc_id;
    
    -- Create reversal journal entries (flip debit/credit)
    FOR v_je_record IN 
        SELECT * FROM journal_entries 
        WHERE document_id = v_original_doc.id 
        ORDER BY line_item
    LOOP
        INSERT INTO journal_entries (
            document_id, line_item, account_code, 
            debit_amount, credit_amount,
            project_code, wbs_element, cost_center,
            description, reference_key
        ) VALUES (
            v_reversal_doc_id, v_je_record.line_item, v_je_record.account_code,
            v_je_record.credit_amount, v_je_record.debit_amount, -- Flip amounts
            v_je_record.project_code, v_je_record.wbs_element, v_je_record.cost_center,
            'REVERSAL: ' || v_je_record.description, v_je_record.reference_key
        );
    END LOOP;
    
    -- Handle stock movements reversal
    IF v_original_doc.document_type IN ('GR', 'GI') THEN
        PERFORM reverse_stock_movements(v_original_doc.id, v_reversal_doc_id, p_reversal_date, p_user_id);
    END IF;
    
    -- Mark original document as reversed
    UPDATE financial_documents 
    SET is_reversed = true,
        reversed_by = v_reversal_doc_number,
        reversal_date = p_reversal_date,
        reversal_reason = p_reversal_reason
    WHERE id = v_original_doc.id;
    
    v_result := json_build_object(
        'success', true,
        'original_document', p_original_doc_number,
        'reversal_document', v_reversal_doc_number,
        'reversal_amount', -v_original_doc.total_amount
    );
    
    RETURN v_result;
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', SQLERRM
    );
END;
$$ LANGUAGE plpgsql;

-- Function to reverse stock movements
CREATE OR REPLACE FUNCTION reverse_stock_movements(
    p_original_doc_id UUID,
    p_reversal_doc_id UUID,
    p_reversal_date DATE,
    p_user_id UUID
) RETURNS VOID AS $$
DECLARE
    v_sm_record RECORD;
    v_reversal_doc_number VARCHAR;
BEGIN
    -- Get reversal document number
    SELECT document_number INTO v_reversal_doc_number
    FROM financial_documents WHERE id = p_reversal_doc_id;
    
    -- Reverse each stock movement
    FOR v_sm_record IN 
        SELECT sm.*, fd.document_number as original_doc_number
        FROM stock_movements sm
        JOIN financial_documents fd ON sm.reference_number = fd.document_number
        WHERE fd.id = p_original_doc_id
    LOOP
        -- Create reversal stock movement
        INSERT INTO stock_movements (
            store_id, stock_item_id, movement_type, reference_number,
            reference_type, reference_id, quantity, unit_cost, movement_date,
            account_assignment, project_code, wbs_element, created_by, notes
        ) VALUES (
            v_sm_record.store_id, v_sm_record.stock_item_id, 
            CASE v_sm_record.movement_type 
                WHEN 'receipt' THEN 'return'
                WHEN 'issue' THEN 'receipt'
                ELSE 'reversal'
            END,
            v_reversal_doc_number, 'REV', p_reversal_doc_id,
            -v_sm_record.quantity, v_sm_record.unit_cost, p_reversal_date,
            v_sm_record.account_assignment, v_sm_record.project_code, 
            v_sm_record.wbs_element, p_user_id,
            'Reversal of ' || v_sm_record.reference_number
        );
        
        -- Update stock balance
        UPDATE stock_balances 
        SET current_quantity = current_quantity - v_sm_record.quantity
        WHERE store_id = v_sm_record.store_id 
          AND stock_item_id = v_sm_record.stock_item_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to check if document can be reversed
CREATE OR REPLACE FUNCTION can_reverse_document(p_doc_number VARCHAR)
RETURNS JSON AS $$
DECLARE
    v_doc financial_documents%ROWTYPE;
    v_result JSON;
    v_issues TEXT[] := '{}';
BEGIN
    SELECT * INTO v_doc FROM financial_documents WHERE document_number = p_doc_number;
    
    IF NOT FOUND THEN
        RETURN json_build_object('can_reverse', false, 'reason', 'Document not found');
    END IF;
    
    IF v_doc.is_reversed THEN
        v_issues := array_append(v_issues, 'Document already reversed');
    END IF;
    
    -- Check if period is closed (add your period closing logic here)
    IF v_doc.posting_date < CURRENT_DATE - INTERVAL '30 days' THEN
        v_issues := array_append(v_issues, 'Posting period may be closed');
    END IF;
    
    -- Check for dependent documents (invoices, payments, etc.)
    -- Add your business logic here
    
    IF array_length(v_issues, 1) > 0 THEN
        RETURN json_build_object(
            'can_reverse', false, 
            'issues', v_issues,
            'document_type', v_doc.document_type,
            'posting_date', v_doc.posting_date
        );
    ELSE
        RETURN json_build_object(
            'can_reverse', true,
            'document_type', v_doc.document_type,
            'total_amount', v_doc.total_amount,
            'posting_date', v_doc.posting_date
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- View to show document reversal status
CREATE VIEW document_reversal_status AS
SELECT 
    fd.document_number,
    fd.document_type,
    fd.posting_date,
    fd.total_amount,
    fd.is_reversed,
    fd.reversed_by as reversal_document,
    fd.reversal_date,
    fd.reversal_reason,
    CASE 
        WHEN fd.is_reversed THEN 'REVERSED'
        WHEN EXISTS (
            SELECT 1 FROM financial_documents rev 
            WHERE rev.reference_document = 'Reversal of ' || fd.document_number
        ) THEN 'REVERSAL'
        ELSE 'ACTIVE'
    END as status
FROM financial_documents fd;

-- Indexes for reversal queries
CREATE INDEX IF NOT EXISTS idx_financial_documents_reversed ON financial_documents(is_reversed, document_number);
CREATE INDEX IF NOT EXISTS idx_financial_documents_reversal_ref ON financial_documents(reversed_by);