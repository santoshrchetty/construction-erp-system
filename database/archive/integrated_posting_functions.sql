-- Integrated Posting Functions for Construction Transactions
-- =========================================================

-- Function to post Goods Receipt (MIGO 101)
CREATE OR REPLACE FUNCTION post_goods_receipt(
    p_po_number VARCHAR,
    p_vendor_id UUID,
    p_material_code VARCHAR,
    p_quantity DECIMAL,
    p_unit_price DECIMAL,
    p_project_code VARCHAR DEFAULT NULL,
    p_wbs_element VARCHAR DEFAULT NULL,
    p_posting_date DATE DEFAULT CURRENT_DATE,
    p_user_id UUID DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
    v_doc_id UUID;
    v_doc_number VARCHAR;
    v_total_amount DECIMAL;
    v_result JSON;
BEGIN
    v_total_amount := p_quantity * p_unit_price;
    v_doc_number := generate_document_number('GR');
    
    -- Create Financial Document
    INSERT INTO financial_documents (
        id, document_number, document_type, posting_date, document_date,
        reference_document, total_amount, created_by
    ) VALUES (
        uuid_generate_v4(), v_doc_number, 'GR', p_posting_date, p_posting_date,
        p_po_number, v_total_amount, p_user_id
    ) RETURNING id INTO v_doc_id;
    
    -- FI Posting: Debit Inventory, Credit GR/IR Clearing
    INSERT INTO journal_entries (
        document_id, line_item, account_code, debit_amount, 
        project_code, wbs_element, description
    ) VALUES 
    (v_doc_id, 1, '140000', v_total_amount, p_project_code, p_wbs_element, 
     'GR: ' || p_material_code || ' Qty: ' || p_quantity),
    (v_doc_id, 2, '201000', 0, NULL, NULL, 
     'GR/IR Clearing - PO: ' || p_po_number);
    
    UPDATE journal_entries 
    SET credit_amount = v_total_amount 
    WHERE document_id = v_doc_id AND line_item = 2;
    
    -- Update Stock Balance
    INSERT INTO stock_balances (
        store_id, stock_item_id, current_quantity, average_cost,
        stock_type, account_assignment, project_code, wbs_element
    ) 
    SELECT 
        s.id, si.id, p_quantity, p_unit_price,
        CASE WHEN p_project_code IS NOT NULL THEN 'PROJECT' ELSE 'WAREHOUSE' END,
        CASE WHEN p_project_code IS NOT NULL THEN 'P' ELSE 'W' END,
        p_project_code, p_wbs_element
    FROM stores s, stock_items si 
    WHERE s.code = '0001' AND si.item_code = p_material_code
    ON CONFLICT (store_id, stock_item_id) 
    DO UPDATE SET 
        current_quantity = stock_balances.current_quantity + p_quantity,
        average_cost = ((stock_balances.current_quantity * stock_balances.average_cost) + 
                       (p_quantity * p_unit_price)) / 
                       (stock_balances.current_quantity + p_quantity);
    
    -- Create Stock Movement
    INSERT INTO stock_movements (
        store_id, stock_item_id, movement_type, reference_number,
        reference_type, quantity, unit_cost, movement_date,
        account_assignment, project_code, wbs_element, created_by
    )
    SELECT 
        s.id, si.id, 'receipt', v_doc_number,
        'GR', p_quantity, p_unit_price, p_posting_date,
        CASE WHEN p_project_code IS NOT NULL THEN 'P' ELSE 'W' END,
        p_project_code, p_wbs_element, p_user_id
    FROM stores s, stock_items si 
    WHERE s.code = '0001' AND si.item_code = p_material_code;
    
    v_result := json_build_object(
        'success', true,
        'document_number', v_doc_number,
        'document_id', v_doc_id,
        'amount', v_total_amount
    );
    
    RETURN v_result;
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', SQLERRM
    );
END;
$$ LANGUAGE plpgsql;

