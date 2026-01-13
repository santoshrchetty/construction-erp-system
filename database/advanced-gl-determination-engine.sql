-- Financial & Compliance Wizard: Advanced GL Determination Engine
-- Handles GST rate changes, input credit restrictions, regulatory updates

-- 1. GST MASTER DATA FRAMEWORK
CREATE TABLE gst_rate_master (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hsn_sac_code VARCHAR(10) NOT NULL,
  commodity_description TEXT NOT NULL,
  
  -- GST Rate Structure
  cgst_rate DECIMAL(5,2) DEFAULT 0,
  sgst_rate DECIMAL(5,2) DEFAULT 0,
  igst_rate DECIMAL(5,2) DEFAULT 0,
  cess_rate DECIMAL(5,2) DEFAULT 0,
  total_gst_rate DECIMAL(5,2) GENERATED ALWAYS AS (cgst_rate + sgst_rate + igst_rate + cess_rate) STORED,
  
  -- Input Credit Rules
  input_credit_category VARCHAR(20) NOT NULL, -- IMMEDIATE, RESTRICTED, BLOCKED, PHASED
  capital_goods_flag BOOLEAN DEFAULT false,
  input_credit_percentage DECIMAL(5,2) DEFAULT 100.00,
  phasing_period_months INTEGER DEFAULT 0,
  
  -- Regulatory Tracking
  notification_number VARCHAR(50),
  effective_date DATE NOT NULL,
  end_date DATE,
  amendment_reason TEXT,
  
  -- Compliance Flags
  reverse_charge_applicable BOOLEAN DEFAULT false,
  composition_scheme_eligible BOOLEAN DEFAULT true,
  
  company_code VARCHAR(10) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Ensure no overlapping rates for same HSN
  CONSTRAINT unique_hsn_period EXCLUDE USING gist (
    hsn_sac_code WITH =,
    company_code WITH =,
    daterange(effective_date, COALESCE(end_date, '9999-12-31'::date), '[]') WITH &&
  )
);

-- 2. DYNAMIC GL ACCOUNT MAPPING
CREATE TABLE dynamic_gl_mapping (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Transaction Context
  company_code VARCHAR(10) NOT NULL,
  movement_type VARCHAR(10) NOT NULL,
  valuation_class VARCHAR(20) NOT NULL,
  business_process VARCHAR(50) NOT NULL,
  
  -- GST Context
  gst_nature VARCHAR(20) NOT NULL, -- GOODS, SERVICES, CAPITAL_GOODS
  input_credit_category VARCHAR(20) NOT NULL,
  
  -- GL Account Determination
  material_gl_account VARCHAR(20) NOT NULL,
  
  -- GST GL Accounts (Dynamic based on input credit category)
  immediate_gst_account VARCHAR(20), -- For immediate credit
  restricted_gst_account VARCHAR(20), -- For capital goods
  blocked_gst_account VARCHAR(20), -- For blocked credit
  
  -- Phased Credit Accounts (for capital goods)
  phase_1_gst_account VARCHAR(20), -- Year 1: 20%
  phase_2_gst_account VARCHAR(20), -- Year 2: 20%
  phase_3_gst_account VARCHAR(20), -- Year 3: 20%
  phase_4_gst_account VARCHAR(20), -- Year 4: 20%
  phase_5_gst_account VARCHAR(20), -- Year 5: 20%
  
  -- Payable Account
  payable_account VARCHAR(20) NOT NULL,
  
  -- Rule Management
  rule_priority INTEGER DEFAULT 100,
  effective_date DATE DEFAULT CURRENT_DATE,
  end_date DATE,
  
  is_active BOOLEAN DEFAULT true
);

-- 3. GST TRANSACTION PROCESSING ENGINE
CREATE TABLE gst_transaction_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Transaction Reference
  transaction_id VARCHAR(50) NOT NULL,
  transaction_date DATE NOT NULL,
  company_code VARCHAR(10) NOT NULL,
  
  -- Material/Service Details
  hsn_sac_code VARCHAR(10) NOT NULL,
  commodity_description TEXT,
  taxable_value DECIMAL(15,2) NOT NULL,
  
  -- GST Calculation
  cgst_amount DECIMAL(15,2) DEFAULT 0,
  sgst_amount DECIMAL(15,2) DEFAULT 0,
  igst_amount DECIMAL(15,2) DEFAULT 0,
  cess_amount DECIMAL(15,2) DEFAULT 0,
  total_gst_amount DECIMAL(15,2) GENERATED ALWAYS AS (cgst_amount + sgst_amount + igst_amount + cess_amount) STORED,
  
  -- Input Credit Processing
  input_credit_category VARCHAR(20) NOT NULL,
  immediate_credit_amount DECIMAL(15,2) DEFAULT 0,
  restricted_credit_amount DECIMAL(15,2) DEFAULT 0,
  blocked_credit_amount DECIMAL(15,2) DEFAULT 0,
  
  -- Phased Credit Schedule (for capital goods)
  phase_1_credit DECIMAL(15,2) DEFAULT 0, -- Available immediately
  phase_2_credit DECIMAL(15,2) DEFAULT 0, -- Available after 12 months
  phase_3_credit DECIMAL(15,2) DEFAULT 0, -- Available after 24 months
  phase_4_credit DECIMAL(15,2) DEFAULT 0, -- Available after 36 months
  phase_5_credit DECIMAL(15,2) DEFAULT 0, -- Available after 48 months
  
  -- GL Posting Reference
  journal_entry_id VARCHAR(50),
  
  -- Compliance Tracking
  gstr_period VARCHAR(7), -- YYYY-MM format
  gstr_filed BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. REGULATORY CHANGE MANAGEMENT
