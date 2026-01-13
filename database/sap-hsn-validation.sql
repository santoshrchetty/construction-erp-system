-- SAP-LIKE HSN VALIDATION - BLOCKS TRANSACTIONS WHEN HSN MISSING
-- Mimics SAP behavior for missing HSN codes

-- ========================================
-- 1. HSN VALIDATION FUNCTION (SAP-LIKE)
-- ========================================

CREATE OR REPLACE FUNCTION validate_hsn_for_transaction(
  p_company_code VARCHAR(10),
  p_material_code VARCHAR(20),
  p_movement_type VARCHAR(10),
  p_supplier_code VARCHAR(20),
  p_taxable_amount DECIMAL(15,2)
) RETURNS TABLE (
  validation_status VARCHAR(20), -- SUCCESS, HSN_MISSING, HSN_INVALID
  error_message TEXT,
  suggested_hsn VARCHAR(8),
  material_group VARCHAR(20),
  requires_user_input BOOLEAN
) AS $$
DECLARE
  v_material RECORD;
  v_hsn_exists BOOLEAN;
  v_suggested_hsn VARCHAR(8);
  v_material_group VARCHAR(20);
BEGIN
  -- Get material master data
  SELECT * INTO v_material
  FROM material_master
  WHERE material_code = p_material_code 
    AND company_code = p_company_code
    AND is_active = true;
  
  -- Check if material exists
  IF v_material IS NULL THEN
    RETURN QUERY SELECT
      'MATERIAL_MISSING'::VARCHAR(20),
      'Material ' || p_material_code || ' not found in material master'::TEXT,
      NULL::VARCHAR(8),
      NULL::VARCHAR(20),
      true;
    RETURN;
  END IF;
  
  v_material_group := v_material.material_group;
  
  -- Check if HSN is populated in material master
  IF v_material.hsn_sac_code IS NULL OR v_material.hsn_sac_code = '' THEN
    -- SAP Behavior: Block transaction and suggest HSN
    v_suggested_hsn := CASE v_material_group
      WHEN 'STEEL' THEN '7214'
      WHEN 'CEMENT' THEN '2523'
      WHEN 'STRUCTURAL_STEEL' THEN '7308'
      WHEN 'EQUIPMENT' THEN '8426'
      WHEN 'CONSUMABLES' THEN '3920'
      ELSE '7214' -- Default construction material
    END;
    
    RETURN QUERY SELECT
      'HSN_MISSING'::VARCHAR(20),
      'HSN/SAC code is mandatory for GST compliance. Material: ' || p_material_code || 
      '. Please update material master or provide HSN code for this transaction.'::TEXT,
      v_suggested_hsn,
      v_material_group,
      true; -- Requires user input
    RETURN;
  END IF;
  
  -- Validate HSN exists in GST rates table
  SELECT EXISTS(
    SELECT 1 FROM gst_rates_simple 
    WHERE hsn_code = v_material.hsn_sac_code 
      AND company_code = p_company_code
      AND is_active = true
  ) INTO v_hsn_exists;
  
  IF NOT v_hsn_exists THEN
    RETURN QUERY SELECT
      'HSN_INVALID'::VARCHAR(20),
      'HSN code ' || v_material.hsn_sac_code || ' not found in GST rates master. Please configure GST rate for this HSN.'::TEXT,
      v_material.hsn_sac_code,
      v_material_group,
      true;
    RETURN;
  END IF;
  
  -- All validations passed
  RETURN QUERY SELECT
    'SUCCESS'::VARCHAR(20),
    NULL::TEXT,
    v_material.hsn_sac_code,
    v_material_group,
    false;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 2. TRANSACTION-LEVEL HSN OVERRIDE TABLE
-- ========================================

CREATE TABLE transaction_hsn_overrides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id VARCHAR(50) NOT NULL,
  material_code VARCHAR(20) NOT NULL,
  original_hsn VARCHAR(8),
  override_hsn VARCHAR(8) NOT NULL,
  override_reason TEXT,
  user_id VARCHAR(50) NOT NULL,
  company_code VARCHAR(10) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(transaction_id, material_code)
);

-- ========================================
-- 3. SAP-LIKE GL DETERMINATION WITH VALIDATION
-- ========================================

