-- COMPLETE INVOICE AND PAYMENT POSTINGS
-- Completes the Procure-to-Pay cycle: PO → GR → Invoice → Payment

-- ========================================
-- 1. INVOICE POSTING FUNCTION
-- ========================================

CREATE OR REPLACE FUNCTION post_vendor_invoice(
  p_invoice_number VARCHAR(30),
  p_company_code VARCHAR(10),
  p_user_id VARCHAR(50)
) RETURNS TABLE (
  posting_status VARCHAR(20),
  document_number VARCHAR(30),
  gl_entries JSON,
  payable_amount DECIMAL(15,2),
  match_status VARCHAR(20)
) AS $$
DECLARE
  v_invoice RECORD;
  v_match_result RECORD;
  v_gl_entries JSON[] := '{}';
  v_document_number VARCHAR(30);
  v_total_payable DECIMAL(15,2) := 0;
BEGIN
  -- Get invoice details
  SELECT * INTO v_invoice FROM vendor_invoices WHERE invoice_number = p_invoice_number;
  
  IF v_invoice IS NULL THEN
    RETURN QUERY SELECT 'ERROR'::VARCHAR(20), NULL::VARCHAR(30), '[]'::JSON, 0::DECIMAL(15,2), 'NOT_FOUND'::VARCHAR(20);
    RETURN;
  END IF;
  
  -- Perform three-way match first
  SELECT * INTO v_match_result FROM perform_three_way_match(p_invoice_number);
  
  -- Only post if matched or within tolerance
  IF v_match_result.match_status NOT IN ('MATCHED', 'MATCHED_WITH_TOLERANCE') THEN
    RETURN QUERY SELECT 'BLOCKED'::VARCHAR(20), NULL::VARCHAR(30), '[]'::JSON, 0::DECIMAL(15,2), v_match_result.match_status;
    RETURN;
  END IF;
  
  v_document_number := 'INV-' || p_invoice_number || '-' || to_char(CURRENT_DATE, 'YYYYMMDD');
  v_total_payable := v_invoice.net_amount;
  
  -- GRN Clearing Account (Debit) - Reverse the GRN posting
  v_gl_entries := array_append(v_gl_entries, json_build_object(
    'account_code', '154000',
    'account_name', 'GRN Clearing Account',
    'debit_amount', v_total_payable,
    'credit_amount', 0,
    'reference', 'Clear GRN against Invoice: ' || p_invoice_number
  ));
  
  -- Trade Payables (Credit) - Create liability
  v_gl_entries := array_append(v_gl_entries, json_build_object(
    'account_code', '210100',
    'account_name', 'Trade Payables - ' || v_invoice.supplier_code,
    'debit_amount', 0,
    'credit_amount', v_total_payable,
    'reference', 'Invoice Payable: ' || v_invoice.supplier_invoice_number
  ));
  
  -- Insert GL entries
  INSERT INTO gl_transactions (
    document_number, document_type, document_date, reference,
    account_code, debit_amount, credit_amount, 
    company_code, created_by, created_at
  )
  SELECT 
    v_document_number,
    'INV',
    v_invoice.invoice_date,
    (entry->>'reference')::TEXT,
    (entry->>'account_code')::VARCHAR(20),
    (entry->>'debit_amount')::DECIMAL(15,2),
    (entry->>'credit_amount')::DECIMAL(15,2),
    p_company_code,
    p_user_id,
    CURRENT_TIMESTAMP
  FROM unnest(v_gl_entries) AS entry;
  
  -- Update invoice status
  UPDATE vendor_invoices 
  SET match_status = 'POSTED',
      payment_status = 'READY_FOR_PAYMENT'
  WHERE invoice_number = p_invoice_number;
  
  RETURN QUERY SELECT
    'SUCCESS'::VARCHAR(20),
    v_document_number,
    array_to_json(v_gl_entries),
    v_total_payable,
    v_match_result.match_status;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 2. PAYMENT POSTING FUNCTION
-- ========================================

CREATE OR REPLACE FUNCTION post_payment(
  p_payment_number VARCHAR(30),
  p_invoice_number VARCHAR(30),
  p_payment_amount DECIMAL(15,2),
  p_bank_account VARCHAR(20),
  p_payment_method VARCHAR(20), -- NEFT, RTGS, CHEQUE, CASH
  p_company_code VARCHAR(10),
  p_user_id VARCHAR(50)
) RETURNS TABLE (
  posting_status VARCHAR(20),
  document_number VARCHAR(30),
  gl_entries JSON,
  remaining_balance DECIMAL(15,2)
) AS $$
DECLARE
  v_invoice RECORD;
  v_gl_entries JSON[] := '{}';
  v_document_number VARCHAR(30);
  v_remaining_balance DECIMAL(15,2);
  v_bank_account_name VARCHAR(100);
