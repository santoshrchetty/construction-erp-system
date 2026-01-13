-- MULTI-COUNTRY TAX COMPLIANCE SYSTEM
-- Handles different tax regimes: GST (India), VAT (UAE/Saudi/EU), Sales Tax (USA)

-- ========================================
-- 1. COUNTRY TAX CONFIGURATION
-- ========================================

CREATE TABLE country_tax_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  country_code VARCHAR(3) NOT NULL, -- ISO 3166-1 alpha-3
  country_name VARCHAR(100) NOT NULL,
  tax_system VARCHAR(20) NOT NULL, -- GST, VAT, SALES_TAX, NONE
  requires_tax_code BOOLEAN DEFAULT false, -- HSN for India, HS for others
  tax_code_name VARCHAR(20), -- 'HSN', 'HS_CODE', 'COMMODITY_CODE'
  default_tax_rate DECIMAL(5,2) DEFAULT 0,
  inter_state_logic BOOLEAN DEFAULT false, -- Only for GST
  is_active BOOLEAN DEFAULT true
);

-- ========================================
-- 2. POPULATE COUNTRY CONFIGURATIONS
-- ========================================

INSERT INTO country_tax_config (country_code, country_name, tax_system, requires_tax_code, tax_code_name, default_tax_rate, inter_state_logic) VALUES
-- India - Complex GST system
('IND', 'India', 'GST', true, 'HSN', 18.0, true),

-- UAE - Simple VAT
('ARE', 'United Arab Emirates', 'VAT', false, null, 5.0, false),

-- Saudi Arabia - Simple VAT  
('SAU', 'Saudi Arabia', 'VAT', false, null, 15.0, false),

-- USA - State-based sales tax
('USA', 'United States', 'SALES_TAX', false, null, 0.0, true), -- Varies by state

-- EU Countries - VAT system
('DEU', 'Germany', 'VAT', false, null, 19.0, false),
('FRA', 'France', 'VAT', false, null, 20.0, false),
('GBR', 'United Kingdom', 'VAT', false, null, 20.0, false),

-- GCC Countries
('QAT', 'Qatar', 'VAT', false, null, 5.0, false),
('KWT', 'Kuwait', 'VAT', false, null, 5.0, false),
('BHR', 'Bahrain', 'VAT', false, null, 10.0, false),

-- No tax countries
('OMN', 'Oman', 'NONE', false, null, 0.0, false);

-- ========================================
-- 3. COMPANY COUNTRY MAPPING
-- ========================================

ALTER TABLE companies 
ADD COLUMN IF NOT EXISTS country_code VARCHAR(3) DEFAULT 'IND',
ADD COLUMN IF NOT EXISTS tax_registration_number VARCHAR(50),
ADD COLUMN IF NOT EXISTS currency_code VARCHAR(3) DEFAULT 'INR';

-- Update existing companies
UPDATE companies SET 
  country_code = 'IND',
  currency_code = 'INR'
WHERE country_code IS NULL;

-- ========================================
-- 4. UNIVERSAL TAX CALCULATION FUNCTION
-- ========================================

CREATE OR REPLACE FUNCTION calculate_tax_universal(
  p_company_country VARCHAR(3),
  p_supplier_country VARCHAR(3),
  p_company_state VARCHAR(10) DEFAULT NULL,
  p_supplier_state VARCHAR(10) DEFAULT NULL,
  p_tax_code VARCHAR(20) DEFAULT NULL,
  p_taxable_amount DECIMAL(15,2),
  p_is_capital_goods BOOLEAN DEFAULT false
) RETURNS TABLE (
  tax_type VARCHAR(20),
  tax_rate DECIMAL(5,2),
  tax_amount DECIMAL(15,2),
  tax_breakdown JSON,
  requires_tax_code BOOLEAN,
  compliance_notes TEXT
) AS $$
DECLARE
  v_tax_config RECORD;
  v_tax_amount DECIMAL(15,2);
  v_tax_breakdown JSON;
  v_compliance_notes TEXT;
