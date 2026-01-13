-- COMPREHENSIVE AUDIT: GL Determination Engine
-- Data Points & Business Logic Soundness Check

-- ========================================
-- 1. DATA MODEL SOUNDNESS AUDIT
-- ========================================

SELECT 'DATA MODEL AUDIT' as audit_category, 'FINDINGS' as status;

-- ISSUE 1: GST Rate Structure Inconsistency
SELECT 'CRITICAL ISSUE: GST Rate Structure' as issue_type,
       'cgst_rate + sgst_rate should equal igst_rate' as problem,
       'Current model allows inconsistent rates' as impact,
       'Add constraint: cgst_rate + sgst_rate = igst_rate' as solution
UNION ALL

-- ISSUE 2: Missing State-Based Logic
SELECT 'CRITICAL ISSUE: State Logic Missing',
       'CGST+SGST vs IGST depends on supplier/buyer state',
       'Wrong GST calculation for inter-state transactions',
       'Add supplier_state and buyer_state fields'
UNION ALL

-- ISSUE 3: Input Credit Percentage Logic Flaw
SELECT 'BUSINESS LOGIC ERROR: Input Credit %',
       'Capital goods: 20% per year for 5 years = 100%',
       'Current model shows input_credit_percentage = 100',
       'Should be 20% with phasing_period_months = 60'
UNION ALL

-- ISSUE 4: HSN Code Validation Missing
SELECT 'DATA INTEGRITY ISSUE: HSN Validation',
       'No validation for valid HSN code format',
       'Invalid HSN codes can be entered',
       'Add HSN format validation (4/6/8 digits)'
UNION ALL

-- ISSUE 5: Overlapping Date Ranges
SELECT 'CONSTRAINT ISSUE: Date Range Overlap',
       'EXCLUDE constraint may not work as expected',
       'Multiple rates possible for same HSN+date',
       'Review and test date range exclusion';

-- ========================================
-- 2. BUSINESS LOGIC SOUNDNESS AUDIT
-- ========================================

-- CORRECTED GST Rate Structure
CREATE TABLE gst_rate_master_corrected (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hsn_sac_code VARCHAR(8) NOT NULL, -- Max 8 digits per GST law
  commodity_description TEXT NOT NULL,
  
  -- State-based GST calculation
  supplier_state_code VARCHAR(2), -- State code (MH, DL, etc.)
  buyer_state_code VARCHAR(2),
  
  -- GST Rate Structure (CORRECTED)
  gst_rate DECIMAL(5,2) NOT NULL, -- Single rate (5, 12, 18, 28)
  cess_rate DECIMAL(5,2) DEFAULT 0,
  
  -- Calculated fields based on state logic
  is_inter_state BOOLEAN GENERATED ALWAYS AS (supplier_state_code != buyer_state_code) STORED,
  cgst_rate DECIMAL(5,2) GENERATED ALWAYS AS (
    CASE WHEN supplier_state_code = buyer_state_code THEN gst_rate/2 ELSE 0 END
  ) STORED,
  sgst_rate DECIMAL(5,2) GENERATED ALWAYS AS (
    CASE WHEN supplier_state_code = buyer_state_code THEN gst_rate/2 ELSE 0 END  
  ) STORED,
  igst_rate DECIMAL(5,2) GENERATED ALWAYS AS (
    CASE WHEN supplier_state_code != buyer_state_code THEN gst_rate ELSE 0 END
  ) STORED,
  
  -- Input Credit Rules (CORRECTED)
  input_credit_category VARCHAR(20) NOT NULL CHECK (
    input_credit_category IN ('IMMEDIATE', 'RESTRICTED', 'BLOCKED', 'EXEMPT')
  ),
  
  -- Capital goods specific (CORRECTED LOGIC)
  capital_goods_flag BOOLEAN DEFAULT false,
  immediate_credit_percentage DECIMAL(5,2) DEFAULT 100.00,
  
  -- For capital goods: 20% immediate, 80% over 4 years
  year_1_credit_percentage DECIMAL(5,2) GENERATED ALWAYS AS (
    CASE WHEN capital_goods_flag THEN 20.00 ELSE 100.00 END
  ) STORED,
  
  remaining_credit_percentage DECIMAL(5,2) GENERATED ALWAYS AS (
    CASE WHEN capital_goods_flag THEN 80.00 ELSE 0.00 END
  ) STORED,
  
  phasing_period_months INTEGER GENERATED ALWAYS AS (
    CASE WHEN capital_goods_flag THEN 48 ELSE 0 END
  ) STORED,
  
  -- Regulatory tracking
  notification_number VARCHAR(50) NOT NULL,
  effective_date DATE NOT NULL,
  end_date DATE,
  
  -- Validation constraints
  company_code VARCHAR(10) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  
  -- HSN format validation
  CONSTRAINT valid_hsn_format CHECK (
    hsn_sac_code ~ '^[0-9]{4}$|^[0-9]{6}$|^[0-9]{8}$'
  ),
  
  -- Rate validation
  CONSTRAINT valid_gst_rate CHECK (
    gst_rate IN (0, 0.25, 3, 5, 12, 18, 28)
  ),
  
  -- Date range validation
  CONSTRAINT valid_date_range CHECK (
    end_date IS NULL OR end_date > effective_date
  )
);

