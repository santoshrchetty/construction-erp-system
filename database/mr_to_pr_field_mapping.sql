-- ============================================================================
-- FIELD MAPPING: MATERIAL REQUEST ITEMS → PURCHASE REQUISITION ITEMS
-- ============================================================================

/*
PURPOSE: Document field mapping for auto-converting MR items to PR items
when stock is not available

CONVERSION LOGIC:
- When MR approved and stock check shows insufficient quantity
- System auto-creates PR with shortage quantity
- Maintains traceability via mr_item_id foreign key
*/

-- ============================================================================
-- MATERIAL REQUEST ITEMS STRUCTURE (Source)
-- ============================================================================
/*
material_request_items:
  - id (UUID)
  - material_request_id (UUID) → FK to material_requests
  - line_number (INTEGER)
  - material_code (VARCHAR(50))
  - material_description (TEXT)
  - quantity (DECIMAL(15,3))
  - unit_of_measure (VARCHAR(10))
  - standard_price (DECIMAL(15,2))
  - total_line_value (DECIMAL(15,2))
  - available_stock (DECIMAL(15,3))
  - reserved_quantity (DECIMAL(15,3))
  - issued_quantity (DECIMAL(15,3))
  - status (VARCHAR(20))
  - storage_location (VARCHAR(50))
  - batch_number (VARCHAR(50))
  - serial_number (VARCHAR(50))
  - notes (TEXT)
*/

-- ============================================================================
-- PURCHASE REQUISITION ITEMS STRUCTURE (Target)
-- ============================================================================
/*
purchase_requisition_items:
  - id (UUID)
  - pr_id (UUID) → FK to purchase_requisitions
  - mr_item_id (UUID) → FK to material_request_items (TRACEABILITY)
  - line_number (INTEGER)
  - material_id (UUID) → FK to materials
  - material_code (VARCHAR(18))
  - material_name (VARCHAR(100))
  - description (TEXT)
  - quantity (DECIMAL(13,3))
  - base_uom (VARCHAR(3))
  - unit_price (DECIMAL(13,2))
  - total_price (DECIMAL(15,2))
  - currency_code (VARCHAR(3))
  - delivery_date (DATE)
  - plant_code (VARCHAR(4))
  - storage_location_id (UUID) → FK to storage_locations
  - vendor_code (VARCHAR(10))
  - vendor_name (VARCHAR(100))
  - account_assignment_type (VARCHAR(1))
  - project_code (VARCHAR(24))
  - wbs_element (VARCHAR(24))
  - cost_center (VARCHAR(10))
  - item_status (VARCHAR(20))
*/

-- ============================================================================
-- FIELD MAPPING TABLE
-- ============================================================================

/*
┌─────────────────────────────────────────────────────────────────────────┐
│ MR ITEM FIELD              → PR ITEM FIELD           │ CONVERSION LOGIC  │
├─────────────────────────────────────────────────────────────────────────┤
│ id                         → mr_item_id              │ Direct copy       │
│ line_number                → line_number             │ Direct copy       │
│ material_code              → material_code           │ Direct copy       │
│ material_description       → material_name           │ Direct copy       │
│ material_description       → description             │ Direct copy       │
│ quantity                   → quantity                │ SHORTAGE ONLY*    │
│ unit_of_measure            → base_uom                │ Direct copy       │
│ standard_price             → unit_price              │ Direct copy       │
│ total_line_value           → total_price             │ Recalculate**     │
│ storage_location           → storage_location_id     │ Lookup UUID***    │
│ notes                      → description             │ Append to desc    │
│                                                                           │
│ FROM MR HEADER:                                                          │
│ project_code               → project_code            │ From MR header    │
│ wbs_element                → wbs_element             │ From MR header    │
│ cost_center                → cost_center             │ From MR header    │
│ plant_code                 → plant_code              │ From MR header    │
│ required_date              → delivery_date           │ From MR header    │
│ currency                   → currency_code           │ From MR header    │
│                                                                           │
│ DERIVED/DEFAULT:                                                         │
│ (new UUID)                 → id                      │ Generate new      │
│ (PR header id)             → pr_id                   │ New PR id         │
│ (lookup)                   → material_id             │ Lookup from code  │
│ 'P' or 'K'                 → account_assignment_type │ P if project      │
│ 'OPEN'                     → item_status             │ Default           │
│ NULL                       → vendor_code             │ To be filled      │
│ NULL                       → vendor_name             │ To be filled      │
└─────────────────────────────────────────────────────────────────────────┘

* SHORTAGE ONLY: quantity = mr_item.quantity - available_stock
** RECALCULATE: total_price = shortage_quantity × unit_price
*** LOOKUP UUID: Find storage_location.id from storage_location.sloc_code
*/

