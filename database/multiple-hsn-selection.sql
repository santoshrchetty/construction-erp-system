-- MULTIPLE HSN CODES FOR SINGLE MATERIAL - SAP-LIKE BEHAVIOR
-- Handles materials that can have different HSN codes based on specifications

-- ========================================
-- 1. MATERIAL HSN VARIANTS TABLE
-- ========================================

CREATE TABLE material_hsn_variants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  material_group VARCHAR(20) NOT NULL,
  material_type VARCHAR(50) NOT NULL,
  hsn_code VARCHAR(8) NOT NULL,
  hsn_description TEXT NOT NULL,
  specification_criteria TEXT,
  is_default BOOLEAN DEFAULT false,
  company_code VARCHAR(10) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(material_group, hsn_code, company_code)
);

-- ========================================
-- 2. POPULATE STEEL HSN VARIANTS
-- ========================================

INSERT INTO material_hsn_variants (material_group, material_type, hsn_code, hsn_description, specification_criteria, is_default, company_code) VALUES
-- Steel variants
('STEEL', 'TMT Bars & Reinforcement', '7214', 'Iron/steel bars, rods, hot-rolled', 'TMT bars, reinforcement steel, rebars', true, 'C001'),
('STEEL', 'Angles & Sections', '7216', 'Angles, shapes and sections of iron/steel', 'L-angles, C-channels, I-beams, structural sections', false, 'C001'),
('STEEL', 'Fabricated Structures', '7308', 'Structures and parts of structures', 'Pre-fabricated buildings, towers, bridges', false, 'C001'),
('STEEL', 'Wire & Wire Products', '7213', 'Bars and rods of iron/steel, hot-rolled', 'Wire rods, binding wire, mesh', false, 'C001'),
('STEEL', 'Cold Formed Products', '7215', 'Other bars and rods of iron/steel', 'Cold-formed bars, precision tubes', false, 'C001'),

-- Cement variants  
('CEMENT', 'Portland Cement', '2523', 'Portland cement, aluminous cement', 'OPC 43/53 grade, PPC cement', true, 'C001'),
('CEMENT', 'Special Cement', '2523', 'Portland cement, aluminous cement', 'White cement, rapid hardening cement', false, 'C001'),

-- Equipment variants
('EQUIPMENT', 'Construction Equipment', '8426', 'Ships derricks; cranes; mobile lifting frames', 'Tower cranes, mobile cranes, hoists', true, 'C001'),
('EQUIPMENT', 'Earth Moving Equipment', '8429', 'Self-propelled bulldozers, graders', 'Excavators, bulldozers, loaders', false, 'C001'),
('EQUIPMENT', 'Concrete Equipment', '8430', 'Other moving, grading machines', 'Concrete mixers, pumps, vibrators', false, 'C001');

-- ========================================
-- 3. HSN SELECTION FUNCTION (SAP-LIKE)
-- ========================================

CREATE OR REPLACE FUNCTION get_hsn_options_for_material(
  p_company_code VARCHAR(10),
  p_material_code VARCHAR(20)
) RETURNS TABLE (
  selection_required BOOLEAN,
  default_hsn VARCHAR(8),
  hsn_options JSON,
  material_group VARCHAR(20),
  selection_message TEXT
) AS $$
DECLARE
  v_material RECORD;
  v_hsn_count INTEGER;
  v_hsn_options JSON;
  v_default_hsn VARCHAR(8);