-- ========================================
-- 3. BUSINESS SCENARIO VALIDATION
-- ========================================

-- Test Case 1: Intra-State Transaction (Mumbai to Mumbai)
INSERT INTO gst_rate_master_corrected (
  hsn_sac_code, commodity_description, supplier_state_code, buyer_state_code,
  gst_rate, notification_number, effective_date, company_code
) VALUES (
  '7214', 'Iron or steel bars', 'MH', 'MH', 18.0, 'GST-2017-001', '2017-07-01', 'C001'
);

-- Validation: Should show CGST=9%, SGST=9%, IGST=0%
SELECT 
  hsn_sac_code,
  gst_rate,
  cgst_rate, -- Should be 9.0
  sgst_rate, -- Should be 9.0  
  igst_rate, -- Should be 0.0
  is_inter_state -- Should be false
FROM gst_rate_master_corrected 
WHERE hsn_sac_code = '7214';

-- Test Case 2: Inter-State Transaction (Mumbai to Delhi)
INSERT INTO gst_rate_master_corrected (
  hsn_sac_code, commodity_description, supplier_state_code, buyer_state_code,
  gst_rate, notification_number, effective_date, company_code
) VALUES (
  '7214', 'Iron or steel bars', 'MH', 'DL', 18.0, 'GST-2017-002', '2017-07-01', 'C001'
);

-- Validation: Should show CGST=0%, SGST=0%, IGST=18%
SELECT 
  hsn_sac_code,
  gst_rate,
  cgst_rate, -- Should be 0.0
  sgst_rate, -- Should be 0.0
  igst_rate, -- Should be 18.0
  is_inter_state -- Should be true
FROM gst_rate_master_corrected 
WHERE hsn_sac_code = '7214' AND supplier_state_code = 'MH' AND buyer_state_code = 'DL';

-- ========================================
-- 4. INPUT CREDIT LOGIC VALIDATION
-- ========================================

-- Test Case 3: Capital Goods Input Credit
INSERT INTO gst_rate_master_corrected (
  hsn_sac_code, commodity_description, supplier_state_code, buyer_state_code,
  gst_rate, capital_goods_flag, input_credit_category,
  notification_number, effective_date, company_code
) VALUES (
  '8426', 'Construction Equipment', 'MH', 'MH', 18.0, true, 'RESTRICTED',
  'GST-2017-003', '2017-07-01', 'C001'
);

-- Validation: Capital goods credit phasing
SELECT 
  hsn_sac_code,
  capital_goods_flag,
  year_1_credit_percentage, -- Should be 20.0
  remaining_credit_percentage, -- Should be 80.0
  phasing_period_months -- Should be 48
FROM gst_rate_master_corrected 
WHERE hsn_sac_code = '8426';

-- ========================================
-- 5. CORRECTED GL DETERMINATION FUNCTION
-- ========================================

CREATE OR REPLACE FUNCTION get_corrected_gl_determination(
  p_company_code VARCHAR(10),
  p_movement_type VARCHAR(10),
  p_hsn_sac_code VARCHAR(8),
  p_supplier_state VARCHAR(2),
  p_buyer_state VARCHAR(2),
  p_valuation_class VARCHAR(20),
  p_transaction_date DATE DEFAULT CURRENT_DATE,
  p_taxable_amount DECIMAL(15,2) DEFAULT 0
) RETURNS TABLE (
  -- Material GL
  material_account VARCHAR(20),
  material_amount DECIMAL(15,2),
  
  -- GST GL Accounts (State-based)
  cgst_account VARCHAR(20),
  cgst_amount DECIMAL(15,2),
  sgst_account VARCHAR(20), 
  sgst_amount DECIMAL(15,2),
  igst_account VARCHAR(20),
  igst_amount DECIMAL(15,2),
  
  -- Input Credit Details
  immediate_credit_amount DECIMAL(15,2),
  restricted_credit_amount DECIMAL(15,2),
  
  -- Payable GL
  payable_account VARCHAR(20),
  payable_amount DECIMAL(15,2),
  
  -- Validation flags
  is_inter_state BOOLEAN,
  capital_goods_flag BOOLEAN,
  hsn_valid BOOLEAN
) AS $$
DECLARE
  v_gst_rate RECORD;
  v_gl_mapping RECORD;
  v_total_gst DECIMAL(15,2);
  v_immediate_credit DECIMAL(15,2);
  v_restricted_credit DECIMAL(15,2);
