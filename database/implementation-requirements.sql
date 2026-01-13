-- IMPLEMENTATION REQUIREMENTS: GL Determination Engine
-- Critical fixes needed for production readiness

-- ========================================
-- PHASE 1: CRITICAL FIXES (MUST IMPLEMENT)
-- ========================================

-- 1. CORRECTED GST RATE MASTER
CREATE TABLE gst_rate_master_v2 (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- HSN/SAC with validation
  hsn_sac_code VARCHAR(8) NOT NULL CHECK (hsn_sac_code ~ '^[0-9]{4}$|^[0-9]{6}$|^[0-9]{8}$'),
  commodity_description TEXT NOT NULL,
  
  -- Single GST rate (as per law)
  gst_rate DECIMAL(5,2) NOT NULL CHECK (gst_rate IN (0, 0.25, 3, 5, 12, 18, 28)),
  cess_rate DECIMAL(5,2) DEFAULT 0,
  
  -- Input credit rules
  input_credit_eligible BOOLEAN DEFAULT true,
  capital_goods_flag BOOLEAN DEFAULT false,
  
  -- Capital goods phasing (20% per year for 5 years)
  immediate_credit_percent DECIMAL(5,2) DEFAULT 100.00,
  
  -- Regulatory tracking
  notification_number VARCHAR(50) NOT NULL,
  effective_date DATE NOT NULL,
  end_date DATE,
  
  company_code VARCHAR(10) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  
  -- Prevent overlapping periods
  CONSTRAINT no_overlap EXCLUDE USING gist (
    hsn_sac_code WITH =,
    company_code WITH =,
    daterange(effective_date, COALESCE(end_date, '9999-12-31'::date)) WITH &&
  )
);

-- 2. STATE MASTER FOR GST CALCULATION
CREATE TABLE state_master (
  state_code VARCHAR(2) PRIMARY KEY,
  state_name VARCHAR(50) NOT NULL,
  is_union_territory BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true
);

-- Insert Indian states
INSERT INTO state_master (state_code, state_name) VALUES
('MH', 'Maharashtra'), ('DL', 'Delhi'), ('KA', 'Karnataka'),
('TN', 'Tamil Nadu'), ('GJ', 'Gujarat'), ('RJ', 'Rajasthan'),
('UP', 'Uttar Pradesh'), ('WB', 'West Bengal'), ('AP', 'Andhra Pradesh'),
('TG', 'Telangana'), ('KL', 'Kerala'), ('OR', 'Odisha'),
('JH', 'Jharkhand'), ('AS', 'Assam'), ('PB', 'Punjab'),
('HR', 'Haryana'), ('HP', 'Himachal Pradesh'), ('UK', 'Uttarakhand'),
('BR', 'Bihar'), ('MP', 'Madhya Pradesh'), ('CG', 'Chhattisgarh'),
('GA', 'Goa'), ('MN', 'Manipur'), ('MZ', 'Mizoram'),
('NL', 'Nagaland'), ('SK', 'Sikkim'), ('TR', 'Tripura'),
('AR', 'Arunachal Pradesh'), ('ML', 'Meghalaya');

-- 3. SUPPLIER/BUYER MASTER WITH STATE
CREATE TABLE entity_master (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_code VARCHAR(20) NOT NULL,
  entity_name VARCHAR(100) NOT NULL,
  entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('SUPPLIER', 'CUSTOMER', 'COMPANY')),
  
  -- Address details
  state_code VARCHAR(2) NOT NULL REFERENCES state_master(state_code),
  gstin VARCHAR(15), -- GST identification number
  
  -- GST registration details
  gst_registration_type VARCHAR(20) DEFAULT 'REGULAR', -- REGULAR, COMPOSITION, UNREGISTERED
  
  company_code VARCHAR(10) NOT NULL,
  is_active BOOLEAN DEFAULT true
);

