-- ============================================================================
-- ACCOUNT ASSIGNMENT: PROPER SAP MM STRUCTURE
-- ============================================================================

/*
PRINCIPLE: 
- Organizational data (Company, Plant) → HEADER level
- Account assignment (Project, Cost Center, Asset) → LINE ITEM level
- Each line can have different account assignment
*/

-- ============================================================================
-- 1. ADD ACCOUNT ASSIGNMENT TO MR LINE ITEMS
-- ============================================================================

ALTER TABLE material_request_items
-- Account Assignment Type
ADD COLUMN IF NOT EXISTS account_assignment_type VARCHAR(1) 
  CHECK (account_assignment_type IN ('K', 'P', 'A', 'N')),
  -- K = Cost Center (Kostenstelle)
  -- P = Project/WBS (Projekt)
  -- A = Asset (Anlage)
  -- N = Network (Netzplan)

-- Cost Object Fields (one will be populated based on type)
ADD COLUMN IF NOT EXISTS project_code VARCHAR(24),
ADD COLUMN IF NOT EXISTS wbs_element VARCHAR(24),
ADD COLUMN IF NOT EXISTS cost_center VARCHAR(10),
ADD COLUMN IF NOT EXISTS asset_number VARCHAR(12),
ADD COLUMN IF NOT EXISTS network_number VARCHAR(12),

-- GL Account for posting
ADD COLUMN IF NOT EXISTS gl_account VARCHAR(10),
ADD COLUMN IF NOT EXISTS gl_account_description VARCHAR(50),

-- Organizational Data (can override header)
ADD COLUMN IF NOT EXISTS plant_code VARCHAR(4),
ADD COLUMN IF NOT EXISTS storage_location_code VARCHAR(4);

-- Add comments
COMMENT ON COLUMN material_request_items.account_assignment_type IS 
  'K=Cost Center, P=Project/WBS, A=Asset, N=Network';
COMMENT ON COLUMN material_request_items.project_code IS 
  'Project code when account_assignment_type = P';
COMMENT ON COLUMN material_request_items.wbs_element IS 
  'WBS element when account_assignment_type = P';
COMMENT ON COLUMN material_request_items.cost_center IS 
  'Cost center when account_assignment_type = K';

-- ============================================================================
-- 2. UPDATE PR LINE ITEMS (Already has correct structure)
-- ============================================================================

-- PR items already have proper structure:
/*
purchase_requisition_items:
  ✓ account_assignment_type VARCHAR(1)
  ✓ project_code VARCHAR(24)
  ✓ wbs_element VARCHAR(24)
  ✓ cost_center VARCHAR(10)
  ✓ plant_code VARCHAR(4)
  ✓ storage_location_id UUID
*/

-- ============================================================================
-- 3. DATA MIGRATION: Move Header-Level to Line-Level
-- ============================================================================

-- Migrate existing project/cost center from header to line items
UPDATE material_request_items mri
SET 
  account_assignment_type = CASE 
    WHEN mr.project_code IS NOT NULL THEN 'P'
    WHEN mr.cost_center IS NOT NULL THEN 'K'
    ELSE NULL
  END,
  project_code = mr.project_code,
  wbs_element = mr.wbs_element,
  cost_center = mr.cost_center,
  plant_code = mr.plant_code
FROM material_requests mr
WHERE mri.material_request_id = mr.id
AND mri.account_assignment_type IS NULL;

-- ============================================================================
-- 4. ACCOUNT ASSIGNMENT VALIDATION FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION validate_account_assignment()
RETURNS TRIGGER AS $$
BEGIN
  -- Validate that correct cost object is populated
  IF NEW.account_assignment_type = 'P' THEN
    IF NEW.project_code IS NULL THEN
      RAISE EXCEPTION 'Project code required for account assignment type P';
    END IF;
  ELSIF NEW.account_assignment_type = 'K' THEN
    IF NEW.cost_center IS NULL THEN
      RAISE EXCEPTION 'Cost center required for account assignment type K';
    END IF;
  ELSIF NEW.account_assignment_type = 'A' THEN
    IF NEW.asset_number IS NULL THEN
      RAISE EXCEPTION 'Asset number required for account assignment type A';
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_mr_item_account_assignment
BEFORE INSERT OR UPDATE ON material_request_items
FOR EACH ROW
EXECUTE FUNCTION validate_account_assignment();

-- ============================================================================
-- 5. UPDATED CONVERSION FUNCTION (MR → PR)
-- ============================================================================

CREATE OR REPLACE FUNCTION convert_mr_item_to_pr_item_v2(
  p_mr_item_id UUID,
  p_pr_id UUID,
  p_shortage_qty NUMERIC(13,3)
)
RETURNS UUID AS $$
DECLARE
  v_pr_item_id UUID;
  v_material_id UUID;
  v_storage_location_id UUID;
  v_mr_item RECORD;
  v_mr_header RECORD;