-- Function to post Goods Issue (MIGO 261)
CREATE OR REPLACE FUNCTION post_goods_issue(
    p_material_code VARCHAR,
    p_quantity DECIMAL,
    p_project_code VARCHAR,
    p_wbs_element VARCHAR,
    p_cost_center VARCHAR DEFAULT NULL,
    p_posting_date DATE DEFAULT CURRENT_DATE,
    p_user_id UUID DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
    v_doc_id UUID;
    v_doc_number VARCHAR;
    v_unit_cost DECIMAL;
    v_total_amount DECIMAL;
    v_result JSON;
BEGIN
    -- Get current average cost
    SELECT average_cost INTO v_unit_cost
    FROM stock_balances sb
    JOIN stock_items si ON sb.stock_item_id = si.id
    JOIN stores s ON sb.store_id = s.id
    WHERE si.item_code = p_material_code AND s.code = '0001'
    LIMIT 1;
    
    IF v_unit_cost IS NULL THEN
        RETURN json_build_object('success', false, 'error', 'Material not found in stock');
    END IF;
    
    v_total_amount := p_quantity * v_unit_cost;
    v_doc_number := generate_document_number('GI');
    
    -- Create Financial Document
    INSERT INTO financial_documents (
        id, document_number, document_type, posting_date, document_date,
        reference_document, total_amount, created_by
    ) VALUES (
        uuid_generate_v4(), v_doc_number, 'GI', p_posting_date, p_posting_date,
        p_project_code || '/' || p_wbs_element, v_total_amount, p_user_id
    ) RETURNING id INTO v_doc_id;
    
    -- FI/CO Posting: Debit Project Cost, Credit Inventory
    INSERT INTO journal_entries (
        document_id, line_item, account_code, debit_amount,
        project_code, wbs_element, cost_center, description
    ) VALUES 
    (v_doc_id, 1, '400100', v_total_amount, p_project_code, p_wbs_element, p_cost_center,
     'Material Consumption: ' || p_material_code || ' Qty: ' || p_quantity),
    (v_doc_id, 2, '140000', 0, NULL, NULL, NULL,
     'Inventory Reduction: ' || p_material_code);
    
    UPDATE journal_entries 
    SET credit_amount = v_total_amount 
    WHERE document_id = v_doc_id AND line_item = 2;
    
    -- Update Stock Balance
    UPDATE stock_balances 
    SET current_quantity = current_quantity - p_quantity
    FROM stock_items si, stores s
    WHERE stock_balances.stock_item_id = si.id 
      AND stock_balances.store_id = s.id
      AND si.item_code = p_material_code 
      AND s.code = '0001';
    
    -- Create Stock Movement
    INSERT INTO stock_movements (
        store_id, stock_item_id, movement_type, reference_number,
        reference_type, quantity, unit_cost, movement_date,
        account_assignment, project_code, wbs_element, created_by
    )
    SELECT 
        s.id, si.id, 'issue', v_doc_number,
        'GI', -p_quantity, v_unit_cost, p_posting_date,
        'P', p_project_code, p_wbs_element, p_user_id
    FROM stores s, stock_items si 
    WHERE s.code = '0001' AND si.item_code = p_material_code;
    
    v_result := json_build_object(
        'success', true,
        'document_number', v_doc_number,
        'document_id', v_doc_id,
        'amount', v_total_amount,
        'unit_cost', v_unit_cost
    );
    
    RETURN v_result;
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', SQLERRM
    );
END;
$$ LANGUAGE plpgsql;

-- Function to post Labor Costs (Timesheet Integration)
CREATE OR REPLACE FUNCTION post_labor_cost(
    p_employee_id UUID,
    p_hours DECIMAL,
    p_hourly_rate DECIMAL,
    p_project_code VARCHAR,
    p_wbs_element VARCHAR,
    p_cost_center VARCHAR DEFAULT NULL,
    p_posting_date DATE DEFAULT CURRENT_DATE,
    p_user_id UUID DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
    v_doc_id UUID;
    v_doc_number VARCHAR;
    v_total_amount DECIMAL;
    v_result JSON;
BEGIN
    v_total_amount := p_hours * p_hourly_rate;
    v_doc_number := generate_document_number('LAB');
    
    -- Create Financial Document
    INSERT INTO financial_documents (
        id, document_number, document_type, posting_date, document_date,
        reference_document, total_amount, created_by
    ) VALUES (
        uuid_generate_v4(), v_doc_number, 'LAB', p_posting_date, p_posting_date,
        'EMP-' || p_employee_id::text, v_total_amount, p_user_id
    ) RETURNING id INTO v_doc_id;
    
    -- FI/CO Posting: Debit Project Labor Cost, Credit Accrued Payroll
    INSERT INTO journal_entries (
        document_id, line_item, account_code, debit_amount,
        project_code, wbs_element, cost_center, description
    ) VALUES 
    (v_doc_id, 1, '600100', v_total_amount, p_project_code, p_wbs_element, p_cost_center,
     'Labor Cost: ' || p_hours || ' hrs @ ' || p_hourly_rate),
    (v_doc_id, 2, '200000', 0, NULL, NULL, NULL,
     'Accrued Payroll');
    
    UPDATE journal_entries 
    SET credit_amount = v_total_amount 
    WHERE document_id = v_doc_id AND line_item = 2;
    
    v_result := json_build_object(
        'success', true,
        'document_number', v_doc_number,
        'document_id', v_doc_id,
        'amount', v_total_amount
    );
    
    RETURN v_result;
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', SQLERRM
    );
END;
$$ LANGUAGE plpgsql;