BEGIN
  -- Get tax configuration for company country
  SELECT * INTO v_tax_config
  FROM country_tax_config
  WHERE country_code = p_company_country AND is_active = true;
  
  IF v_tax_config IS NULL THEN
    RETURN QUERY SELECT
      'NONE'::VARCHAR(20),
      0::DECIMAL(5,2),
      0::DECIMAL(15,2),
      '{}'::JSON,
      false,
      'No tax configuration found for country'::TEXT;
    RETURN;
  END IF;
  
  CASE v_tax_config.tax_system
    WHEN 'GST' THEN
      -- India GST logic (existing)
      IF p_company_state IS NULL OR p_supplier_state IS NULL THEN
        v_compliance_notes := 'GST requires state information';
        v_tax_amount := 0;
        v_tax_breakdown := '{"error": "Missing state information"}';
      ELSE
        -- Use existing GST calculation
        SELECT total_gst, 
               json_build_object(
                 'cgst', cgst_amount,
                 'sgst', sgst_amount, 
                 'igst', igst_amount,
                 'is_inter_state', is_inter_state
               )
        INTO v_tax_amount, v_tax_breakdown
        FROM calculate_gst_minimal(p_supplier_state, p_company_state, 
                                 v_tax_config.default_tax_rate, p_taxable_amount, p_is_capital_goods);
        
        v_compliance_notes := 'GST calculated based on state mapping';
      END IF;
      
    WHEN 'VAT' THEN
      -- Simple VAT calculation
      v_tax_amount := p_taxable_amount * v_tax_config.default_tax_rate / 100;
      v_tax_breakdown := json_build_object(
        'vat_rate', v_tax_config.default_tax_rate,
        'vat_amount', v_tax_amount,
        'is_domestic', (p_company_country = p_supplier_country)
      );
      
      IF p_company_country != p_supplier_country THEN
        v_compliance_notes := 'Cross-border VAT - verify reverse charge applicability';
      ELSE
        v_compliance_notes := 'Domestic VAT applied';
      END IF;
      
    WHEN 'SALES_TAX' THEN
      -- US Sales Tax (state-dependent)
      IF p_company_state = p_supplier_state THEN
        -- Same state - apply sales tax (simplified)
        v_tax_amount := p_taxable_amount * 8.5 / 100; -- Average US sales tax
        v_tax_breakdown := json_build_object(
          'sales_tax_rate', 8.5,
          'sales_tax_amount', v_tax_amount,
          'state', p_company_state
        );
        v_compliance_notes := 'Sales tax applied for same-state transaction';
      ELSE
        -- Different state - no sales tax (simplified)
        v_tax_amount := 0;
        v_tax_breakdown := json_build_object('interstate', true, 'sales_tax_amount', 0);
        v_compliance_notes := 'Interstate transaction - no sales tax';
      END IF;
      
    WHEN 'NONE' THEN
      v_tax_amount := 0;
      v_tax_breakdown := json_build_object('tax_exempt', true);
      v_compliance_notes := 'Tax-free jurisdiction';
      
    ELSE
      v_tax_amount := 0;
      v_tax_breakdown := json_build_object('error', 'Unknown tax system');
      v_compliance_notes := 'Unknown tax system: ' || v_tax_config.tax_system;
  END CASE;
  
  RETURN QUERY SELECT
    v_tax_config.tax_system,
    v_tax_config.default_tax_rate,
    v_tax_amount,
    v_tax_breakdown,
    v_tax_config.requires_tax_code,
    v_compliance_notes;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 5. UNIVERSAL GL DETERMINATION
-- ========================================

CREATE OR REPLACE FUNCTION get_gl_universal(
  p_company_code VARCHAR(10),
  p_movement_type VARCHAR(10),
  p_material_code VARCHAR(20),
  p_supplier_code VARCHAR(20),
  p_taxable_amount DECIMAL(15,2)
) RETURNS TABLE (
  material_account VARCHAR(20),
  material_amount DECIMAL(15,2),
  tax_account VARCHAR(20),
  tax_amount DECIMAL(15,2),
  payable_account VARCHAR(20),
  payable_amount DECIMAL(15,2),
  tax_breakdown JSON,
  country_code VARCHAR(3),
  tax_system VARCHAR(20),
  compliance_notes TEXT
) AS $$
DECLARE
  v_company RECORD;
  v_supplier RECORD;
  v_tax_calc RECORD;
  v_material_account VARCHAR(20);
  v_tax_account VARCHAR(20);
BEGIN
  -- Get company details
  SELECT c.*, cc.country_code, cc.state_code as company_state
  INTO v_company
  FROM companies c
  LEFT JOIN company_codes cc ON c.company_id = cc.company_id
  WHERE cc.company_code = p_company_code;
  
  -- Get supplier details  
  SELECT *, state_code as supplier_state
  INTO v_supplier
  FROM entity_states
  WHERE entity_code = p_supplier_code;
  
  -- Calculate tax
  SELECT * INTO v_tax_calc
  FROM calculate_tax_universal(
    v_company.country_code,
    COALESCE(v_supplier.country_code, v_company.country_code),
    v_company.company_state,
    v_supplier.supplier_state,
    NULL, -- tax_code handled separately
    p_taxable_amount,
    false
  );
  
  -- Determine GL accounts
  v_material_account := CASE 
    WHEN p_movement_type = 'C101' THEN '130200'
    WHEN p_movement_type = 'C111' THEN '140100'
    WHEN p_movement_type = 'C121' THEN '151000'
    ELSE '130200'
  END;
  
  v_tax_account := CASE v_tax_calc.tax_type
    WHEN 'GST' THEN '170100' -- GST Input
    WHEN 'VAT' THEN '170200' -- VAT Input  
    WHEN 'SALES_TAX' THEN '170300' -- Sales Tax
    ELSE NULL
  END;
  
  RETURN QUERY SELECT
    v_material_account,
    p_taxable_amount,
    v_tax_account,
    v_tax_calc.tax_amount,
    '210100'::VARCHAR(20), -- Trade Payables
    p_taxable_amount + v_tax_calc.tax_amount,
    v_tax_calc.tax_breakdown,
    v_company.country_code,
    v_tax_calc.tax_type,
    v_tax_calc.compliance_notes;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 6. TEST MULTI-COUNTRY SCENARIOS
-- ========================================

-- Test India GST
SELECT 'TEST: India GST' as test_case;
SELECT * FROM calculate_tax_universal('IND', 'IND', 'MH', 'DL', '7214', 100000, false);

-- Test UAE VAT
SELECT 'TEST: UAE VAT' as test_case;  
SELECT * FROM calculate_tax_universal('ARE', 'ARE', NULL, NULL, NULL, 100000, false);

-- Test Saudi VAT
SELECT 'TEST: Saudi VAT' as test_case;
SELECT * FROM calculate_tax_universal('SAU', 'SAU', NULL, NULL, NULL, 100000, false);

-- Test Cross-border (UAE to India)
SELECT 'TEST: Cross-border UAE to India' as test_case;
SELECT * FROM calculate_tax_universal('IND', 'ARE', 'MH', NULL, NULL, 100000, false);

SELECT 'MULTI-COUNTRY TAX SYSTEM IMPLEMENTED' as status;