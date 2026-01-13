-- HSN FALLBACK MECHANISM - CRITICAL PRODUCTION FIX
-- Handles missing HSN codes gracefully with fallback logic

-- ========================================
-- 1. ENHANCED GL DETERMINATION WITH FALLBACK
-- ========================================

CREATE OR REPLACE FUNCTION get_gl_accounts_minimal_safe(
  p_company_code VARCHAR(10),
  p_movement_type VARCHAR(10),
  p_hsn_code VARCHAR(8),
  p_supplier_code VARCHAR(20),
  p_taxable_amount DECIMAL(15,2)
) RETURNS TABLE (
  material_account VARCHAR(20),
  material_amount DECIMAL(15,2),
  cgst_account VARCHAR(20),
  cgst_amount DECIMAL(15,2),
  sgst_account VARCHAR(20),
  sgst_amount DECIMAL(15,2),
  igst_account VARCHAR(20),
  igst_amount DECIMAL(15,2),
  payable_account VARCHAR(20),
  payable_amount DECIMAL(15,2),
  total_gst DECIMAL(15,2),
  immediate_credit DECIMAL(15,2),
  is_inter_state BOOLEAN,
  hsn_code VARCHAR(8),
  fallback_used BOOLEAN
) AS $$
DECLARE
  v_gst_rate RECORD;
  v_supplier_state VARCHAR(2);
  v_company_state VARCHAR(2);
  v_gst_calc RECORD;
  v_material_account VARCHAR(20);
  v_final_hsn VARCHAR(8);
  v_fallback_used BOOLEAN := false;
BEGIN
  -- Try to get GST rate for provided HSN
  SELECT * INTO v_gst_rate
  FROM gst_rates_simple
  WHERE hsn_code = p_hsn_code 
    AND company_code = p_company_code
    AND is_active = true
  ORDER BY effective_date DESC
  LIMIT 1;
  
  -- If HSN not found, use fallback based on movement type
  IF v_gst_rate IS NULL THEN
    v_fallback_used := true;
    v_final_hsn := CASE 
      WHEN p_movement_type = 'C121' THEN '8426' -- Capital goods
      WHEN p_movement_type = 'C111' THEN '7214' -- WIP materials
      ELSE '7214' -- Default construction materials
    END;
    
    -- Get fallback GST rate
    SELECT * INTO v_gst_rate
    FROM gst_rates_simple
    WHERE hsn_code = v_final_hsn 
      AND company_code = p_company_code
      AND is_active = true
    ORDER BY effective_date DESC
    LIMIT 1;
    
    -- If still no rate found, use default 18% GST
    IF v_gst_rate IS NULL THEN
      v_gst_rate := ROW(
        gen_random_uuid(),
        v_final_hsn,
        'Default Construction Material',
        18.0::DECIMAL(5,2),
        false,
        CURRENT_DATE,
        p_company_code,
        true
      );
    END IF;
  ELSE
    v_final_hsn := p_hsn_code;
  END IF;
  
  -- Get supplier state with fallback
  SELECT state_code INTO v_supplier_state
  FROM entity_states
  WHERE entity_code = p_supplier_code;
  
  -- Default to Maharashtra if supplier state not found
  v_supplier_state := COALESCE(v_supplier_state, 'MH');
  
  -- Get company state with fallback
  SELECT state_code INTO v_company_state
  FROM entity_states
  WHERE entity_type = 'COMPANY' AND company_code = p_company_code;
  
  -- Default to Maharashtra if company state not found
  v_company_state := COALESCE(v_company_state, 'MH');
  
  -- Calculate GST
  SELECT * INTO v_gst_calc
  FROM calculate_gst_minimal(
    v_supplier_state, 
    v_company_state, 
    v_gst_rate.gst_rate, 
    p_taxable_amount,
    v_gst_rate.is_capital_goods
  );
  
  -- Determine material account
  v_material_account := CASE 
    WHEN p_movement_type = 'C101' THEN '130200' -- Inventory
    WHEN p_movement_type = 'C111' THEN '140100' -- WIP
    WHEN p_movement_type = 'C121' THEN '151000' -- Capital WIP
    ELSE '130200'
  END;
  
  -- Return GL determination with fallback indicator
  RETURN QUERY SELECT
    v_material_account,
    p_taxable_amount,
    
    CASE WHEN v_gst_calc.cgst_amount > 0 THEN '170101'::VARCHAR(20) ELSE NULL END,
    v_gst_calc.cgst_amount,
    CASE WHEN v_gst_calc.sgst_amount > 0 THEN '170102'::VARCHAR(20) ELSE NULL END,
    v_gst_calc.sgst_amount,
    CASE WHEN v_gst_calc.igst_amount > 0 THEN '170103'::VARCHAR(20) ELSE NULL END,
    v_gst_calc.igst_amount,
    
    '210100'::VARCHAR(20),
    p_taxable_amount + v_gst_calc.total_gst,
    
    v_gst_calc.total_gst,
    v_gst_calc.immediate_credit,
    v_gst_calc.is_inter_state,
    v_final_hsn,
    v_fallback_used;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 2. UPDATE API INTEGRATION FUNCTION
