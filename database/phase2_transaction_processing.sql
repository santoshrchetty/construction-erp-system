-- PHASE 2: Transaction Processing - Material Documents & Financial Postings
-- Enterprise-grade transaction processing with automatic GL posting

-- =====================================================
-- MATERIAL DOCUMENTS (like SAP MSEG/MKPF)
-- =====================================================

-- Material Document Header
CREATE TABLE material_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_number VARCHAR(10) UNIQUE NOT NULL,
    document_date DATE NOT NULL,
    posting_date DATE NOT NULL,
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    plant_id UUID REFERENCES plants(id),
    created_by UUID NOT NULL,
    reference_document VARCHAR(50), -- PO Number, Transfer Order, etc.
    header_text TEXT,
    document_status VARCHAR(1) DEFAULT 'A', -- A=Active, C=Cancelled
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Material Document Items
CREATE TABLE material_document_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_document_id UUID NOT NULL REFERENCES material_documents(id) ON DELETE CASCADE,
    item_number VARCHAR(3) NOT NULL, -- 001, 002, etc.
    material_id UUID NOT NULL REFERENCES stock_items(id),
    plant_id UUID NOT NULL REFERENCES plants(id),
    storage_location_id UUID NOT NULL REFERENCES storage_locations(id),
    movement_type_id UUID NOT NULL REFERENCES movement_types(id),
    quantity DECIMAL(15,4) NOT NULL,
    unit VARCHAR(10) NOT NULL,
    amount DECIMAL(15,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'INR',
    -- Project Assignment
    project_id UUID REFERENCES projects(id),
    wbs_element_id UUID REFERENCES wbs_nodes(id),
    cost_center_id UUID REFERENCES cost_centers(id),
    -- Reference Documents
    purchase_order_id UUID REFERENCES purchase_orders(id),
    po_item_number VARCHAR(3),
    goods_receipt_id UUID REFERENCES goods_receipts(id),
    -- Special Stock
    special_stock_indicator VARCHAR(1), -- 'Q' Project Stock
    special_stock_number VARCHAR(12), -- Project Number for Q stock
    -- Batch/Serial
    batch_number VARCHAR(10),
    serial_number VARCHAR(18),
    -- Valuation
    valuation_type VARCHAR(10),
    stock_type VARCHAR(1) DEFAULT 'U', -- U=Unrestricted, Q=Quality, B=Blocked
    reason_code VARCHAR(4),
    item_text TEXT,
    UNIQUE(material_document_id, item_number)
);

-- =====================================================
-- FINANCIAL DOCUMENTS (like SAP BKPF/BSEG)
-- =====================================================

-- Financial Document Header
CREATE TABLE financial_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_number VARCHAR(10) UNIQUE NOT NULL,
    document_type VARCHAR(2) DEFAULT 'WE', -- WE=Goods Movement, RE=Invoice
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    fiscal_year INTEGER NOT NULL,
    document_date DATE NOT NULL,
    posting_date DATE NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    reference_document VARCHAR(16),
    header_text TEXT,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Financial Document Line Items
CREATE TABLE financial_document_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    financial_document_id UUID NOT NULL REFERENCES financial_documents(id) ON DELETE CASCADE,
    line_item_number VARCHAR(3) NOT NULL, -- 001, 002, etc.
    gl_account_id UUID NOT NULL REFERENCES gl_accounts(id),
    debit_credit_indicator VARCHAR(1) NOT NULL, -- 'D' or 'C'
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    -- Cost Object Assignment
    cost_center_id UUID REFERENCES cost_centers(id),
    project_id UUID REFERENCES projects(id),
    wbs_element_id UUID REFERENCES wbs_nodes(id),
    -- Material Document Reference
    material_document_id UUID REFERENCES material_documents(id),
    material_document_item_id UUID REFERENCES material_document_items(id),
    -- Additional Fields
    assignment VARCHAR(18),
    item_text TEXT,
    business_area_id UUID REFERENCES business_areas(id),
    profit_center_id UUID REFERENCES profit_centers(id),
    UNIQUE(financial_document_id, line_item_number)
);

-- =====================================================
-- POSTING LOGIC FUNCTIONS
-- =====================================================

-- Function to get GL Account from Account Determination
CREATE OR REPLACE FUNCTION get_gl_account(
    p_company_code_id UUID,
    p_valuation_class_id UUID,
    p_account_key_id UUID
) RETURNS UUID AS $$
DECLARE
    v_gl_account_id UUID;
BEGIN
    SELECT gl_account_id INTO v_gl_account_id
    FROM account_determination
    WHERE company_code_id = p_company_code_id
      AND valuation_class_id = p_valuation_class_id
      AND account_key_id = p_account_key_id
      AND is_active = true;
    
    RETURN v_gl_account_id;
END;
$$ LANGUAGE plpgsql;

-- Function to create Financial Document from Material Document
CREATE OR REPLACE FUNCTION create_financial_posting(
    p_material_document_id UUID
) RETURNS UUID AS $$
DECLARE
    v_financial_doc_id UUID;
    v_doc_number VARCHAR(10);
    v_line_number INTEGER := 0;
    mat_doc RECORD;
    mat_item RECORD;
    v_account_key RECORD;
    v_gl_account_id UUID;
    v_amount DECIMAL(15,2);
    v_debit_credit VARCHAR(1);