CREATE TABLE regulatory_updates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Update Details
  update_type VARCHAR(30) NOT NULL, -- GST_RATE_CHANGE, HSN_MERGER, NEW_EXEMPTION, etc.
  notification_number VARCHAR(50) NOT NULL,
  notification_date DATE NOT NULL,
  effective_date DATE NOT NULL,
  
  -- Impact Assessment
  affected_hsn_codes TEXT[], -- Array of affected HSN codes
  impact_description TEXT NOT NULL,
  
  -- System Changes Required
  gl_mapping_update_required BOOLEAN DEFAULT false,
  rate_master_update_required BOOLEAN DEFAULT false,
  
  -- Implementation Status
  implementation_status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, IN_PROGRESS, COMPLETED
  implemented_by VARCHAR(50),
  implemented_date DATE,
  
  -- Compliance Notes
  compliance_notes TEXT,
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. ADVANCED GL DETERMINATION FUNCTION
CREATE OR REPLACE FUNCTION get_advanced_gl_determination(
  p_company_code VARCHAR(10),
  p_movement_type VARCHAR(10),
  p_hsn_sac_code VARCHAR(10),
  p_valuation_class VARCHAR(20),
  p_business_process VARCHAR(50),
  p_transaction_date DATE DEFAULT CURRENT_DATE,
  p_taxable_amount DECIMAL(15,2) DEFAULT 0
) RETURNS TABLE (
  -- Material GL
  material_account VARCHAR(20),
  material_amount DECIMAL(15,2),
  
  -- GST GL Accounts
  gst_account_1 VARCHAR(20),
  gst_amount_1 DECIMAL(15,2),
  gst_account_2 VARCHAR(20),
  gst_amount_2 DECIMAL(15,2),
  gst_account_3 VARCHAR(20),
  gst_amount_3 DECIMAL(15,2),
  
  -- Payable GL
  payable_account VARCHAR(20),
  payable_amount DECIMAL(15,2),
  
  -- GST Details
  total_gst_rate DECIMAL(5,2),
  input_credit_category VARCHAR(20),
  immediate_credit DECIMAL(15,2),
  restricted_credit DECIMAL(15,2),
  
  -- Compliance Info
  hsn_code VARCHAR(10),
  notification_ref VARCHAR(50)
) AS $$
DECLARE
  v_gst_rate RECORD;
  v_gl_mapping RECORD;
  v_gst_amount DECIMAL(15,2);
  v_immediate_credit DECIMAL(15,2);
  v_restricted_credit DECIMAL(15,2);
BEGIN
  -- Get current GST rate
  SELECT * INTO v_gst_rate
  FROM gst_rate_master
  WHERE hsn_sac_code = p_hsn_sac_code
    AND company_code = p_company_code
    AND effective_date <= p_transaction_date
    AND (end_date IS NULL OR end_date > p_transaction_date)
    AND is_active = true
  ORDER BY effective_date DESC
  LIMIT 1;
  
  -- Get GL mapping
  SELECT * INTO v_gl_mapping
  FROM dynamic_gl_mapping
  WHERE company_code = p_company_code
    AND movement_type = p_movement_type
    AND valuation_class = p_valuation_class
    AND business_process = p_business_process
    AND input_credit_category = v_gst_rate.input_credit_category
    AND effective_date <= p_transaction_date
    AND (end_date IS NULL OR end_date > p_transaction_date)
    AND is_active = true
  ORDER BY rule_priority
  LIMIT 1;
  
  -- Calculate GST amount
  v_gst_amount := p_taxable_amount * v_gst_rate.total_gst_rate / 100;
  
  -- Calculate input credit based on category
  CASE v_gst_rate.input_credit_category
    WHEN 'IMMEDIATE' THEN
      v_immediate_credit := v_gst_amount;
      v_restricted_credit := 0;
    WHEN 'RESTRICTED' THEN
      v_immediate_credit := v_gst_amount * 0.20; -- 20% in first year
      v_restricted_credit := v_gst_amount * 0.80; -- 80% over 4 years
    WHEN 'BLOCKED' THEN
      v_immediate_credit := 0;
      v_restricted_credit := 0;
    ELSE
      v_immediate_credit := v_gst_amount;
      v_restricted_credit := 0;
  END CASE;
  
  -- Return GL determination
  RETURN QUERY SELECT
    v_gl_mapping.material_gl_account,
    p_taxable_amount,
    
    -- GST accounts based on input credit category
    CASE 
      WHEN v_gst_rate.input_credit_category = 'IMMEDIATE' THEN v_gl_mapping.immediate_gst_account
      WHEN v_gst_rate.input_credit_category = 'RESTRICTED' THEN v_gl_mapping.phase_1_gst_account
      ELSE v_gl_mapping.blocked_gst_account
    END,
    v_immediate_credit,
    
    CASE 
      WHEN v_gst_rate.input_credit_category = 'RESTRICTED' THEN v_gl_mapping.restricted_gst_account
      ELSE NULL
    END,
    v_restricted_credit,
    
    NULL::VARCHAR(20), -- Third GST account (for future use)
    0::DECIMAL(15,2),   -- Third GST amount
    
    v_gl_mapping.payable_account,
    p_taxable_amount + v_gst_amount,
    
    v_gst_rate.total_gst_rate,
    v_gst_rate.input_credit_category,
    v_immediate_credit,
    v_restricted_credit,
    
    v_gst_rate.hsn_sac_code,
    v_gst_rate.notification_number;