BEGIN
  -- Get invoice details
  SELECT * INTO v_invoice FROM vendor_invoices WHERE invoice_number = p_invoice_number;
  
  IF v_invoice IS NULL OR v_invoice.payment_status = 'PAID' THEN
    RETURN QUERY SELECT 'ERROR'::VARCHAR(20), NULL::VARCHAR(30), '[]'::JSON, 0::DECIMAL(15,2);
    RETURN;
  END IF;
  
  -- Validate payment amount
  IF p_payment_amount > v_invoice.net_amount THEN
    RETURN QUERY SELECT 'OVERPAYMENT'::VARCHAR(20), NULL::VARCHAR(30), '[]'::JSON, v_invoice.net_amount;
    RETURN;
  END IF;
  
  v_document_number := 'PMT-' || p_payment_number || '-' || to_char(CURRENT_DATE, 'YYYYMMDD');
  v_remaining_balance := v_invoice.net_amount - p_payment_amount;
  
  -- Get bank account name
  v_bank_account_name := CASE p_bank_account
    WHEN '110100' THEN 'HDFC Bank Current Account'
    WHEN '110200' THEN 'ICICI Bank Current Account'
    WHEN '110300' THEN 'SBI Bank Current Account'
    ELSE 'Bank Account'
  END;
  
  -- Trade Payables (Debit) - Reduce liability
  v_gl_entries := array_append(v_gl_entries, json_build_object(
    'account_code', '210100',
    'account_name', 'Trade Payables - ' || v_invoice.supplier_code,
    'debit_amount', p_payment_amount,
    'credit_amount', 0,
    'reference', 'Payment to ' || v_invoice.supplier_code || ' - ' || p_payment_method
  ));
  
  -- Bank Account (Credit) - Reduce cash/bank
  v_gl_entries := array_append(v_gl_entries, json_build_object(
    'account_code', p_bank_account,
    'account_name', v_bank_account_name,
    'debit_amount', 0,
    'credit_amount', p_payment_amount,
    'reference', 'Payment via ' || p_payment_method || ' - ' || p_payment_number
  ));
  
  -- Insert GL entries
  INSERT INTO gl_transactions (
    document_number, document_type, document_date, reference,
    account_code, debit_amount, credit_amount, 
    company_code, created_by, created_at
  )
  SELECT 
    v_document_number,
    'PMT',
    CURRENT_DATE,
    (entry->>'reference')::TEXT,
    (entry->>'account_code')::VARCHAR(20),
    (entry->>'debit_amount')::DECIMAL(15,2),
    (entry->>'credit_amount')::DECIMAL(15,2),
    p_company_code,
    p_user_id,
    CURRENT_TIMESTAMP
  FROM unnest(v_gl_entries) AS entry;
  
  -- Insert payment record
  INSERT INTO payments (
    payment_number, invoice_number, supplier_code, payment_date,
    payment_amount, payment_method, bank_account, reference,
    company_code, created_by, created_at
  ) VALUES (
    p_payment_number, p_invoice_number, v_invoice.supplier_code, CURRENT_DATE,
    p_payment_amount, p_payment_method, p_bank_account, v_document_number,
    p_company_code, p_user_id, CURRENT_TIMESTAMP
  );
  
  -- Update invoice payment status
  UPDATE vendor_invoices 
  SET payment_status = CASE 
    WHEN v_remaining_balance = 0 THEN 'PAID'
    ELSE 'PARTIALLY_PAID'
  END
  WHERE invoice_number = p_invoice_number;
  
  RETURN QUERY SELECT
    'SUCCESS'::VARCHAR(20),
    v_document_number,
    array_to_json(v_gl_entries),
    v_remaining_balance;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 3. PAYMENTS TABLE
-- ========================================

CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_number VARCHAR(30) NOT NULL UNIQUE,
  invoice_number VARCHAR(30) NOT NULL REFERENCES vendor_invoices(invoice_number),
  supplier_code VARCHAR(20) NOT NULL,
  payment_date DATE NOT NULL,
  payment_amount DECIMAL(15,2) NOT NULL,
  payment_method VARCHAR(20) NOT NULL, -- NEFT, RTGS, CHEQUE, CASH
  bank_account VARCHAR(20) NOT NULL,
  reference VARCHAR(100),
  company_code VARCHAR(10) NOT NULL,
  created_by VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 4. COMPLETE PROCURE-TO-PAY EXAMPLE
-- ========================================

-- Step 1: GR Posting (Already done)
SELECT 'STEP 1: Goods Receipt Posted' as step;
SELECT posting_status, total_amount FROM post_goods_receipt('GRN-2024-001', 'PO-2024-001', 'C001', 'USER001');

-- Expected GL after GR:
-- Dr. Raw Materials (130200)        ₹1,00,000
-- Dr. CGST Input (170101)           ₹9,000  
-- Dr. SGST Input (170102)           ₹9,000
--     Cr. GRN Clearing (154000)             ₹1,18,000

-- Step 2: Invoice Posting
SELECT 'STEP 2: Invoice Posted' as step;
SELECT posting_status, payable_amount FROM post_vendor_invoice('INV-2024-001', 'C001', 'USER001');

-- Expected GL after Invoice:
-- Dr. GRN Clearing (154000)         ₹1,18,000
--     Cr. Trade Payables (210100)           ₹1,18,000

-- Step 3: Payment Posting  
SELECT 'STEP 3: Payment Posted' as step;
SELECT posting_status, remaining_balance FROM post_payment('PMT-2024-001', 'INV-2024-001', 118000, '110100', 'NEFT', 'C001', 'USER001');

-- Expected GL after Payment:
-- Dr. Trade Payables (210100)       ₹1,18,000
--     Cr. HDFC Bank (110100)                ₹1,18,000

-- ========================================
-- 5. FINAL ACCOUNT BALANCES
-- ========================================

SELECT 'FINAL BALANCES AFTER COMPLETE CYCLE' as summary;

-- Net effect on Balance Sheet accounts:
-- Dr. Raw Materials (130200)        ₹1,00,000  (Asset increased)
-- Dr. CGST Input (170101)           ₹9,000     (Asset - recoverable)  
-- Dr. SGST Input (170102)           ₹9,000     (Asset - recoverable)
--     Cr. HDFC Bank (110100)                ₹1,18,000  (Asset decreased)

-- Net Cash Flow: -₹1,18,000 (Cash out)
-- Net Assets: ₹1,00,000 (Inventory) + ₹18,000 (Tax Credit) - ₹1,18,000 (Cash) = ₹0

SELECT 'COMPLETE PROCURE-TO-PAY POSTING SYSTEM IMPLEMENTED' as status;