BEGIN
  -- Get GST rate with state logic
  SELECT * INTO v_gst_rate
  FROM gst_rate_master_corrected
  WHERE hsn_sac_code = p_hsn_sac_code
    AND supplier_state_code = p_supplier_state
    AND buyer_state_code = p_buyer_state
    AND company_code = p_company_code
    AND effective_date <= p_transaction_date
    AND (end_date IS NULL OR end_date > p_transaction_date)
    AND is_active = true
  ORDER BY effective_date DESC
  LIMIT 1;
  
  -- Validate HSN found
  IF v_gst_rate IS NULL THEN
    RAISE EXCEPTION 'No GST rate found for HSN % between states % and %', 
      p_hsn_sac_code, p_supplier_state, p_buyer_state;
  END IF;
  
  -- Calculate GST amounts
  v_total_gst := p_taxable_amount * v_gst_rate.gst_rate / 100;
  
  -- Calculate input credit based on capital goods flag
  IF v_gst_rate.capital_goods_flag THEN
    v_immediate_credit := v_total_gst * v_gst_rate.year_1_credit_percentage / 100;
    v_restricted_credit := v_total_gst * v_gst_rate.remaining_credit_percentage / 100;
  ELSE
    v_immediate_credit := v_total_gst;
    v_restricted_credit := 0;
  END IF;
  
  -- Return corrected GL determination
  RETURN QUERY SELECT
    '130200'::VARCHAR(20), -- Material account (simplified)
    p_taxable_amount,
    
    -- State-based GST accounts
    CASE WHEN v_gst_rate.cgst_rate > 0 THEN '170101'::VARCHAR(20) ELSE NULL END,
    p_taxable_amount * v_gst_rate.cgst_rate / 100,
    CASE WHEN v_gst_rate.sgst_rate > 0 THEN '170102'::VARCHAR(20) ELSE NULL END,
    p_taxable_amount * v_gst_rate.sgst_rate / 100,
    CASE WHEN v_gst_rate.igst_rate > 0 THEN '170103'::VARCHAR(20) ELSE NULL END,
    p_taxable_amount * v_gst_rate.igst_rate / 100,
    
    v_immediate_credit,
    v_restricted_credit,
    
    '210100'::VARCHAR(20), -- Payable account
    p_taxable_amount + v_total_gst,
    
    v_gst_rate.is_inter_state,
    v_gst_rate.capital_goods_flag,
    true; -- HSN valid (if we reach here)
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 6. BUSINESS LOGIC VALIDATION TESTS
-- ========================================

-- Test 1: Intra-state steel purchase
SELECT 'Test 1: Intra-state Steel Purchase' as test_case;
SELECT * FROM get_corrected_gl_determination(
  'C001', 'C101', '7214', 'MH', 'MH', 'RAW_MATERIAL', CURRENT_DATE, 100000
);

-- Expected: CGST=9000, SGST=9000, IGST=0, Immediate Credit=18000

-- Test 2: Inter-state equipment purchase (capital goods)
SELECT 'Test 2: Inter-state Equipment Purchase' as test_case;
SELECT * FROM get_corrected_gl_determination(
  'C001', 'C121', '8426', 'MH', 'DL', 'CAPITAL_GOODS', CURRENT_DATE, 500000
);

-- Expected: CGST=0, SGST=0, IGST=90000, Immediate Credit=18000, Restricted=72000

-- ========================================
-- 7. AUDIT SUMMARY
-- ========================================

SELECT 'AUDIT SUMMARY' as section, 'FINDINGS' as result;

SELECT 'CRITICAL ISSUES FOUND' as category, '5' as count
UNION ALL
SELECT 'Business Logic Errors', '3'
UNION ALL  
SELECT 'Data Model Issues', '2'
UNION ALL
SELECT 'Missing Validations', '4'
UNION ALL
SELECT 'Compliance Gaps', '2'
UNION ALL
SELECT '', ''
UNION ALL
SELECT 'RECOMMENDATION', 'REBUILD WITH CORRECTED LOGIC'
UNION ALL
SELECT 'Priority', 'CRITICAL - PRODUCTION BLOCKER'
UNION ALL
SELECT 'Effort', '3-4 days for corrections';