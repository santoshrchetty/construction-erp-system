-- ============================================================================
-- CUSTOM ACCOUNT ASSIGNMENT MAPPING STRATEGY
-- ============================================================================

/*
BUSINESS REQUIREMENT:
- User selects MR Type: Project / Maintenance / General / Asset
- System maps to Account Assignment Code (2 letters)
- Account Assignment flows: MR → PR → PO → GR → FI Posting

CUSTOM ACCOUNT ASSIGNMENT CODES:
├─ CC = Cost Center (General expenses)
├─ WB = WBS Element (Project-related)
├─ AS = Asset (Capital expenditure)
├─ WA = WBS + Activity (Project with activity tracking)
├─ OP = Production Order (Manufacturing)
├─ OM = Maintenance Order (Equipment maintenance)
└─ OQ = Quality Order (Quality inspection)
*/

-- ============================================================================
-- 1. CURRENT MR TYPE vs REQUIRED ACCOUNT ASSIGNMENT
-- ============================================================================

/*
┌──────────────────────────────────────────────────────────────────────┐
│ MR TYPE (User Selection) → Account Assignment Code → Cost Object     │
├──────────────────────────────────────────────────────────────────────┤
│ PROJECT                   → WB or WA              → WBS Element       │
│ MAINTENANCE               → OM or CC              → Maint Order / CC  │
│ GENERAL                   → CC                    → Cost Center       │
│ ASSET                     → AS                    → Asset Number      │
│ OFFICE                    → CC                    → Cost Center       │
│ SAFETY                    → CC or WB              → CC or Project     │
│ EQUIPMENT                 → AS or OM              → Asset / Maint Ord │
└──────────────────────────────────────────────────────────────────────┘
*/

-- ============================================================================
-- 2. RECOMMENDED MAPPING STRATEGY
-- ============================================================================

/*
APPROACH: Two-Level Selection

LEVEL 1: MR Type (Header) - User selects category
├─ PROJECT
├─ MAINTENANCE  
├─ GENERAL
├─ ASSET
├─ OFFICE
├─ SAFETY
└─ EQUIPMENT

LEVEL 2: Account Assignment (Line Item) - System suggests, user can override
├─ Based on MR Type
├─ User can change per line item
└─ Validates required fields

EXAMPLE:
MR Type: PROJECT
└─ System suggests: WB (WBS Element)
   └─ User must provide: WBS Element
   └─ User can change to: WA (WBS + Activity)
      └─ Then must provide: WBS Element + Activity Code
*/

-- ============================================================================
-- 3. DATABASE SCHEMA UPDATES
-- ============================================================================

-- Create Account Assignment Type enum/table
CREATE TABLE IF NOT EXISTS account_assignment_types (
  code VARCHAR(2) PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  description TEXT,
  requires_cost_center BOOLEAN DEFAULT FALSE,
  requires_wbs_element BOOLEAN DEFAULT FALSE,
  requires_activity_code BOOLEAN DEFAULT FALSE,
  requires_asset_number BOOLEAN DEFAULT FALSE,
  requires_order_number BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  display_order INTEGER
);

-- Insert account assignment types
INSERT INTO account_assignment_types (code, name, description, requires_cost_center, requires_wbs_element, requires_activity_code, requires_asset_number, requires_order_number, display_order) VALUES
('CC', 'Cost Center', 'General overhead expenses', TRUE, FALSE, FALSE, FALSE, FALSE, 1),
('WB', 'WBS Element', 'Project-related expenses', FALSE, TRUE, FALSE, FALSE, FALSE, 2),
('AS', 'Asset', 'Capital expenditure for assets', FALSE, FALSE, FALSE, TRUE, FALSE, 3),
('WA', 'WBS + Activity', 'Project with activity tracking', FALSE, TRUE, TRUE, FALSE, FALSE, 4),
('OP', 'Production Order', 'Manufacturing production', FALSE, FALSE, FALSE, FALSE, TRUE, 5),
('OM', 'Maintenance Order', 'Equipment maintenance', FALSE, FALSE, FALSE, FALSE, TRUE, 6),
('OQ', 'Quality Order', 'Quality inspection', FALSE, FALSE, FALSE, FALSE, TRUE, 7)
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  requires_cost_center = EXCLUDED.requires_cost_center,
  requires_wbs_element = EXCLUDED.requires_wbs_element,
  requires_activity_code = EXCLUDED.requires_activity_code,
  requires_asset_number = EXCLUDED.requires_asset_number,
  requires_order_number = EXCLUDED.requires_order_number;

-- Create MR Type to Account Assignment mapping table
CREATE TABLE IF NOT EXISTS mr_type_account_assignment_mapping (
  id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  mr_type VARCHAR(20) NOT NULL,
  account_assignment_code VARCHAR(2) NOT NULL REFERENCES account_assignment_types(code),
  is_default BOOLEAN DEFAULT FALSE,
  is_allowed BOOLEAN DEFAULT TRUE,
  display_order INTEGER,
  tenant_id UUID NOT NULL DEFAULT '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  UNIQUE(mr_type, account_assignment_code, tenant_id)
);

