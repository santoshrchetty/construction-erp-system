-- HSN CODE MANAGEMENT: Material Master Approach
-- Recommended implementation for consistency and compliance

-- ========================================
-- 1. MATERIAL MASTER WITH HSN
-- ========================================

CREATE TABLE material_master (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  material_code VARCHAR(20) NOT NULL,
  material_name VARCHAR(100) NOT NULL,
  material_group VARCHAR(20) NOT NULL,
  
  -- HSN Classification (CRITICAL)
  hsn_sac_code VARCHAR(8) NOT NULL,
  commodity_description TEXT,
  
  -- Material Properties
  base_uom VARCHAR(10) NOT NULL,
  material_type VARCHAR(20) DEFAULT 'RAW_MATERIAL', -- RAW_MATERIAL, CONSUMABLE, CAPITAL_GOODS
  
  -- GST Properties (derived from HSN)
  is_capital_goods BOOLEAN DEFAULT false,
  standard_gst_rate DECIMAL(5,2),
  
  -- Master Data
  company_code VARCHAR(10) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(material_code, company_code)
);

-- ========================================
-- 2. HSN MASTER DATA
-- ========================================

CREATE TABLE hsn_master (
  hsn_sac_code VARCHAR(8) PRIMARY KEY,
  commodity_description TEXT NOT NULL,
  chapter_heading VARCHAR(100),
  
  -- GST Properties
  standard_gst_rate DECIMAL(5,2) NOT NULL,
  is_capital_goods BOOLEAN DEFAULT false,
  is_exempt BOOLEAN DEFAULT false,
  
  -- Compliance
  effective_date DATE DEFAULT CURRENT_DATE,
  notification_reference VARCHAR(50),
  
  is_active BOOLEAN DEFAULT true
);

-- ========================================
-- 3. POPULATE HSN MASTER (Construction Focus)
-- ========================================

INSERT INTO hsn_master (hsn_sac_code, commodity_description, standard_gst_rate, is_capital_goods) VALUES
-- Construction Materials
('7214', 'Iron or steel bars, rods, angles, shapes', 18.0, false),
('7308', 'Structures and parts of structures of iron/steel', 18.0, false),
('2523', 'Portland cement, aluminous cement', 28.0, false),
('6810', 'Articles of cement, concrete or artificial stone', 28.0, false),
('7610', 'Aluminium structures and parts thereof', 18.0, false),
('3920', 'Plates, sheets, film, foil of plastics', 18.0, false),

-- Construction Equipment (Capital Goods)
('8426', 'Ships derricks; cranes; mobile lifting frames', 18.0, true),
('8429', 'Self-propelled bulldozers, graders, levellers', 18.0, true),
('8430', 'Other moving, grading, levelling, scraping machines', 18.0, true),
('8479', 'Machines having individual functions', 18.0, true),

-- Construction Services
('9954', 'Construction services', 18.0, false),
('9955', 'Architectural services', 18.0, false);

-- ========================================
-- 4. POPULATE MATERIAL MASTER
-- ========================================

INSERT INTO material_master (
  material_code, material_name, material_group, hsn_sac_code, 
  base_uom, material_type, company_code
) VALUES
-- Raw Materials
('STEEL_TMT_8MM', 'TMT Steel Bars 8mm', 'STEEL', '7214', 'MT', 'RAW_MATERIAL', 'C001'),
('STEEL_TMT_12MM', 'TMT Steel Bars 12mm', 'STEEL', '7214', 'MT', 'RAW_MATERIAL', 'C001'),
('CEMENT_OPC_53', 'OPC Cement Grade 53', 'CEMENT', '2523', 'BAG', 'RAW_MATERIAL', 'C001'),
('CEMENT_PPC', 'Portland Pozzolana Cement', 'CEMENT', '2523', 'BAG', 'RAW_MATERIAL', 'C001'),

-- Structural Items
('STEEL_BEAM_ISMB', 'ISMB Steel Beam', 'STRUCTURAL_STEEL', '7308', 'MT', 'RAW_MATERIAL', 'C001'),
('STEEL_COLUMN', 'Steel Column Section', 'STRUCTURAL_STEEL', '7308', 'MT', 'RAW_MATERIAL', 'C001'),

-- Equipment (Capital Goods)
('CRANE_TOWER_25T', 'Tower Crane 25 Ton', 'EQUIPMENT', '8426', 'NOS', 'CAPITAL_GOODS', 'C001'),
('EXCAVATOR_20T', 'Hydraulic Excavator 20 Ton', 'EQUIPMENT', '8429', 'NOS', 'CAPITAL_GOODS', 'C001'),

-- Consumables
('WELDING_ROD', 'Welding Electrodes', 'CONSUMABLES', '8311', 'KG', 'CONSUMABLE', 'C001'),
('PAINT_PRIMER', 'Primer Paint', 'CONSUMABLES', '3208', 'LTR', 'CONSUMABLE', 'C001');

