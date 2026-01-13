-- MINIMAL CHATGPT COMPLIANCE FIXES
-- Works with existing table structures

-- ========================================
-- CREATE MISSING TABLES ONLY
-- ========================================

-- Create transaction_keys table if not exists
CREATE TABLE IF NOT EXISTS transaction_keys (
  transaction_key VARCHAR(3) PRIMARY KEY,
  description VARCHAR(100) NOT NULL,
  transaction_type VARCHAR(20) NOT NULL
);

-- Insert basic transaction keys
INSERT INTO transaction_keys VALUES
('BSX', 'Inventory Posting', 'INVENTORY'),
('WRX', 'GR/IR Clearing', 'CLEARING'),
('GBB', 'Vendor Payable', 'PAYABLE'),
('PRD', 'Price Differences', 'VARIANCE'),
('QTY', 'Quantity Differences', 'INVENTORY')
ON CONFLICT (transaction_key) DO NOTHING;

-- ========================================
-- CAPITAL GOODS ITC TRACKING
-- ========================================

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
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- DYNAMIC TAX GL FUNCTION
-- ========================================

CREATE OR REPLACE FUNCTION get_tax_gl_account(
  p_company_code VARCHAR(10),
  p_country_code VARCHAR(3),
  p_tax_type VARCHAR(10),
  p_input_output VARCHAR(1)
) RETURNS VARCHAR(20) AS $$
BEGIN
  -- Return default accounts for now
  CASE 
    WHEN p_tax_type = 'CGST' THEN RETURN '170101';
    WHEN p_tax_type = 'SGST' THEN RETURN '170102';
    WHEN p_tax_type = 'IGST' THEN RETURN '170103';
    ELSE RETURN '999999';
  END CASE;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- CAPITAL GOODS ITC ENFORCEMENT
-- ========================================

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
  
  RETURN QUERY SELECT v_immediate_itc, v_deferred_itc, '170150'::VARCHAR(20);
END;
$$ LANGUAGE plpgsql;

SELECT 'MINIMAL CHATGPT COMPLIANCE FIXES APPLIED' as status;