-- Insert mappings
INSERT INTO mr_type_account_assignment_mapping (mr_type, account_assignment_code, is_default, is_allowed, display_order) VALUES
-- PROJECT: Can use WB (default) or WA
('PROJECT', 'WB', TRUE, TRUE, 1),
('PROJECT', 'WA', FALSE, TRUE, 2),

-- MAINTENANCE: Can use OM (default) or CC
('MAINTENANCE', 'OM', TRUE, TRUE, 1),
('MAINTENANCE', 'CC', FALSE, TRUE, 2),

-- GENERAL: Only CC
('GENERAL', 'CC', TRUE, TRUE, 1),

-- ASSET: Only AS
('ASSET', 'AS', TRUE, TRUE, 1),

-- OFFICE: Only CC
('OFFICE', 'CC', TRUE, TRUE, 1),

-- SAFETY: Can use CC (default) or WB
('SAFETY', 'CC', TRUE, TRUE, 1),
('SAFETY', 'WB', FALSE, TRUE, 2),

-- EQUIPMENT: Can use AS (default) or OM
('EQUIPMENT', 'AS', TRUE, TRUE, 1),
('EQUIPMENT', 'OM', FALSE, TRUE, 2)
ON CONFLICT (mr_type, account_assignment_code, tenant_id) DO UPDATE SET
  is_default = EXCLUDED.is_default,
  is_allowed = EXCLUDED.is_allowed,
  display_order = EXCLUDED.display_order;

-- ============================================================================
-- 4. UPDATE MR LINE ITEMS TABLE
-- ============================================================================

ALTER TABLE material_request_items
-- Account Assignment (2-letter code)
ADD COLUMN IF NOT EXISTS account_assignment_code VARCHAR(2) REFERENCES account_assignment_types(code),

-- Cost Objects (populate based on account assignment code)
ADD COLUMN IF NOT EXISTS cost_center VARCHAR(10),
ADD COLUMN IF NOT EXISTS wbs_element VARCHAR(24),
ADD COLUMN IF NOT EXISTS activity_code VARCHAR(12),
ADD COLUMN IF NOT EXISTS asset_number VARCHAR(12),
ADD COLUMN IF NOT EXISTS order_number VARCHAR(12), -- For OP/OM/OQ
ADD COLUMN IF NOT EXISTS order_type VARCHAR(2), -- OP/OM/OQ

-- Organizational data (can override header)
ADD COLUMN IF NOT EXISTS plant_code VARCHAR(4),
ADD COLUMN IF NOT EXISTS storage_location_code VARCHAR(4);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_mr_items_account_assignment ON material_request_items(account_assignment_code);
CREATE INDEX IF NOT EXISTS idx_mr_items_wbs ON material_request_items(wbs_element);
CREATE INDEX IF NOT EXISTS idx_mr_items_cost_center ON material_request_items(cost_center);

-- ============================================================================
-- 5. VALIDATION FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION validate_mr_item_account_assignment()
RETURNS TRIGGER AS $$
DECLARE
  v_aa_type RECORD;
BEGIN
  -- Get account assignment type requirements
  SELECT * INTO v_aa_type
  FROM account_assignment_types
  WHERE code = NEW.account_assignment_code;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invalid account assignment code: %', NEW.account_assignment_code;
  END IF;
  
  -- Validate required fields
  IF v_aa_type.requires_cost_center AND NEW.cost_center IS NULL THEN
    RAISE EXCEPTION 'Cost center required for account assignment %', NEW.account_assignment_code;
  END IF;
  
  IF v_aa_type.requires_wbs_element AND NEW.wbs_element IS NULL THEN
    RAISE EXCEPTION 'WBS element required for account assignment %', NEW.account_assignment_code;
  END IF;
  
  IF v_aa_type.requires_activity_code AND NEW.activity_code IS NULL THEN
    RAISE EXCEPTION 'Activity code required for account assignment %', NEW.account_assignment_code;
  END IF;
  
  IF v_aa_type.requires_asset_number AND NEW.asset_number IS NULL THEN
    RAISE EXCEPTION 'Asset number required for account assignment %', NEW.account_assignment_code;
  END IF;
  
  IF v_aa_type.requires_order_number AND NEW.order_number IS NULL THEN
    RAISE EXCEPTION 'Order number required for account assignment %', NEW.account_assignment_code;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_mr_item_account_assignment
BEFORE INSERT OR UPDATE ON material_request_items
FOR EACH ROW
WHEN (NEW.account_assignment_code IS NOT NULL)
EXECUTE FUNCTION validate_mr_item_account_assignment();

-- ============================================================================
-- 6. HELPER FUNCTION: Get Default Account Assignment for MR Type
-- ============================================================================

