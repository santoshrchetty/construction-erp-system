-- SIMPLIFIED GL DETERMINATION LOGIC
-- Maps Movement Type + Material + Supplier → Complete GL Accounts

-- ========================================
-- 1. GL ACCOUNT MASTER
-- ========================================

CREATE TABLE gl_account_master (
  account_code VARCHAR(20) PRIMARY KEY,
  account_name VARCHAR(100) NOT NULL,
  account_type VARCHAR(20) NOT NULL, -- ASSET, LIABILITY, INCOME, EXPENSE
  account_group VARCHAR(50) NOT NULL,
  is_active BOOLEAN DEFAULT true
);

INSERT INTO gl_account_master VALUES
-- Asset Accounts
('110100', 'HDFC Bank Current Account', 'ASSET', 'CASH_AND_BANK'),
('110200', 'ICICI Bank Current Account', 'ASSET', 'CASH_AND_BANK'),
('130200', 'Raw Materials Inventory', 'ASSET', 'INVENTORY'),
('140100', 'Work in Progress', 'ASSET', 'INVENTORY'),
('151000', 'Capital Work in Progress', 'ASSET', 'FIXED_ASSETS'),
('170101', 'CGST Input Credit', 'ASSET', 'TAX_RECOVERABLE'),
('170102', 'SGST Input Credit', 'ASSET', 'TAX_RECOVERABLE'),
('170103', 'IGST Input Credit', 'ASSET', 'TAX_RECOVERABLE'),

-- Liability Accounts  
('210100', 'Trade Payables', 'LIABILITY', 'CURRENT_LIABILITIES'),
('154000', 'GRN Clearing Account', 'LIABILITY', 'CURRENT_LIABILITIES'),

-- Expense Accounts
('500100', 'Material Consumption', 'EXPENSE', 'DIRECT_COSTS'),
('500200', 'Equipment Rental', 'EXPENSE', 'DIRECT_COSTS'),
('600100', 'Administrative Expenses', 'EXPENSE', 'INDIRECT_COSTS');

-- ========================================
-- 2. MOVEMENT TYPE MAPPING
-- ========================================

CREATE TABLE movement_type_mapping (
  movement_type VARCHAR(10) PRIMARY KEY,
  movement_description VARCHAR(100) NOT NULL,
  debit_account VARCHAR(20) NOT NULL REFERENCES gl_account_master(account_code),
  account_determination_logic TEXT,
  is_active BOOLEAN DEFAULT true
);

INSERT INTO movement_type_mapping VALUES
('C101', 'Purchase Receipt to Inventory', '130200', 'Raw materials and consumables'),
('C111', 'Purchase Receipt to WIP', '140100', 'Direct project materials'),  
('C121', 'Purchase Receipt to Capital WIP', '151000', 'Capital goods and equipment'),
('C201', 'Material Issue to Project', '500100', 'Material consumption expense'),
('C301', 'Equipment Rental', '500200', 'Equipment and machinery rental');

-- ========================================
-- 3. SIMPLIFIED GL DETERMINATION
-- ========================================

CREATE OR REPLACE FUNCTION get_gl_accounts_simple(
  p_movement_type VARCHAR(10),
  p_material_code VARCHAR(20),
  p_supplier_code VARCHAR(20),
  p_amount DECIMAL(15,2),
  p_company_code VARCHAR(10)
) RETURNS TABLE (
  material_account VARCHAR(20),
  material_account_name VARCHAR(100),
  material_amount DECIMAL(15,2),
  cgst_account VARCHAR(20),
  cgst_amount DECIMAL(15,2),
  sgst_account VARCHAR(20), 
  sgst_amount DECIMAL(15,2),
  igst_account VARCHAR(20),
  igst_amount DECIMAL(15,2),
  payable_account VARCHAR(20),
  payable_amount DECIMAL(15,2),
  total_amount DECIMAL(15,2)
) AS $$
DECLARE
  v_material RECORD;
  v_movement RECORD;
  v_supplier_state VARCHAR(2);
  v_company_state VARCHAR(2);
  v_gst_rate DECIMAL(5,2);
  v_cgst DECIMAL(15,2) := 0;
  v_sgst DECIMAL(15,2) := 0;
  v_igst DECIMAL(15,2) := 0;
  v_total_tax DECIMAL(15,2);
BEGIN
  -- Get movement type mapping
  SELECT * INTO v_movement FROM movement_type_mapping WHERE movement_type = p_movement_type;
  
  -- Get material details
  SELECT * INTO v_material FROM material_master 
  WHERE material_code = p_material_code AND company_code = p_company_code;
  
  -- Get GST rate
  SELECT gst_rate INTO v_gst_rate FROM gst_rates_simple 
  WHERE hsn_code = v_material.hsn_sac_code AND company_code = p_company_code;
  
  -- Default GST rate if not found
  v_gst_rate := COALESCE(v_gst_rate, 18.0);
  
  -- Get states
  SELECT state_code INTO v_supplier_state FROM entity_states 
  WHERE entity_code = p_supplier_code;
  
  SELECT state_code INTO v_company_state FROM entity_states 
  WHERE entity_type = 'COMPANY' AND company_code = p_company_code;
  
  -- Calculate GST
  IF v_supplier_state = v_company_state THEN
    -- Intra-state: CGST + SGST
    v_cgst := p_amount * v_gst_rate / 200;
    v_sgst := p_amount * v_gst_rate / 200;
  ELSE
    -- Inter-state: IGST
    v_igst := p_amount * v_gst_rate / 100;
  END IF;
  
  v_total_tax := v_cgst + v_sgst + v_igst;
  
  RETURN QUERY SELECT
    v_movement.debit_account,
    (SELECT account_name FROM gl_account_master WHERE account_code = v_movement.debit_account),
    p_amount,
    CASE WHEN v_cgst > 0 THEN '170101'::VARCHAR(20) ELSE NULL END,
    v_cgst,
    CASE WHEN v_sgst > 0 THEN '170102'::VARCHAR(20) ELSE NULL END,
    v_sgst,
    CASE WHEN v_igst > 0 THEN '170103'::VARCHAR(20) ELSE NULL END,
    v_igst,
    '210100'::VARCHAR(20),
    p_amount + v_total_tax,
    p_amount + v_total_tax;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 4. GL DETERMINATION WITH VALIDATION