BEGIN
    -- Get Material Document Header
    SELECT * INTO mat_doc FROM material_documents WHERE id = p_material_document_id;
    
    -- Generate Financial Document Number
    v_doc_number := 'FI' || LPAD(nextval('financial_doc_seq')::text, 8, '0');
    
    -- Create Financial Document Header
    INSERT INTO financial_documents (
        document_number, company_code_id, fiscal_year, document_date, 
        posting_date, reference_document, created_by
    ) VALUES (
        v_doc_number, mat_doc.company_code_id, EXTRACT(YEAR FROM mat_doc.posting_date),
        mat_doc.document_date, mat_doc.posting_date, mat_doc.document_number, mat_doc.created_by
    ) RETURNING id INTO v_financial_doc_id;
    
    -- Process each Material Document Item
    FOR mat_item IN 
        SELECT mdi.*, si.valuation_class_id, mt.movement_type_code
        FROM material_document_items mdi
        JOIN stock_items si ON mdi.material_id = si.id
        JOIN movement_types mt ON mdi.movement_type_id = mt.id
        WHERE mdi.material_document_id = p_material_document_id
    LOOP
        -- Get Account Keys for this Movement Type
        FOR v_account_key IN
            SELECT ak.*, mtak.sequence_number
            FROM movement_type_account_keys mtak
            JOIN account_keys ak ON mtak.account_key_id = ak.id
            WHERE mtak.movement_type_id = mat_item.movement_type_id
            ORDER BY mtak.sequence_number
        LOOP
            -- Get GL Account from Account Determination
            v_gl_account_id := get_gl_account(
                mat_doc.company_code_id,
                mat_item.valuation_class_id,
                v_account_key.id
            );
            
            IF v_gl_account_id IS NOT NULL THEN
                v_line_number := v_line_number + 1;
                v_amount := mat_item.amount;
                v_debit_credit := v_account_key.debit_credit_indicator;
                
                -- Create Financial Document Line Item
                INSERT INTO financial_document_items (
                    financial_document_id, line_item_number, gl_account_id,
                    debit_credit_indicator, amount, cost_center_id, project_id,
                    wbs_element_id, material_document_id, material_document_item_id
                ) VALUES (
                    v_financial_doc_id, LPAD(v_line_number::text, 3, '0'), v_gl_account_id,
                    v_debit_credit, v_amount, mat_item.cost_center_id, mat_item.project_id,
                    mat_item.wbs_element_id, p_material_document_id, mat_item.id
                );
            END IF;
        END LOOP;
    END LOOP;
    
    RETURN v_financial_doc_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SEQUENCES AND TRIGGERS
-- =====================================================

-- Sequences for document numbering
CREATE SEQUENCE IF NOT EXISTS material_doc_seq START 1;
CREATE SEQUENCE IF NOT EXISTS financial_doc_seq START 1;

-- Trigger to auto-create financial postings
CREATE OR REPLACE FUNCTION trigger_create_financial_posting()
RETURNS TRIGGER AS $$
BEGIN
    -- Create financial posting for material document
    PERFORM create_financial_posting(NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER material_document_financial_posting
    AFTER INSERT ON material_documents
    FOR EACH ROW
    EXECUTE FUNCTION trigger_create_financial_posting();

-- =====================================================
-- ENHANCED VIEWS
-- =====================================================

-- Material Document Complete View
CREATE OR REPLACE VIEW material_documents_complete AS
SELECT 
    md.id,
    md.document_number,
    md.document_date,
    md.posting_date,
    cc.company_code,
    pl.plant_code,
    md.reference_document,
    md.header_text,
    -- Items
    mdi.item_number,
    si.item_code,
    si.description as material_description,
    mt.movement_type_code,
    mt.movement_type_name,
    mdi.quantity,
    mdi.unit,
    mdi.amount,
    sl.sloc_code,
    p.code as project_code,
    wbs.code as wbs_code
FROM material_documents md
LEFT JOIN company_codes cc ON md.company_code_id = cc.id
LEFT JOIN plants pl ON md.plant_id = pl.id
LEFT JOIN material_document_items mdi ON md.id = mdi.material_document_id
LEFT JOIN stock_items si ON mdi.material_id = si.id
LEFT JOIN movement_types mt ON mdi.movement_type_id = mt.id
LEFT JOIN storage_locations sl ON mdi.storage_location_id = sl.id
LEFT JOIN projects p ON mdi.project_id = p.id
LEFT JOIN wbs_nodes wbs ON mdi.wbs_element_id = wbs.id;

-- Financial Postings View
CREATE OR REPLACE VIEW financial_postings_complete AS
SELECT 
    fd.id,
    fd.document_number,
    fd.document_date,
    fd.posting_date,
    cc.company_code,
    fd.reference_document,
    -- Line Items
    fdi.line_item_number,
    gl.account_number,
    gl.account_name,
    fdi.debit_credit_indicator,
    fdi.amount,
    p.code as project_code,
    wbs.code as wbs_code,
    cost.cost_center_code
FROM financial_documents fd
LEFT JOIN company_codes cc ON fd.company_code_id = cc.id
LEFT JOIN financial_document_items fdi ON fd.id = fdi.financial_document_id
LEFT JOIN gl_accounts gl ON fdi.gl_account_id = gl.id
LEFT JOIN projects p ON fdi.project_id = p.id
LEFT JOIN wbs_nodes wbs ON fdi.wbs_element_id = wbs.id
LEFT JOIN cost_centers cost ON fdi.cost_center_id = cost.id;

-- Indexes
CREATE INDEX idx_material_documents_company ON material_documents(company_code_id);
CREATE INDEX idx_material_documents_date ON material_documents(posting_date);
CREATE INDEX idx_material_document_items_material ON material_document_items(material_id);
CREATE INDEX idx_financial_documents_company ON financial_documents(company_code_id);
CREATE INDEX idx_financial_document_items_gl ON financial_document_items(gl_account_id);
CREATE INDEX idx_financial_document_items_project ON financial_document_items(project_id);