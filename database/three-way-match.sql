-- THREE-WAY MATCH LOGIC IMPLEMENTATION
-- Matches PO → GRN → Invoice for automated payment approval

-- ========================================
-- 1. PURCHASE ORDER TRACKING
-- ========================================

CREATE TABLE purchase_orders (
  po_number VARCHAR(20) PRIMARY KEY,
  supplier_code VARCHAR(20) NOT NULL,
  po_date DATE NOT NULL,
  total_amount DECIMAL(15,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'INR',
  status VARCHAR(20) DEFAULT 'OPEN', -- OPEN, PARTIALLY_RECEIVED, FULLY_RECEIVED, CLOSED
  company_code VARCHAR(10) NOT NULL,
  created_by VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE purchase_order_lines (
  po_line_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  po_number VARCHAR(20) NOT NULL REFERENCES purchase_orders(po_number),
  line_number INTEGER NOT NULL,
  material_code VARCHAR(20) NOT NULL,
  ordered_qty DECIMAL(15,3) NOT NULL,
  unit_price DECIMAL(15,2) NOT NULL,
  line_amount DECIMAL(15,2) NOT NULL,
  received_qty DECIMAL(15,3) DEFAULT 0,
  invoiced_qty DECIMAL(15,3) DEFAULT 0,
  
  UNIQUE(po_number, line_number)
);

-- ========================================
-- 2. GOODS RECEIPT NOTE (GRN)
-- ========================================

CREATE TABLE goods_receipt_notes (
  grn_number VARCHAR(20) PRIMARY KEY,
  po_number VARCHAR(20) NOT NULL REFERENCES purchase_orders(po_number),
  supplier_code VARCHAR(20) NOT NULL,
  receipt_date DATE NOT NULL,
  total_received_amount DECIMAL(15,2) NOT NULL,
  status VARCHAR(20) DEFAULT 'PENDING_INVOICE', -- PENDING_INVOICE, MATCHED, DISCREPANCY
  company_code VARCHAR(10) NOT NULL,
  created_by VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE grn_lines (
  grn_line_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  grn_number VARCHAR(20) NOT NULL REFERENCES goods_receipt_notes(grn_number),
  po_line_id UUID NOT NULL REFERENCES purchase_order_lines(po_line_id),
  material_code VARCHAR(20) NOT NULL,
  received_qty DECIMAL(15,3) NOT NULL,
  unit_price DECIMAL(15,2) NOT NULL,
  line_amount DECIMAL(15,2) NOT NULL,
  quality_status VARCHAR(20) DEFAULT 'ACCEPTED' -- ACCEPTED, REJECTED, PENDING_QC
);

-- ========================================
-- 3. VENDOR INVOICE
-- ========================================

CREATE TABLE vendor_invoices (
  invoice_number VARCHAR(30) PRIMARY KEY,
  supplier_invoice_number VARCHAR(30) NOT NULL,
  supplier_code VARCHAR(20) NOT NULL,
  invoice_date DATE NOT NULL,
  total_amount DECIMAL(15,2) NOT NULL,
  tax_amount DECIMAL(15,2) DEFAULT 0,
  net_amount DECIMAL(15,2) NOT NULL,
  match_status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, MATCHED, DISCREPANCY, APPROVED, PAID
  payment_status VARCHAR(20) DEFAULT 'UNPAID', -- UNPAID, PAID, PARTIALLY_PAID
  company_code VARCHAR(10) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE invoice_lines (
  invoice_line_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number VARCHAR(30) NOT NULL REFERENCES vendor_invoices(invoice_number),
  grn_line_id UUID REFERENCES grn_lines(grn_line_id),
  material_code VARCHAR(20) NOT NULL,
  invoiced_qty DECIMAL(15,3) NOT NULL,
  unit_price DECIMAL(15,2) NOT NULL,
  line_amount DECIMAL(15,2) NOT NULL,
  tax_amount DECIMAL(15,2) DEFAULT 0
);

-- ========================================
-- 4. THREE-WAY MATCH VALIDATION FUNCTION
-- ========================================

CREATE OR REPLACE FUNCTION perform_three_way_match(
  p_invoice_number VARCHAR(30)
) RETURNS TABLE (
  match_status VARCHAR(20),
  match_result JSON,
  discrepancies JSON,
  approval_required BOOLEAN,
  auto_approve BOOLEAN
) AS $$
DECLARE
  v_invoice RECORD;
  v_match_result JSON := '{}';
  v_discrepancies JSON := '[]';
  v_total_discrepancy DECIMAL(15,2) := 0;
  v_line_matches JSON[];
  v_line RECORD;
  v_tolerance_percent DECIMAL(5,2) := 5.0; -- 5% tolerance
BEGIN
  -- Get invoice details
  SELECT * INTO v_invoice
  FROM vendor_invoices
  WHERE invoice_number = p_invoice_number;
  
  IF v_invoice IS NULL THEN
    RETURN QUERY SELECT
      'ERROR'::VARCHAR(20),
      '{"error": "Invoice not found"}'::JSON,
      '[]'::JSON,
      false,
      false;
    RETURN;
  END IF;
  
  -- Check each invoice line against GRN and PO
  FOR v_line IN 
    SELECT il.*, gl.received_qty, gl.unit_price as grn_unit_price,
           pol.ordered_qty, pol.unit_price as po_unit_price,
           gl.grn_number, pol.po_number
    FROM invoice_lines il
    LEFT JOIN grn_lines gl ON il.grn_line_id = gl.grn_line_id
    LEFT JOIN purchase_order_lines pol ON gl.po_line_id = pol.po_line_id
    WHERE il.invoice_number = p_invoice_number
  LOOP
    DECLARE
      v_qty_match BOOLEAN;
      v_price_match BOOLEAN;
      v_amount_match BOOLEAN;
      v_line_discrepancy DECIMAL(15,2);
    BEGIN
      -- Quantity Match: Invoice Qty ≤ Received Qty
      v_qty_match := v_line.invoiced_qty <= v_line.received_qty;
      
      -- Price Match: Within tolerance
      v_price_match := ABS(v_line.unit_price - v_line.grn_unit_price) / v_line.grn_unit_price * 100 <= v_tolerance_percent;
      
      -- Amount Match: Calculate discrepancy
      v_line_discrepancy := ABS(v_line.line_amount - (v_line.invoiced_qty * v_line.grn_unit_price));
      v_amount_match := v_line_discrepancy / (v_line.invoiced_qty * v_line.grn_unit_price) * 100 <= v_tolerance_percent;
      
      v_total_discrepancy := v_total_discrepancy + v_line_discrepancy;
      
      -- Build line match result
      v_line_matches := array_append(v_line_matches, json_build_object(
        'material_code', v_line.material_code,
        'po_number', v_line.po_number,
        'grn_number', v_line.grn_number,
        'ordered_qty', v_line.ordered_qty,
        'received_qty', v_line.received_qty,
        'invoiced_qty', v_line.invoiced_qty,
        'po_price', v_line.po_unit_price,
        'grn_price', v_line.grn_unit_price,
        'invoice_price', v_line.unit_price,
        'qty_match', v_qty_match,
        'price_match', v_price_match,
        'amount_match', v_amount_match,
        'discrepancy_amount', v_line_discrepancy
      ));
      
      -- Add to discrepancies if not matching
      IF NOT (v_qty_match AND v_price_match AND v_amount_match) THEN
        v_discrepancies := v_discrepancies || json_build_object(
          'material_code', v_line.material_code,
          'issue_type', CASE 
            WHEN NOT v_qty_match THEN 'QUANTITY_MISMATCH'
            WHEN NOT v_price_match THEN 'PRICE_VARIANCE'
            WHEN NOT v_amount_match THEN 'AMOUNT_VARIANCE'
          END,
          'expected', CASE 
            WHEN NOT v_qty_match THEN v_line.received_qty
            ELSE v_line.grn_unit_price
          END,
          'actual', CASE 
            WHEN NOT v_qty_match THEN v_line.invoiced_qty
            ELSE v_line.unit_price
          END,
          'discrepancy_amount', v_line_discrepancy
        );
      END IF;
    END;
  END LOOP;
  
  -- Build final match result
  v_match_result := json_build_object(
    'invoice_number', p_invoice_number,
    'total_discrepancy', v_total_discrepancy,
    'tolerance_percent', v_tolerance_percent,
    'line_matches', array_to_json(v_line_matches)
  );
  
  -- Determine final status
  DECLARE
    v_final_status VARCHAR(20);
    v_auto_approve BOOLEAN := false;
    v_approval_required BOOLEAN := true;
  BEGIN
    IF json_array_length(v_discrepancies) = 0 THEN
      v_final_status := 'MATCHED';
      v_auto_approve := true;
      v_approval_required := false;
    ELSIF v_total_discrepancy / v_invoice.net_amount * 100 <= v_tolerance_percent THEN
      v_final_status := 'MATCHED_WITH_TOLERANCE';
      v_auto_approve := true;
      v_approval_required := false;
    ELSE
      v_final_status := 'DISCREPANCY';
      v_auto_approve := false;
      v_approval_required := true;
    END IF;
    
    -- Update invoice status
    UPDATE vendor_invoices 
    SET match_status = v_final_status
    WHERE invoice_number = p_invoice_number;
    
    RETURN QUERY SELECT
      v_final_status,
      v_match_result,
      v_discrepancies,
      v_approval_required,
      v_auto_approve;
  END;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 5. AUTOMATED APPROVAL WORKFLOW
-- ========================================

CREATE OR REPLACE FUNCTION process_matched_invoice(
  p_invoice_number VARCHAR(30)
) RETURNS TABLE (
  processing_status VARCHAR(20),
  gl_entries JSON,
  payment_eligible BOOLEAN
) AS $$
DECLARE
  v_invoice RECORD;
  v_match_result RECORD;
  v_gl_entries JSON[];
BEGIN
  -- Get invoice and match status
  SELECT * INTO v_invoice FROM vendor_invoices WHERE invoice_number = p_invoice_number;
  SELECT * INTO v_match_result FROM perform_three_way_match(p_invoice_number);
  
  -- Only process if matched
  IF v_match_result.auto_approve THEN
    -- Create GL entries for matched invoice
    v_gl_entries := array_append(v_gl_entries, json_build_object(
      'account', '210100', -- Trade Payables
      'amount', v_invoice.net_amount,
      'type', 'CREDIT'
    ));
    
    v_gl_entries := array_append(v_gl_entries, json_build_object(
      'account', '130200', -- Inventory (from GRN)
      'amount', v_invoice.net_amount - v_invoice.tax_amount,
      'type', 'DEBIT'
    ));
    
    IF v_invoice.tax_amount > 0 THEN
      v_gl_entries := array_append(v_gl_entries, json_build_object(
        'account', '170100', -- Tax Input
        'amount', v_invoice.tax_amount,
        'type', 'DEBIT'
      ));
    END IF;
    
    -- Update invoice status
    UPDATE vendor_invoices 
    SET match_status = 'APPROVED',
        payment_status = 'READY_FOR_PAYMENT'
    WHERE invoice_number = p_invoice_number;
    
    RETURN QUERY SELECT
      'AUTO_APPROVED'::VARCHAR(20),
      array_to_json(v_gl_entries),
      true;
  ELSE
    RETURN QUERY SELECT
      'REQUIRES_APPROVAL'::VARCHAR(20),
      '[]'::JSON,
      false;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 6. TEST THREE-WAY MATCH SCENARIO
-- ========================================

-- Sample data for testing
INSERT INTO purchase_orders VALUES ('PO-2024-001', 'STEEL_SUPPLIER', '2024-01-15', 118000, 'INR', 'OPEN', 'C001', 'USER001');
INSERT INTO purchase_order_lines VALUES (gen_random_uuid(), 'PO-2024-001', 1, 'STEEL_TMT_8MM', 10.000, 10000, 100000);

SELECT 'THREE-WAY MATCH SYSTEM IMPLEMENTED' as status;