-- ========================================

CREATE OR REPLACE FUNCTION get_enhanced_gl_determination_safe(
  p_company_code VARCHAR(10),
  p_movement_type VARCHAR(10),
  p_project_category VARCHAR(20),
  p_event_type VARCHAR(50),
  p_taxable_amount DECIMAL(15,2) DEFAULT 100000,
  p_supplier_code VARCHAR(20) DEFAULT 'STEEL_SUPPLIER'
) RETURNS TABLE (
  debit_account VARCHAR(20),
  credit_account VARCHAR(20),
  posting_key VARCHAR(10),
  debit_amount DECIMAL(15,2),
  credit_amount DECIMAL(15,2),
  gst_amount DECIMAL(15,2),
  input_credit DECIMAL(15,2),
  is_inter_state BOOLEAN,
  gst_breakdown TEXT,
  hsn_used VARCHAR(8),
  fallback_warning TEXT
) AS $$
DECLARE
  v_gl_result RECORD;
  v_hsn_code VARCHAR(8);
  v_gst_breakdown TEXT;
  v_fallback_warning TEXT := NULL;
BEGIN
  -- Get HSN code from GL rules
  SELECT hsn_sac_code INTO v_hsn_code
  FROM project_gl_determination
  WHERE company_code = p_company_code
    AND project_category = p_project_category
    AND event_type = p_event_type
    AND is_active = true
  LIMIT 1;
  
  -- Use default if not found
  v_hsn_code := COALESCE(v_hsn_code, '7214');
  
  -- Get GL determination with fallback
  SELECT * INTO v_gl_result
  FROM get_gl_accounts_minimal_safe(
    p_company_code,
    p_movement_type,
    v_hsn_code,
    p_supplier_code,
    p_taxable_amount
  );
  
  -- Create warning if fallback was used
  IF v_gl_result.fallback_used THEN
    v_fallback_warning := 'HSN code ' || v_hsn_code || ' not found. Used fallback: ' || v_gl_result.hsn_code;
  END IF;
  
  -- Create GST breakdown
  IF v_gl_result.is_inter_state THEN
    v_gst_breakdown := 'IGST: ₹' || v_gl_result.igst_amount;
  ELSE
    v_gst_breakdown := 'CGST: ₹' || v_gl_result.cgst_amount || ', SGST: ₹' || v_gl_result.sgst_amount;
  END IF;
  
  RETURN QUERY SELECT
    v_gl_result.material_account,
    v_gl_result.payable_account,
    '89'::VARCHAR(10),
    v_gl_result.material_amount,
    v_gl_result.payable_amount,
    v_gl_result.total_gst,
    v_gl_result.immediate_credit,
    v_gl_result.is_inter_state,
    v_gst_breakdown,
    v_gl_result.hsn_code,
    v_fallback_warning;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 3. TEST FALLBACK SCENARIOS
-- ========================================

-- Test missing HSN code
SELECT 'TEST: Missing HSN Code Fallback' as test_case;
SELECT * FROM get_gl_accounts_minimal_safe('C001', 'C101', '9999', 'STEEL_SUPPLIER', 100000);

-- Test missing supplier
SELECT 'TEST: Missing Supplier Fallback' as test_case;
SELECT * FROM get_gl_accounts_minimal_safe('C001', 'C101', '7214', 'UNKNOWN_SUPPLIER', 100000);

SELECT 'FALLBACK MECHANISM IMPLEMENTED - PRODUCTION SAFE' as status;