-- 4. CORRECTED GL DETERMINATION FUNCTION
CREATE OR REPLACE FUNCTION determine_gl_accounts_v2(
  p_company_code VARCHAR(10),
  p_movement_type VARCHAR(10),
  p_hsn_code VARCHAR(8),
  p_supplier_code VARCHAR(20),
  p_buyer_code VARCHAR(20) DEFAULT NULL, -- NULL means company itself
  p_taxable_amount DECIMAL(15,2),
  p_transaction_date DATE DEFAULT CURRENT_DATE
) RETURNS TABLE (
  -- Material account
  material_account VARCHAR(20),
  material_amount DECIMAL(15,2),
  
  -- GST accounts (state-based)
  cgst_account VARCHAR(20),
  cgst_amount DECIMAL(15,2),
  sgst_account VARCHAR(20),
  sgst_amount DECIMAL(15,2),
  igst_account VARCHAR(20),
  igst_amount DECIMAL(15,2),
  
  -- Input credit
  input_credit_immediate DECIMAL(15,2),
  input_credit_restricted DECIMAL(15,2),
  
  -- Payable
  payable_account VARCHAR(20),
  payable_amount DECIMAL(15,2),
  
  -- Metadata
  is_inter_state BOOLEAN,
  gst_rate_applied DECIMAL(5,2),
  capital_goods_flag BOOLEAN
) AS $$
DECLARE
  v_supplier_state VARCHAR(2);
  v_buyer_state VARCHAR(2);
  v_gst_rate RECORD;
  v_is_inter_state BOOLEAN;
  v_cgst_amount DECIMAL(15,2) := 0;
  v_sgst_amount DECIMAL(15,2) := 0;
  v_igst_amount DECIMAL(15,2) := 0;
  v_total_gst DECIMAL(15,2);
  v_immediate_credit DECIMAL(15,2);
  v_restricted_credit DECIMAL(15,2);