-- ============================================================================
-- CONVERSION SQL FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION convert_mr_item_to_pr_item(
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
  -- Get MR item details
  SELECT * INTO v_mr_item
  FROM material_request_items
  WHERE id = p_mr_item_id;
  
  -- Get MR header details
  SELECT * INTO v_mr_header
  FROM material_requests
  WHERE id = v_mr_item.material_request_id;
  
  -- Lookup material_id from material_code
  SELECT id INTO v_material_id
  FROM materials
  WHERE material_code = v_mr_item.material_code;
  
  -- Lookup storage_location_id from sloc_code
  SELECT id INTO v_storage_location_id
  FROM storage_locations
  WHERE sloc_code = v_mr_item.storage_location
  LIMIT 1;
  
  -- Insert PR item
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
    p_shortage_qty, -- SHORTAGE QUANTITY ONLY
    v_mr_item.unit_of_measure,
    v_mr_item.standard_price,
    p_shortage_qty * v_mr_item.standard_price, -- RECALCULATED
    v_mr_header.currency,
    v_mr_header.required_date,
    v_mr_header.plant_code,
    v_storage_location_id,
    CASE WHEN v_mr_header.project_code IS NOT NULL THEN 'P' ELSE 'K' END,
    v_mr_header.project_code,
    v_mr_header.wbs_element,
    v_mr_header.cost_center,
    'OPEN'
  )
  RETURNING id INTO v_pr_item_id;
  
  RETURN v_pr_item_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- USAGE EXAMPLE
-- ============================================================================

/*
-- When stock check shows shortage:
-- MR Item: 100 EA requested, 60 EA available → 40 EA shortage

-- 1. Create Reservation for available stock (60 EA)
INSERT INTO reservation_items (...)
VALUES (..., 60, ...);

-- 2. Create PR for shortage (40 EA)
-- First create PR header
INSERT INTO purchase_requisitions (...)
VALUES (...) RETURNING id INTO v_pr_id;

-- Then convert MR item to PR item with shortage quantity
SELECT convert_mr_item_to_pr_item(
  'mr-item-uuid',
  v_pr_id,
  40.000 -- shortage quantity
);

-- 3. Update MR item with fulfillment tracking
UPDATE material_request_items
SET 
  fulfillment_type = 'PARTIAL_STOCK',
  stock_reserved_qty = 60.000,
  purchase_qty = 40.000,
  reservation_id = v_reservation_id,
  pr_id = v_pr_id
WHERE id = 'mr-item-uuid';
*/

-- ============================================================================
-- VALIDATION QUERIES
-- ============================================================================

-- Check MR to PR traceability
SELECT 
  mr.request_number,
  mri.line_number as mr_line,
  mri.material_code,
  mri.quantity as mr_qty,
  mri.stock_reserved_qty,
  mri.purchase_qty,
  pr.pr_number,
  pri.line_number as pr_line,
  pri.quantity as pr_qty,
  pri.item_status
FROM material_request_items mri
JOIN material_requests mr ON mr.id = mri.material_request_id
LEFT JOIN purchase_requisition_items pri ON pri.mr_item_id = mri.id
LEFT JOIN purchase_requisitions pr ON pr.id = pri.pr_id
WHERE mri.fulfillment_type IN ('PURCHASE', 'PARTIAL_STOCK')
ORDER BY mr.request_number, mri.line_number;