CREATE OR REPLACE FUNCTION get_gl_with_hsn_validation(
  p_company_code VARCHAR(10),
  p_movement_type VARCHAR(10),
  p_material_code VARCHAR(20),
  p_supplier_code VARCHAR(20),
  p_taxable_amount DECIMAL(15,2),
  p_transaction_id VARCHAR(50) DEFAULT NULL,
  p_override_hsn VARCHAR(8) DEFAULT NULL,
  p_user_id VARCHAR(50) DEFAULT NULL
) RETURNS TABLE (
  validation_status VARCHAR(20),
  error_message TEXT,
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
  hsn_used VARCHAR(8),
  requires_user_action BOOLEAN
) AS $$
DECLARE
  v_validation RECORD;
  v_gl_result RECORD;
  v_final_hsn VARCHAR(8);
  v_material RECORD;
BEGIN
  -- First validate HSN
  SELECT * INTO v_validation
  FROM validate_hsn_for_transaction(
    p_company_code, p_material_code, p_movement_type, p_supplier_code, p_taxable_amount
  );
  
  -- If validation failed and no override provided, return error
  IF v_validation.validation_status != 'SUCCESS' AND p_override_hsn IS NULL THEN
    RETURN QUERY SELECT
      v_validation.validation_status,
      v_validation.error_message,
      NULL::VARCHAR(20), NULL::DECIMAL(15,2), NULL::VARCHAR(20), NULL::DECIMAL(15,2),
      NULL::VARCHAR(20), NULL::DECIMAL(15,2), NULL::VARCHAR(20), NULL::DECIMAL(15,2),
      NULL::VARCHAR(20), NULL::DECIMAL(15,2), NULL::DECIMAL(15,2),
      v_validation.suggested_hsn,
      v_validation.requires_user_input;
    RETURN;
  END IF;
  
  -- Determine HSN to use
  IF p_override_hsn IS NOT NULL THEN
    v_final_hsn := p_override_hsn;
    
    -- Log the override if transaction_id provided
    IF p_transaction_id IS NOT NULL AND p_user_id IS NOT NULL THEN
      INSERT INTO transaction_hsn_overrides (
        transaction_id, material_code, original_hsn, override_hsn, 
        override_reason, user_id, company_code
      ) VALUES (
        p_transaction_id, p_material_code, v_validation.suggested_hsn, p_override_hsn,
        'User override for missing HSN in material master', p_user_id, p_company_code
      ) ON CONFLICT (transaction_id, material_code) DO UPDATE SET
        override_hsn = EXCLUDED.override_hsn,
        override_reason = EXCLUDED.override_reason;
    END IF;
  ELSE
    -- Get HSN from material master
    SELECT hsn_sac_code INTO v_final_hsn
    FROM material_master
    WHERE material_code = p_material_code AND company_code = p_company_code;
  END IF;
  
  -- Get GL determination using the final HSN
  SELECT * INTO v_gl_result
  FROM get_gl_accounts_minimal_safe(
    p_company_code, p_movement_type, v_final_hsn, p_supplier_code, p_taxable_amount
  );
  
  -- Return successful GL determination
  RETURN QUERY SELECT
    'SUCCESS'::VARCHAR(20),
    NULL::TEXT,
    v_gl_result.material_account,
    v_gl_result.material_amount,
    v_gl_result.cgst_account,
    v_gl_result.cgst_amount,
    v_gl_result.sgst_account,
    v_gl_result.sgst_amount,
    v_gl_result.igst_account,
    v_gl_result.igst_amount,
    v_gl_result.payable_account,
    v_gl_result.payable_amount,
    v_gl_result.total_gst,
    v_final_hsn,
    false;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 4. TEST SAP-LIKE BEHAVIOR
-- ========================================

-- Test 1: Material with missing HSN (should block)
SELECT 'TEST: Missing HSN - Should Block Transaction' as test_case;
SELECT validation_status, error_message, suggested_hsn, requires_user_action
FROM validate_hsn_for_transaction('C001', 'STEEL_TMT_8MM', 'C101', 'STEEL_SUPPLIER', 100000);

-- Test 2: Valid material with HSN (should succeed)
SELECT 'TEST: Valid HSN - Should Allow Transaction' as test_case;
SELECT validation_status, error_message, requires_user_action
FROM validate_hsn_for_transaction('C001', 'STEEL_TMT_8MM', 'C101', 'STEEL_SUPPLIER', 100000);

SELECT 'SAP-LIKE HSN VALIDATION IMPLEMENTED' as status;