-- ========================================
-- 5. ENHANCED GL DETERMINATION WITH MATERIAL MASTER
-- ========================================

CREATE OR REPLACE FUNCTION get_gl_with_material_master(
  p_company_code VARCHAR(10),
  p_movement_type VARCHAR(10),
  p_material_code VARCHAR(20),
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
  hsn_code VARCHAR(8),
  material_name VARCHAR(100),
  gst_rate DECIMAL(5,2),
  is_capital_goods BOOLEAN
) AS $$
DECLARE
  v_material RECORD;
  v_hsn RECORD;
  v_gst_calc RECORD;
BEGIN
  -- Get material details with HSN
  SELECT 
    mm.*,
    hm.standard_gst_rate,
    hm.is_capital_goods as hsn_capital_goods,
    hm.commodity_description
  INTO v_material
  FROM material_master mm
  JOIN hsn_master hm ON mm.hsn_sac_code = hm.hsn_sac_code
  WHERE mm.material_code = p_material_code
    AND mm.company_code = p_company_code
    AND mm.is_active = true
    AND hm.is_active = true;
  
  IF v_material IS NULL THEN
    RAISE EXCEPTION 'Material % not found or HSN not configured', p_material_code;
  END IF;
  
  -- Use existing GST calculation function
  SELECT * INTO v_gst_calc
  FROM get_gl_accounts_minimal(
    p_company_code,
    p_movement_type,
    v_material.hsn_sac_code,
    p_supplier_code,
    p_taxable_amount
  );
  
  -- Return enhanced result with material details
  RETURN QUERY SELECT
    v_gst_calc.material_account,
    v_gst_calc.material_amount,
    v_gst_calc.cgst_account,
    v_gst_calc.cgst_amount,
    v_gst_calc.sgst_account,
    v_gst_calc.sgst_amount,
    v_gst_calc.igst_account,
    v_gst_calc.igst_amount,
    v_gst_calc.payable_account,
    v_gst_calc.payable_amount,
    v_material.hsn_sac_code,
    v_material.material_name,
    v_material.standard_gst_rate,
    v_material.hsn_capital_goods;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 6. COMPARISON: CURRENT vs RECOMMENDED
-- ========================================

SELECT 'APPROACH COMPARISON' as aspect, 'CURRENT (Manual)' as current_approach, 'RECOMMENDED (Material Master)' as recommended;

SELECT 'HSN Maintenance' as aspect, 'Manual entry per transaction' as current_approach, 'One-time setup in material master' as recommended
UNION ALL
SELECT 'Consistency', 'Same material can have different HSN', 'Same material always same HSN'
UNION ALL
SELECT 'Error Risk', 'HIGH - Manual entry errors', 'LOW - Automated from master'
UNION ALL
SELECT 'Compliance', 'Manual validation needed', 'Automatic compliance'
UNION ALL
SELECT 'Audit Trail', 'Difficult to trace', 'Clear material-HSN mapping'
UNION ALL
SELECT 'GSTR Filing', 'Manual HSN entry', 'Auto-populated from transactions'
UNION ALL
SELECT 'Maintenance Effort', 'High - per transaction', 'Low - one-time setup'
UNION ALL
SELECT 'Data Quality', 'Inconsistent', 'Consistent and reliable';

-- ========================================
-- 7. MIGRATION STRATEGY
-- ========================================

-- Step 1: Create material master for existing materials
INSERT INTO material_master (material_code, material_name, material_group, hsn_sac_code, base_uom, company_code)
SELECT DISTINCT
  COALESCE(material_group, 'GENERAL') as material_code,
  COALESCE(material_group, 'General Material') as material_name,
  COALESCE(material_group, 'GENERAL') as material_group,
  COALESCE(hsn_sac_code, '7214') as hsn_sac_code,
  'NOS' as base_uom,
  company_code
FROM project_gl_determination
WHERE hsn_sac_code IS NOT NULL
ON CONFLICT (material_code, company_code) DO NOTHING;

-- Step 2: Update GL determination to use material master
-- (This would be done in application code)

-- ========================================
-- 8. RECOMMENDATION SUMMARY
-- ========================================

SELECT 'RECOMMENDATION' as decision, 'IMPLEMENT MATERIAL MASTER APPROACH' as action;
SELECT 'Benefits:' as category, 'Benefit' as description
UNION ALL
SELECT '✅ Consistency', 'Same material = Same HSN always'
UNION ALL
SELECT '✅ Automation', 'GST calculation automated'
UNION ALL
SELECT '✅ Compliance', 'Reduced manual errors'
UNION ALL
SELECT '✅ Audit Ready', 'Clear material-HSN traceability'
UNION ALL
SELECT '✅ GSTR Ready', 'Auto-populated returns'
UNION ALL
SELECT '', ''
UNION ALL
SELECT 'Implementation:', '2-3 hours to setup material master'
UNION ALL
SELECT 'Migration:', '1 hour to migrate existing data'
UNION ALL
SELECT 'Total Effort:', '3-4 hours for complete solution';