BEGIN
  -- Get supplier state
  SELECT state_code INTO v_supplier_state
  FROM entity_master
  WHERE entity_code = p_supplier_code AND is_active = true;
  
  -- Get buyer state (company's state if not specified)
  IF p_buyer_code IS NULL THEN
    SELECT state_code INTO v_buyer_state
    FROM entity_master
    WHERE entity_type = 'COMPANY' AND company_code = p_company_code AND is_active = true;
  ELSE
    SELECT state_code INTO v_buyer_state
    FROM entity_master
    WHERE entity_code = p_buyer_code AND is_active = true;
  END IF;
  
  -- Determine if inter-state
  v_is_inter_state := (v_supplier_state != v_buyer_state);
  
  -- Get GST rate
  SELECT * INTO v_gst_rate
  FROM gst_rate_master_v2
  WHERE hsn_sac_code = p_hsn_code
    AND company_code = p_company_code
    AND effective_date <= p_transaction_date
    AND (end_date IS NULL OR end_date > p_transaction_date)
    AND is_active = true
  ORDER BY effective_date DESC
  LIMIT 1;
  
  IF v_gst_rate IS NULL THEN
    RAISE EXCEPTION 'No GST rate found for HSN: %', p_hsn_code;
  END IF;
  
  -- Calculate GST amounts based on state
  IF v_is_inter_state THEN
    -- Inter-state: IGST only
    v_igst_amount := p_taxable_amount * v_gst_rate.gst_rate / 100;
  ELSE
    -- Intra-state: CGST + SGST
    v_cgst_amount := p_taxable_amount * v_gst_rate.gst_rate / 200; -- Half of total rate
    v_sgst_amount := p_taxable_amount * v_gst_rate.gst_rate / 200; -- Half of total rate
  END IF;
  
  v_total_gst := v_cgst_amount + v_sgst_amount + v_igst_amount;
  
  -- Calculate input credit
  IF v_gst_rate.capital_goods_flag THEN
    -- Capital goods: 20% immediate, 80% over 4 years
    v_immediate_credit := v_total_gst * 0.20;
    v_restricted_credit := v_total_gst * 0.80;
  ELSE
    -- Regular goods: 100% immediate
    v_immediate_credit := v_total_gst;
    v_restricted_credit := 0;
  END IF;
  
  -- Return GL determination
  RETURN QUERY SELECT
    -- Material account (simplified - should come from mapping table)
    CASE 
      WHEN p_movement_type = 'C101' THEN '130200'::VARCHAR(20) -- Inventory
      WHEN p_movement_type = 'C111' THEN '140100'::VARCHAR(20) -- WIP
      WHEN p_movement_type = 'C121' THEN '151000'::VARCHAR(20) -- Capital WIP
      ELSE '130200'::VARCHAR(20)
    END,
    p_taxable_amount,
    
    -- GST accounts
    CASE WHEN v_cgst_amount > 0 THEN '170101'::VARCHAR(20) ELSE NULL END, -- CGST Receivable
    v_cgst_amount,
    CASE WHEN v_sgst_amount > 0 THEN '170102'::VARCHAR(20) ELSE NULL END, -- SGST Receivable  
    v_sgst_amount,
    CASE WHEN v_igst_amount > 0 THEN '170103'::VARCHAR(20) ELSE NULL END, -- IGST Receivable
    v_igst_amount,
    
    v_immediate_credit,
    v_restricted_credit,
    
    '210100'::VARCHAR(20), -- Trade Payables
    p_taxable_amount + v_total_gst,
    
    v_is_inter_state,
    v_gst_rate.gst_rate,
    v_gst_rate.capital_goods_flag;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- PHASE 2: INTEGRATION REQUIREMENTS
-- ========================================

-- 5. UPDATE EXISTING API ENDPOINT
-- File: app/api/erp-config/projects/route.ts
-- REQUIRED CHANGES:
/*
// Add HSN code field to all forms
// Add supplier/buyer selection
// Replace old GL determination with new function

// Example API call:
SELECT * FROM determine_gl_accounts_v2(
  'C001',           -- company_code
  'C101',           -- movement_type  
  '7214',           -- hsn_code
  'STEEL_INDIA_LTD', -- supplier_code
  NULL,             -- buyer_code (company)
  800000,           -- taxable_amount
  CURRENT_DATE      -- transaction_date
);
*/

-- 6. UPDATE FRONTEND COMPONENTS
-- File: components/EnhancedProjectsConfigTab.tsx
-- REQUIRED CHANGES:
/*
// Add HSN code field to GL rules form
// Add supplier dropdown
// Add state-based GST display
// Show CGST/SGST vs IGST based on states
// Display input credit breakdown
*/

-- 7. UPDATE SERVICE LAYER
-- File: domains/projects/projectConfigServices.ts
-- REQUIRED CHANGES:
/*
// Add getGLDeterminationV2 method
// Add HSN validation
// Add state-based GST calculation
// Update interfaces to include new fields
*/

-- ========================================
-- PHASE 3: SAMPLE DATA SETUP
-- ========================================

-- Insert sample GST rates
INSERT INTO gst_rate_master_v2 (
  hsn_sac_code, commodity_description, gst_rate, capital_goods_flag,
  immediate_credit_percent, notification_number, effective_date, company_code
) VALUES
('7214', 'Iron or steel bars and rods', 18.0, false, 100.0, 'GST-2017-001', '2017-07-01', 'C001'),
('8426', 'Ships derricks; cranes', 18.0, true, 20.0, 'GST-2017-002', '2017-07-01', 'C001'),
('2523', 'Portland cement', 28.0, false, 100.0, 'GST-2017-003', '2017-07-01', 'C001');

-- Insert sample entities
INSERT INTO entity_master (entity_code, entity_name, entity_type, state_code, company_code) VALUES
('STEEL_INDIA_LTD', 'Steel India Limited', 'SUPPLIER', 'MH', 'C001'),
('ABC_CONSTRUCTION', 'ABC Construction Company', 'COMPANY', 'MH', 'C001'),
('CEMENT_CORP', 'Cement Corporation', 'SUPPLIER', 'DL', 'C001');

-- ========================================
-- IMPLEMENTATION CHECKLIST
-- ========================================

SELECT 'IMPLEMENTATION CHECKLIST' as phase, 'STATUS' as status, 'EFFORT' as effort;

SELECT '1. Create corrected GST rate master' as task, 'PENDING' as status, '4 hours' as effort
UNION ALL
SELECT '2. Create state master data', 'PENDING', '1 hour'
UNION ALL  
SELECT '3. Create entity master with states', 'PENDING', '2 hours'
UNION ALL
SELECT '4. Implement corrected GL function', 'PENDING', '6 hours'
UNION ALL
SELECT '5. Update API endpoints', 'PENDING', '4 hours'
UNION ALL
SELECT '6. Update frontend components', 'PENDING', '6 hours'
UNION ALL
SELECT '7. Update service layer', 'PENDING', '3 hours'
UNION ALL
SELECT '8. Add validation logic', 'PENDING', '2 hours'
UNION ALL
SELECT '9. Create test cases', 'PENDING', '4 hours'
UNION ALL
SELECT '10. Integration testing', 'PENDING', '4 hours'
UNION ALL
SELECT '', '', ''
UNION ALL
SELECT 'TOTAL EFFORT', '', '36 hours (4-5 days)'
UNION ALL
SELECT 'PRIORITY', 'CRITICAL', 'PRODUCTION BLOCKER';

-- Test the corrected implementation
SELECT 'TEST CASE 1: Intra-state steel purchase' as test;
-- Expected: CGST=9%, SGST=9%, IGST=0%, Immediate credit=100%

SELECT 'TEST CASE 2: Inter-state equipment purchase' as test;  
-- Expected: CGST=0%, SGST=0%, IGST=18%, Immediate credit=20%, Restricted=80%