BEGIN
  -- Get material details
  SELECT * INTO v_material
  FROM material_master
  WHERE material_code = p_material_code 
    AND company_code = p_company_code
    AND is_active = true;
  
  IF v_material IS NULL THEN
    RETURN QUERY SELECT
      false,
      NULL::VARCHAR(8),
      NULL::JSON,
      NULL::VARCHAR(20),
      'Material not found'::TEXT;
    RETURN;
  END IF;
  
  -- Check if material already has HSN assigned
  IF v_material.hsn_sac_code IS NOT NULL AND v_material.hsn_sac_code != '' THEN
    RETURN QUERY SELECT
      false,
      v_material.hsn_sac_code,
      NULL::JSON,
      v_material.material_group,
      'HSN already assigned in material master'::TEXT;
    RETURN;
  END IF;
  
  -- Get available HSN options for this material group
  SELECT COUNT(*), 
         json_agg(json_build_object(
           'hsn_code', hsn_code,
           'hsn_description', hsn_description,
           'specification_criteria', specification_criteria,
           'is_default', is_default
         ) ORDER BY is_default DESC, hsn_code)
  INTO v_hsn_count, v_hsn_options
  FROM material_hsn_variants
  WHERE material_group = v_material.material_group
    AND company_code = p_company_code
    AND is_active = true;
  
  -- Get default HSN
  SELECT hsn_code INTO v_default_hsn
  FROM material_hsn_variants
  WHERE material_group = v_material.material_group
    AND company_code = p_company_code
    AND is_default = true
    AND is_active = true
  LIMIT 1;
  
  -- If multiple HSN options available, require selection
  IF v_hsn_count > 1 THEN
    RETURN QUERY SELECT
      true,
      v_default_hsn,
      v_hsn_options,
      v_material.material_group,
      'Multiple HSN codes available for ' || v_material.material_group || 
      '. Please select appropriate HSN based on material specification.'::TEXT;
  ELSIF v_hsn_count = 1 THEN
    RETURN QUERY SELECT
      false,
      v_default_hsn,
      v_hsn_options,
      v_material.material_group,
      'Single HSN option available'::TEXT;
  ELSE
    RETURN QUERY SELECT
      true,
      '7214'::VARCHAR(8), -- Fallback
      '[{"hsn_code":"7214","hsn_description":"Default construction material","specification_criteria":"General construction use","is_default":true}]'::JSON,
      v_material.material_group,
      'No HSN configured for material group. Using default.'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 4. ENHANCED VALIDATION WITH HSN SELECTION
-- ========================================

CREATE OR REPLACE FUNCTION validate_hsn_with_selection(
  p_company_code VARCHAR(10),
  p_material_code VARCHAR(20),
  p_movement_type VARCHAR(10),
  p_supplier_code VARCHAR(20),
  p_taxable_amount DECIMAL(15,2)
) RETURNS TABLE (
  validation_status VARCHAR(20), -- SUCCESS, HSN_SELECTION_REQUIRED, HSN_MISSING
  error_message TEXT,
  hsn_options JSON,
  default_hsn VARCHAR(8),
  material_group VARCHAR(20),
  requires_user_selection BOOLEAN
) AS $$
DECLARE
  v_hsn_selection RECORD;
BEGIN
  -- Get HSN selection options
  SELECT * INTO v_hsn_selection
  FROM get_hsn_options_for_material(p_company_code, p_material_code);
  
  -- If selection required, return options to user
  IF v_hsn_selection.selection_required THEN
    RETURN QUERY SELECT
      'HSN_SELECTION_REQUIRED'::VARCHAR(20),
      v_hsn_selection.selection_message,
      v_hsn_selection.hsn_options,
      v_hsn_selection.default_hsn,
      v_hsn_selection.material_group,
      true;
    RETURN;
  END IF;
  
  -- If HSN available, validate it exists in GST rates
  IF v_hsn_selection.default_hsn IS NOT NULL THEN
    IF EXISTS(
      SELECT 1 FROM gst_rates_simple 
      WHERE hsn_code = v_hsn_selection.default_hsn 
        AND company_code = p_company_code
        AND is_active = true
    ) THEN
      RETURN QUERY SELECT
        'SUCCESS'::VARCHAR(20),
        NULL::TEXT,
        NULL::JSON,
        v_hsn_selection.default_hsn,
        v_hsn_selection.material_group,
        false;
    ELSE
      RETURN QUERY SELECT
        'HSN_MISSING'::VARCHAR(20),
        'HSN code ' || v_hsn_selection.default_hsn || ' not configured in GST rates master'::TEXT,
        NULL::JSON,
        v_hsn_selection.default_hsn,
        v_hsn_selection.material_group,
        true;
    END IF;
  ELSE
    RETURN QUERY SELECT
      'HSN_MISSING'::VARCHAR(20),
      'No HSN code available for material'::TEXT,
      NULL::JSON,
      NULL::VARCHAR(8),
      v_hsn_selection.material_group,
      true;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 5. TEST MULTIPLE HSN SCENARIOS
-- ========================================

-- Test steel material (should show multiple HSN options)
SELECT 'TEST: Steel Material - Multiple HSN Options' as test_case;
SELECT * FROM get_hsn_options_for_material('C001', 'STEEL_TMT_8MM');

-- Test validation requiring HSN selection
SELECT 'TEST: HSN Selection Required' as test_case;
SELECT validation_status, error_message, requires_user_selection, 
       json_array_length(hsn_options) as option_count
FROM validate_hsn_with_selection('C001', 'STEEL_TMT_8MM', 'C101', 'STEEL_SUPPLIER', 100000);

SELECT 'MULTIPLE HSN SELECTION IMPLEMENTED - SAP-LIKE BEHAVIOR' as status;