CREATE OR REPLACE FUNCTION get_default_account_assignment(p_mr_type VARCHAR(20))
RETURNS VARCHAR(2) AS $$
DECLARE
  v_default_code VARCHAR(2);
BEGIN
  SELECT account_assignment_code INTO v_default_code
  FROM mr_type_account_assignment_mapping
  WHERE mr_type = p_mr_type
  AND is_default = TRUE
  LIMIT 1;
  
  RETURN v_default_code;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 7. HELPER FUNCTION: Get Allowed Account Assignments for MR Type
-- ============================================================================

CREATE OR REPLACE FUNCTION get_allowed_account_assignments(p_mr_type VARCHAR(20))
RETURNS TABLE(
  code VARCHAR(2),
  name VARCHAR(50),
  description TEXT,
  is_default BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    aat.code,
    aat.name,
    aat.description,
    mtaa.is_default
  FROM mr_type_account_assignment_mapping mtaa
  JOIN account_assignment_types aat ON aat.code = mtaa.account_assignment_code
  WHERE mtaa.mr_type = p_mr_type
  AND mtaa.is_allowed = TRUE
  AND aat.is_active = TRUE
  ORDER BY mtaa.display_order;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 8. UPDATE PR LINE ITEMS TABLE
-- ============================================================================

ALTER TABLE purchase_requisition_items
-- Replace single-letter with 2-letter code
DROP COLUMN IF EXISTS account_assignment_type CASCADE,
ADD COLUMN IF NOT EXISTS account_assignment_code VARCHAR(2) REFERENCES account_assignment_types(code),

-- Add missing cost objects
ADD COLUMN IF NOT EXISTS activity_code VARCHAR(12),
ADD COLUMN IF NOT EXISTS asset_number VARCHAR(12),
ADD COLUMN IF NOT EXISTS order_number VARCHAR(12),
ADD COLUMN IF NOT EXISTS order_type VARCHAR(2);

-- ============================================================================
-- 9. CONVERSION FUNCTION: MR → PR (Updated)
-- ============================================================================

CREATE OR REPLACE FUNCTION convert_mr_item_to_pr_item_v3(
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
  -- Get MR item with account assignment
  SELECT * INTO v_mr_item
  FROM material_request_items
  WHERE id = p_mr_item_id;
  
  -- Get MR header
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
  
  -- Insert PR item with 2-letter account assignment code
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
    plant_code,
    storage_location_id,
    
    -- Account Assignment (2-letter code + cost objects)
    account_assignment_code,
    cost_center,
    wbs_element,
    activity_code,
    asset_number,
    order_number,
    order_type,
    
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
    COALESCE(v_mr_item.plant_code, v_mr_header.plant_code),
    v_storage_location_id,
    
    -- Copy account assignment from MR item
    v_mr_item.account_assignment_code,
    v_mr_item.cost_center,
    v_mr_item.wbs_element,
    v_mr_item.activity_code,
    v_mr_item.asset_number,
    v_mr_item.order_number,
    v_mr_item.order_type,
    
    'OPEN'
  )
  RETURNING id INTO v_pr_item_id;
  
  RETURN v_pr_item_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 10. UI HELPER QUERIES
-- ============================================================================

-- Get default account assignment when user selects MR type
SELECT get_default_account_assignment('PROJECT'); -- Returns 'WB'

-- Get dropdown options for account assignment based on MR type
SELECT * FROM get_allowed_account_assignments('PROJECT');
/*
Returns:
code | name              | description                    | is_default
-----|-------------------|--------------------------------|------------
WB   | WBS Element       | Project-related expenses       | true
WA   | WBS + Activity    | Project with activity tracking | false
*/

-- Get required fields for selected account assignment
SELECT 
  code,
  name,
  requires_cost_center,
  requires_wbs_element,
  requires_activity_code,
  requires_asset_number,
  requires_order_number
FROM account_assignment_types
WHERE code = 'WA';
/*
Returns: WA requires wbs_element=true, activity_code=true
*/

-- ============================================================================
-- 11. EXAMPLE DATA FLOW
-- ============================================================================

/*
USER CREATES MR:
1. Selects MR Type: "PROJECT"
2. System suggests Account Assignment: "WB" (WBS Element)
3. User must provide: WBS Element (e.g., "WBS-001-001")
4. User can change to: "WA" (WBS + Activity)
   → Then must provide: WBS Element + Activity Code

MR LINE ITEM SAVED:
├─ account_assignment_code: 'WB'
├─ wbs_element: 'WBS-001-001'
├─ cost_center: NULL
├─ activity_code: NULL
└─ asset_number: NULL

AFTER APPROVAL → STOCK CHECK → PR CREATION:
PR LINE ITEM CREATED:
├─ account_assignment_code: 'WB' (copied from MR)
├─ wbs_element: 'WBS-001-001' (copied from MR)
├─ cost_center: NULL
├─ activity_code: NULL
└─ asset_number: NULL

PR → PO → GR → FI POSTING:
All documents maintain same account assignment
*/