-- ========================================

CREATE OR REPLACE FUNCTION determine_gl_accounts(
  p_transaction_type VARCHAR(20), -- GRN, INVOICE, PAYMENT
  p_movement_type VARCHAR(10),
  p_material_code VARCHAR(20),
  p_supplier_code VARCHAR(20),
  p_amount DECIMAL(15,2),
  p_company_code VARCHAR(10)
) RETURNS TABLE (
  account_code VARCHAR(20),
  account_name VARCHAR(100),
  debit_amount DECIMAL(15,2),
  credit_amount DECIMAL(15,2),
  line_description TEXT
) AS $$
DECLARE
  v_gl_result RECORD;
BEGIN
  -- Get GL accounts
  SELECT * INTO v_gl_result FROM get_gl_accounts_simple(
    p_movement_type, p_material_code, p_supplier_code, p_amount, p_company_code
  );
  
  IF p_transaction_type = 'GRN' THEN
    -- GRN Postings
    RETURN QUERY SELECT
      v_gl_result.material_account,
      v_gl_result.material_account_name,
      v_gl_result.material_amount,
      0::DECIMAL(15,2),
      'Material Receipt: ' || p_material_code;
    
    IF v_gl_result.cgst_amount > 0 THEN
      RETURN QUERY SELECT '170101'::VARCHAR(20), 'CGST Input Credit'::VARCHAR(100), 
                          v_gl_result.cgst_amount, 0::DECIMAL(15,2), 'CGST Input'::TEXT;
    END IF;
    
    IF v_gl_result.sgst_amount > 0 THEN
      RETURN QUERY SELECT '170102'::VARCHAR(20), 'SGST Input Credit'::VARCHAR(100),
                          v_gl_result.sgst_amount, 0::DECIMAL(15,2), 'SGST Input'::TEXT;
    END IF;
    
    IF v_gl_result.igst_amount > 0 THEN
      RETURN QUERY SELECT '170103'::VARCHAR(20), 'IGST Input Credit'::VARCHAR(100),
                          v_gl_result.igst_amount, 0::DECIMAL(15,2), 'IGST Input'::TEXT;
    END IF;
    
    RETURN QUERY SELECT '154000'::VARCHAR(20), 'GRN Clearing Account'::VARCHAR(100),
                        0::DECIMAL(15,2), v_gl_result.total_amount, 'GRN Clearing'::TEXT;
  
  ELSIF p_transaction_type = 'INVOICE' THEN
    -- Invoice Postings
    RETURN QUERY SELECT '154000'::VARCHAR(20), 'GRN Clearing Account'::VARCHAR(100),
                        v_gl_result.total_amount, 0::DECIMAL(15,2), 'Clear GRN'::TEXT;
    
    RETURN QUERY SELECT '210100'::VARCHAR(20), 'Trade Payables'::VARCHAR(100),
                        0::DECIMAL(15,2), v_gl_result.total_amount, 'Invoice Payable'::TEXT;
  
  ELSIF p_transaction_type = 'PAYMENT' THEN
    -- Payment Postings  
    RETURN QUERY SELECT '210100'::VARCHAR(20), 'Trade Payables'::VARCHAR(100),
                        v_gl_result.total_amount, 0::DECIMAL(15,2), 'Payment to Supplier'::TEXT;
    
    RETURN QUERY SELECT '110100'::VARCHAR(20), 'Bank Account'::VARCHAR(100),
                        0::DECIMAL(15,2), v_gl_result.total_amount, 'Bank Payment'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 5. TEST GL DETERMINATION
-- ========================================

-- Test GRN GL determination
SELECT 'GRN GL DETERMINATION TEST' as test_type;
SELECT * FROM determine_gl_accounts('GRN', 'C101', 'STEEL_TMT_8MM', 'STEEL_SUPPLIER', 100000, 'C001');

-- Test Invoice GL determination  
SELECT 'INVOICE GL DETERMINATION TEST' as test_type;
SELECT * FROM determine_gl_accounts('INVOICE', 'C101', 'STEEL_TMT_8MM', 'STEEL_SUPPLIER', 118000, 'C001');

-- Test Payment GL determination
SELECT 'PAYMENT GL DETERMINATION TEST' as test_type;
SELECT * FROM determine_gl_accounts('PAYMENT', 'C101', 'STEEL_TMT_8MM', 'STEEL_SUPPLIER', 118000, 'C001');

SELECT 'GL DETERMINATION SYSTEM COMPLETE' as status;