END;
$$ LANGUAGE plpgsql;

-- 6. REGULATORY UPDATE AUTOMATION
CREATE OR REPLACE FUNCTION process_gst_rate_change(
  p_notification_number VARCHAR(50),
  p_hsn_code VARCHAR(10),
  p_new_rate DECIMAL(5,2),
  p_effective_date DATE,
  p_company_code VARCHAR(10)
) RETURNS TEXT AS $$
DECLARE
  v_result TEXT;
BEGIN
  -- End current rate
  UPDATE gst_rate_master 
  SET end_date = p_effective_date - INTERVAL '1 day',
      is_active = false
  WHERE hsn_sac_code = p_hsn_code
    AND company_code = p_company_code
    AND end_date IS NULL;
  
  -- Insert new rate
  INSERT INTO gst_rate_master (
    hsn_sac_code, commodity_description,
    igst_rate, notification_number, effective_date,
    company_code
  )
  SELECT 
    p_hsn_code,
    commodity_description,
    p_new_rate,
    p_notification_number,
    p_effective_date,
    p_company_code
  FROM gst_rate_master
  WHERE hsn_sac_code = p_hsn_code
    AND company_code = p_company_code
  ORDER BY effective_date DESC
  LIMIT 1;
  
  v_result := 'GST rate updated for HSN ' || p_hsn_code || ' to ' || p_new_rate || '%';
  
  -- Log regulatory update
  INSERT INTO regulatory_updates (
    update_type, notification_number, notification_date, effective_date,
    affected_hsn_codes, impact_description,
    implementation_status, implemented_date
  ) VALUES (
    'GST_RATE_CHANGE', p_notification_number, CURRENT_DATE, p_effective_date,
    ARRAY[p_hsn_code], v_result,
    'COMPLETED', CURRENT_DATE
  );
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- 7. SAMPLE DATA SETUP
INSERT INTO gst_rate_master (
  hsn_sac_code, commodity_description,
  cgst_rate, sgst_rate, igst_rate,
  input_credit_category, capital_goods_flag,
  notification_number, effective_date, company_code
) VALUES
-- Steel - Regular goods
('7214', 'Iron or steel bars and rods', 9.0, 9.0, 18.0, 'IMMEDIATE', false, 'GST-2017-001', '2017-07-01', 'C001'),
-- Construction Equipment - Capital goods
('8426', 'Ships derricks; cranes', 9.0, 9.0, 18.0, 'RESTRICTED', true, 'GST-2017-002', '2017-07-01', 'C001'),
-- Cement - Regular goods
('2523', 'Portland cement', 14.0, 14.0, 28.0, 'IMMEDIATE', false, 'GST-2017-003', '2017-07-01', 'C001');

INSERT INTO dynamic_gl_mapping (
  company_code, movement_type, valuation_class, business_process,
  gst_nature, input_credit_category,
  material_gl_account, immediate_gst_account, restricted_gst_account,
  phase_1_gst_account, payable_account
) VALUES
-- Immediate credit scenario
('C001', 'C101', 'RAW_MATERIAL', 'PROCURE_TO_PAY', 'GOODS', 'IMMEDIATE',
 '130200', '170100', NULL, NULL, '210100'),
-- Restricted credit scenario  
('C001', 'C121', 'CAPITAL_GOODS', 'ASSET_CONSTRUCTION', 'CAPITAL_GOODS', 'RESTRICTED',
 '151000', NULL, '170200', '170201', '210100');

-- Example Usage:
-- SELECT * FROM get_advanced_gl_determination('C001', 'C101', '7214', 'RAW_MATERIAL', 'PROCURE_TO_PAY', CURRENT_DATE, 800000);
-- SELECT process_gst_rate_change('GST-2024-001', '7214', 12.0, '2024-04-01', 'C001');