BEGIN
  -- Get MR item details (now includes account assignment)
  SELECT * INTO v_mr_item
  FROM material_request_items
  WHERE id = p_mr_item_id;
  
  -- Get MR header details (organizational data only)
  SELECT * INTO v_mr_header
  FROM material_requests
  WHERE id = v_mr_item.material_request_id;
  
  -- Lookup material_id
  SELECT id INTO v_material_id
  FROM materials
  WHERE material_code = v_mr_item.material_code;
  
  -- Lookup storage_location_id
  SELECT id INTO v_storage_location_id
  FROM storage_locations
  WHERE sloc_code = COALESCE(v_mr_item.storage_location_code, v_mr_item.storage_location)
  AND plant_code = COALESCE(v_mr_item.plant_code, v_mr_header.plant_code)
  LIMIT 1;
  
  -- Insert PR item with LINE-LEVEL account assignment
  INSERT INTO purchase_requisition_items (
    pr_id,
    mr_item_id,
    line_number,
    material_id,
    material_code,
    material_name,
    description,
    quantity,
    base_uom,
    unit_price,
    total_price,
    currency_code,
    delivery_date,
    
    -- Organizational Data (from header or line override)
    plant_code,
    storage_location_id,
    
    -- Account Assignment (from LINE ITEM)
    account_assignment_type,
    project_code,
    wbs_element,
    cost_center,
    
    item_status
  ) VALUES (
    p_pr_id,
    p_mr_item_id,
    v_mr_item.line_number,
    v_material_id,
    v_mr_item.material_code,
    v_mr_item.material_description,
    COALESCE(v_mr_item.notes, v_mr_item.material_description),
    p_shortage_qty,
    v_mr_item.unit_of_measure,
    v_mr_item.standard_price,
    p_shortage_qty * v_mr_item.standard_price,
    v_mr_header.currency,
    v_mr_header.required_date,
    
    -- Org data: Use line-level if exists, else header
    COALESCE(v_mr_item.plant_code, v_mr_header.plant_code),
    v_storage_location_id,
    
    -- Account assignment: From LINE ITEM
    v_mr_item.account_assignment_type,
    v_mr_item.project_code,
    v_mr_item.wbs_element,
    v_mr_item.cost_center,
    
    'OPEN'
  )
  RETURNING id INTO v_pr_item_id;
  
  RETURN v_pr_item_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 6. EXAMPLE DATA STRUCTURE
-- ============================================================================

/*
CORRECT STRUCTURE:

MR Header:
├─ company_code: '1000'          ← Organizational
├─ plant_code: 'P001'            ← Organizational
└─ currency: 'USD'               ← Organizational

MR Line Items:
├─ Line 1:
│  ├─ material_code: 'CEMENT-001'
│  ├─ quantity: 100
│  ├─ account_assignment_type: 'P'     ← Account Assignment
│  ├─ project_code: 'PRJ-001'          ← Account Assignment
│  ├─ wbs_element: 'WBS-001-001'       ← Account Assignment
│  └─ plant_code: 'P001' (inherited)   ← Can override
│
└─ Line 2:
   ├─ material_code: 'OFFICE-001'
   ├─ quantity: 50
   ├─ account_assignment_type: 'K'     ← Different assignment!
   ├─ cost_center: 'CC-ADMIN'          ← Account Assignment
   └─ plant_code: 'P002' (override!)   ← Different plant!

PR Line Items (After Conversion):
├─ Line 1:
│  ├─ Inherits: account_assignment_type='P', project_code, wbs_element
│  └─ From MR Line 1
│
└─ Line 2:
   ├─ Inherits: account_assignment_type='K', cost_center
   └─ From MR Line 2
*/

-- ============================================================================
-- 7. VERIFICATION QUERY
-- ============================================================================

SELECT 
  mr.request_number,
  mr.company_code as header_company,
  mr.plant_code as header_plant,
  
  mri.line_number,
  mri.material_code,
  mri.account_assignment_type,
  
  -- Show which cost object is populated
  CASE mri.account_assignment_type
    WHEN 'P' THEN mri.project_code || ' / ' || mri.wbs_element
    WHEN 'K' THEN mri.cost_center
    WHEN 'A' THEN mri.asset_number
    ELSE 'None'
  END as cost_object,
  
  COALESCE(mri.plant_code, mr.plant_code) as effective_plant
  
FROM material_requests mr
JOIN material_request_items mri ON mri.material_request_id = mr.id
ORDER BY mr.request_number, mri.line_number;
