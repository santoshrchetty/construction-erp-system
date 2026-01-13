-- COMBINED CHATGPT COMPLIANCE FIXES
-- Creates required tables first, then applies fixes

-- ========================================
-- CREATE REQUIRED TABLES FIRST
-- ========================================

-- Create transaction_keys table
CREATE TABLE IF NOT EXISTS transaction_keys (
  transaction_key VARCHAR(3) PRIMARY KEY,
  description VARCHAR(100) NOT NULL,
  transaction_type VARCHAR(20) NOT NULL,
  is_system_managed BOOLEAN DEFAULT true
);

-- Create account_determination table if not exists
CREATE TABLE IF NOT EXISTS account_determination (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_code VARCHAR(10) NOT NULL,
  transaction_key VARCHAR(3) NOT NULL,
  material_group VARCHAR(20),
  valuation_class VARCHAR(10),
  gl_account VARCHAR(20) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  UNIQUE(company_code, transaction_key, material_group, valuation_class)
);

-- Create tax_gl_mapping table if not exists
CREATE TABLE IF NOT EXISTS tax_gl_mapping (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_code VARCHAR(10) NOT NULL,
  country_code VARCHAR(3) NOT NULL,
  tax_type VARCHAR(10) NOT NULL,
  input_output VARCHAR(1) NOT NULL,
  gl_account VARCHAR(20) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  UNIQUE(company_code, country_code, tax_type, input_output)
);

-- Insert basic transaction keys
INSERT INTO transaction_keys VALUES
('BSX', 'Inventory Posting', 'INVENTORY', true),
('WRX', 'GR/IR Clearing', 'CLEARING', true),
('GBB', 'Vendor Payable', 'PAYABLE', true),
('PRD', 'Price Differences', 'VARIANCE', true),
('VBR', 'Consumption Posting', 'EXPENSE', true),
('QTY', 'Quantity Differences', 'INVENTORY', true)
ON CONFLICT (transaction_key) DO NOTHING;

-- ========================================
-- CHATGPT COMPLIANCE FIXES
-- ========================================

-- Capital goods ITC tracking table
CREATE TABLE IF NOT EXISTS capital_goods_itc_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_code VARCHAR(10) NOT NULL,
  material_code VARCHAR(20) NOT NULL,
  purchase_document VARCHAR(20) NOT NULL,
  total_itc_amount DECIMAL(15,2) NOT NULL,
  immediate_itc_amount DECIMAL(15,2) NOT NULL,
  deferred_itc_amount DECIMAL(15,2) NOT NULL,
  remaining_itc DECIMAL(15,2) NOT NULL,
  purchase_date DATE NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Function to get tax GL account dynamically
CREATE OR REPLACE FUNCTION get_tax_gl_account(
  p_company_code VARCHAR(10),
  p_country_code VARCHAR(3),
  p_tax_type VARCHAR(10),
  p_input_output VARCHAR(1)
) RETURNS VARCHAR(20) AS $$
DECLARE
  v_gl_account VARCHAR(20);
BEGIN
  SELECT gl_account INTO v_gl_account
  FROM tax_gl_mapping
  WHERE company_code = p_company_code
    AND country_code = p_country_code
    AND tax_type = p_tax_type
    AND input_output = p_input_output
    AND is_active = true;
    
  IF v_gl_account IS NULL THEN
    -- Return default account if not found
    RETURN '999999';
  END IF;
  
  RETURN v_gl_account;
END;
$$ LANGUAGE plpgsql;

-- Function to enforce capital goods ITC rules
CREATE OR REPLACE FUNCTION enforce_capital_goods_itc(
  p_company_code VARCHAR(10),
  p_material_code VARCHAR(20),
  p_purchase_document VARCHAR(20),
  p_total_tax_amount DECIMAL(15,2)
) RETURNS TABLE (
  immediate_itc DECIMAL(15,2),
  deferred_itc DECIMAL(15,2),
  gl_account VARCHAR(20)
) AS $$
DECLARE
  v_immediate_itc DECIMAL(15,2);
  v_deferred_itc DECIMAL(15,2);
  v_itc_gl_account VARCHAR(20) := '170150';
BEGIN
  -- Calculate ITC amounts (20% immediate, 80% deferred)
  v_immediate_itc := p_total_tax_amount * 0.20;
  v_deferred_itc := p_total_tax_amount * 0.80;
  
  -- Insert tracking record
  INSERT INTO capital_goods_itc_tracking (
    company_code, material_code, purchase_document,
    total_itc_amount, immediate_itc_amount, deferred_itc_amount,
    remaining_itc, purchase_date
  ) VALUES (
    p_company_code, p_material_code, p_purchase_document,
    p_total_tax_amount, v_immediate_itc, v_deferred_itc,
    v_deferred_itc, CURRENT_DATE
  );
  
  RETURN QUERY SELECT v_immediate_itc, v_deferred_itc, v_itc_gl_account;
END;
$$ LANGUAGE plpgsql;

-- Add sample account determination data
INSERT INTO account_determination VALUES
(gen_random_uuid(), 'C001', 'BSX', 'STEEL', NULL, '140101', true),
(gen_random_uuid(), 'C001', 'BSX', 'CEMENT', NULL, '140102', true),
(gen_random_uuid(), 'C001', 'WRX', NULL, NULL, '230101', true),
(gen_random_uuid(), 'C001', 'GBB', NULL, NULL, '210101', true),
(gen_random_uuid(), 'C001', 'PRD', 'STEEL', NULL, '540101', true),
(gen_random_uuid(), 'C001', 'QTY', 'STEEL', NULL, '540201', true)
ON CONFLICT (company_code, transaction_key, material_group, valuation_class) DO NOTHING;

-- Add sample tax GL mapping
INSERT INTO tax_gl_mapping VALUES
(gen_random_uuid(), 'C001', 'IND', 'CGST', 'I', '170101', true),
(gen_random_uuid(), 'C001', 'IND', 'SGST', 'I', '170102', true),
(gen_random_uuid(), 'C001', 'IND', 'IGST', 'I', '170103', true),
(gen_random_uuid(), 'C001', 'IND', 'ITC_DEFERRED', 'I', '170150', true)
ON CONFLICT (company_code, country_code, tax_type, input_output) DO NOTHING;

SELECT 'CHATGPT COMPLIANCE FIXES APPLIED SUCCESSFULLY' as status;