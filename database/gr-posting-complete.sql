-- COMPLETE GR AGAINST PO POSTINGS
-- All GL entries for Goods Receipt with tax implications

-- ========================================
-- 1. GR POSTING FUNCTION
-- ========================================

CREATE OR REPLACE FUNCTION post_goods_receipt(
  p_grn_number VARCHAR(20),
  p_po_number VARCHAR(20),
  p_company_code VARCHAR(10),
  p_user_id VARCHAR(50)
) RETURNS TABLE (
  posting_status VARCHAR(20),
  document_number VARCHAR(30),
  gl_entries JSON,
  total_amount DECIMAL(15,2),
  tax_amount DECIMAL(15,2)
) AS $$
DECLARE
  v_grn RECORD;
  v_po RECORD;
  v_gl_entries JSON[] := '{}';
  v_total_material_amount DECIMAL(15,2) := 0;
  v_total_tax_amount DECIMAL(15,2) := 0;
  v_total_amount DECIMAL(15,2) := 0;
  v_document_number VARCHAR(30);
  v_line RECORD;
  v_tax_calc RECORD;
BEGIN
  -- Get GRN details
  SELECT * INTO v_grn FROM goods_receipt_notes WHERE grn_number = p_grn_number;
  SELECT * INTO v_po FROM purchase_orders WHERE po_number = p_po_number;
  
  IF v_grn IS NULL OR v_po IS NULL THEN
    RETURN QUERY SELECT
      'ERROR'::VARCHAR(20),
      NULL::VARCHAR(30),
      '[]'::JSON,
      0::DECIMAL(15,2),
      0::DECIMAL(15,2);
    RETURN;
  END IF;
  
  -- Generate document number for GL posting
  v_document_number := 'GR-' || p_grn_number || '-' || to_char(CURRENT_DATE, 'YYYYMMDD');
  
  -- Process each GRN line
  FOR v_line IN
    SELECT gl.*, pol.material_code, pol.unit_price,
           mm.material_group, mm.hsn_sac_code
    FROM grn_lines gl
    JOIN purchase_order_lines pol ON gl.po_line_id = pol.po_line_id
    JOIN material_master mm ON pol.material_code = mm.material_code
    WHERE gl.grn_number = p_grn_number
      AND mm.company_code = p_company_code
  LOOP
    DECLARE
      v_line_amount DECIMAL(15,2);
      v_movement_type VARCHAR(10);
    BEGIN
      v_line_amount := v_line.received_qty * v_line.unit_price;
      v_total_material_amount := v_total_material_amount + v_line_amount;
      
      -- Determine movement type based on material group
      v_movement_type := CASE v_line.material_group
        WHEN 'EQUIPMENT' THEN 'C121' -- Capital WIP
        WHEN 'CONSUMABLES' THEN 'C101' -- Inventory
        ELSE 'C101' -- Default to inventory
      END;
      
      -- Calculate tax for this line
      SELECT * INTO v_tax_calc
      FROM get_gl_with_hsn_validation(
        p_company_code,
        v_movement_type,
        v_line.material_code,
        v_po.supplier_code,
        v_line_amount,
        v_document_number,
        v_line.hsn_sac_code,
        p_user_id
      );
      
      IF v_tax_calc.validation_status = 'SUCCESS' THEN
        v_total_tax_amount := v_total_tax_amount + v_tax_calc.total_gst;
        
        -- Material/Asset Account (Debit)
        v_gl_entries := array_append(v_gl_entries, json_build_object(
          'account_code', v_tax_calc.material_account,
          'account_name', CASE v_tax_calc.material_account
            WHEN '130200' THEN 'Raw Materials Inventory'
            WHEN '140100' THEN 'Work in Progress'
            WHEN '151000' THEN 'Capital Work in Progress'
            ELSE 'Materials'
          END,
          'debit_amount', v_line_amount,
          'credit_amount', 0,
          'material_code', v_line.material_code,
          'quantity', v_line.received_qty,
          'unit_price', v_line.unit_price,
          'reference', 'GRN Line: ' || v_line.material_code
        ));
        
        -- GST Input Accounts (Debit) - Only if GST applicable
        IF v_tax_calc.cgst_amount > 0 THEN
          v_gl_entries := array_append(v_gl_entries, json_build_object(
            'account_code', '170101',
            'account_name', 'CGST Input Credit',
            'debit_amount', v_tax_calc.cgst_amount,
            'credit_amount', 0,
            'material_code', v_line.material_code,
            'tax_rate', v_tax_calc.gst_rate / 2,
            'reference', 'CGST on GRN: ' || v_line.material_code
          ));
        END IF;
        
        IF v_tax_calc.sgst_amount > 0 THEN
          v_gl_entries := array_append(v_gl_entries, json_build_object(
            'account_code', '170102',
            'account_name', 'SGST Input Credit',
            'debit_amount', v_tax_calc.sgst_amount,
            'credit_amount', 0,
            'material_code', v_line.material_code,
            'tax_rate', v_tax_calc.gst_rate / 2,
            'reference', 'SGST on GRN: ' || v_line.material_code
          ));
        END IF;
        
        IF v_tax_calc.igst_amount > 0 THEN
          v_gl_entries := array_append(v_gl_entries, json_build_object(
            'account_code', '170103',
            'account_name', 'IGST Input Credit',
            'debit_amount', v_tax_calc.igst_amount,
            'credit_amount', 0,
            'material_code', v_line.material_code,
            'tax_rate', v_tax_calc.gst_rate,
            'reference', 'IGST on GRN: ' || v_line.material_code
          ));
        END IF;
      END IF;
    END;
  END LOOP;
  
  v_total_amount := v_total_material_amount + v_total_tax_amount;
  
  -- GRN Clearing Account (Credit) - Balancing entry
  v_gl_entries := array_append(v_gl_entries, json_build_object(
    'account_code', '154000',
    'account_name', 'GRN Clearing Account',
    'debit_amount', 0,
    'credit_amount', v_total_amount,
    'reference', 'GRN Clearing: ' || p_grn_number || ' against PO: ' || p_po_number
  ));
  
  -- Insert GL entries into accounting system
  INSERT INTO gl_transactions (
    document_number, document_type, document_date, reference,
    account_code, debit_amount, credit_amount, 
    company_code, created_by, created_at
  )
  SELECT 
    v_document_number,
    'GRN',
    CURRENT_DATE,
    (entry->>'reference')::TEXT,
    (entry->>'account_code')::VARCHAR(20),
    (entry->>'debit_amount')::DECIMAL(15,2),
    (entry->>'credit_amount')::DECIMAL(15,2),
    p_company_code,
    p_user_id,
    CURRENT_TIMESTAMP
  FROM unnest(v_gl_entries) AS entry;
  
  -- Update inventory ledger
  INSERT INTO inventory_ledger (
    material_code, transaction_type, transaction_date, 
    quantity, unit_cost, total_amount, reference,
    company_code, created_by
  )
  SELECT 
    gl.material_code,
    'GRN_RECEIPT',
    CURRENT_DATE,
    gl.received_qty,
    gl.unit_price,
    gl.line_amount,
    'GRN: ' || p_grn_number,
    p_company_code,
    p_user_id
  FROM grn_lines gl
  WHERE gl.grn_number = p_grn_number;
  
  -- Update PO line received quantities
  UPDATE purchase_order_lines pol
  SET received_qty = received_qty + gl.received_qty
  FROM grn_lines gl
  WHERE pol.po_line_id = gl.po_line_id
    AND gl.grn_number = p_grn_number;
  
  -- Update PO status if fully received
  UPDATE purchase_orders
  SET status = CASE 
    WHEN (SELECT SUM(ordered_qty - received_qty) FROM purchase_order_lines WHERE po_number = p_po_number) = 0 
    THEN 'FULLY_RECEIVED'
    ELSE 'PARTIALLY_RECEIVED'
  END
  WHERE po_number = p_po_number;
  
  RETURN QUERY SELECT
    'SUCCESS'::VARCHAR(20),
    v_document_number,
    array_to_json(v_gl_entries),
    v_total_amount,
    v_total_tax_amount;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 2. GL TRANSACTIONS TABLE
-- ========================================

CREATE TABLE IF NOT EXISTS gl_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_number VARCHAR(30) NOT NULL,
  document_type VARCHAR(10) NOT NULL, -- GRN, INV, PMT, JV
  document_date DATE NOT NULL,
  reference TEXT,
  account_code VARCHAR(20) NOT NULL,
  debit_amount DECIMAL(15,2) DEFAULT 0,
  credit_amount DECIMAL(15,2) DEFAULT 0,
  company_code VARCHAR(10) NOT NULL,
  created_by VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT check_debit_credit CHECK (
    (debit_amount > 0 AND credit_amount = 0) OR 
    (credit_amount > 0 AND debit_amount = 0)
  )
);

-- ========================================
-- 3. INVENTORY LEDGER TABLE
-- ========================================

CREATE TABLE IF NOT EXISTS inventory_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  material_code VARCHAR(20) NOT NULL,
  transaction_type VARCHAR(20) NOT NULL, -- GRN_RECEIPT, ISSUE, TRANSFER
  transaction_date DATE NOT NULL,
  quantity DECIMAL(15,3) NOT NULL,
  unit_cost DECIMAL(15,2) NOT NULL,
  total_amount DECIMAL(15,2) NOT NULL,
  reference VARCHAR(100),
  company_code VARCHAR(10) NOT NULL,
  created_by VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 4. EXAMPLE GR POSTING
-- ========================================

-- Test GR posting
SELECT 'EXAMPLE: GR Posting for Steel Purchase' as example;
SELECT * FROM post_goods_receipt('GRN-2024-001', 'PO-2024-001', 'C001', 'USER001');

-- Expected GL Entries:
-- Dr. Raw Materials Inventory (130200)     ₹1,00,000
-- Dr. CGST Input Credit (170101)           ₹9,000  
-- Dr. SGST Input Credit (170102)           ₹9,000
--     Cr. GRN Clearing Account (154000)            ₹1,18,000

SELECT 'GR POSTING SYSTEM COMPLETE' as status;