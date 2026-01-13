-- MINIMAL PURCHASE ORDER SCHEMA
-- Works with existing database structure

-- ========================================
-- 1. PURCHASE ORDERS HEADER TABLE
-- ========================================

CREATE TABLE IF NOT EXISTS purchase_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  po_number VARCHAR(20) NOT NULL UNIQUE,
  supplier_id UUID NOT NULL REFERENCES vendors(id),
  project_id UUID REFERENCES projects(id),
  
  -- PO Details
  po_date DATE NOT NULL DEFAULT CURRENT_DATE,
  delivery_date DATE,
  payment_terms VARCHAR(20) DEFAULT 'NET30',
  currency VARCHAR(3) DEFAULT 'INR',
  
  -- Status and Approval
  status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
  approval_status VARCHAR(20) DEFAULT 'PENDING',
  approved_by UUID,
  approved_date TIMESTAMP,
  
  -- Amounts
  subtotal_amount DECIMAL(15,2) DEFAULT 0,
  tax_amount DECIMAL(15,2) DEFAULT 0,
  total_amount DECIMAL(15,2) DEFAULT 0,
  
  -- Additional Info
  remarks TEXT,
  created_by UUID NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 2. PURCHASE ORDER ITEMS TABLE
-- ========================================

CREATE TABLE IF NOT EXISTS purchase_order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  po_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
  line_number INTEGER NOT NULL,
  
  -- Material Details
  material_code VARCHAR(20) NOT NULL,
  material_description VARCHAR(255),
  
  -- Quantity and Pricing
  ordered_quantity DECIMAL(15,3) NOT NULL,
  unit_of_measure VARCHAR(10) NOT NULL,
  unit_price DECIMAL(15,2) NOT NULL,
  line_amount DECIMAL(15,2) NOT NULL,
  
  -- Tax Details
  tax_rate DECIMAL(5,2) DEFAULT 18,
  tax_amount DECIMAL(15,2) DEFAULT 0,
  
  -- Delivery
  delivery_date DATE,
  
  -- Status Tracking
  received_quantity DECIMAL(15,3) DEFAULT 0,
  pending_quantity DECIMAL(15,3) DEFAULT 0,
  item_status VARCHAR(20) DEFAULT 'OPEN',
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(po_id, line_number)
);

-- ========================================
-- 3. PO NUMBER SEQUENCE
-- ========================================

CREATE SEQUENCE IF NOT EXISTS po_number_seq START 1000;

-- ========================================
-- 4. PO NUMBER GENERATION FUNCTION
-- ========================================

CREATE OR REPLACE FUNCTION generate_po_number()
RETURNS VARCHAR(20) AS $$
DECLARE
  v_sequence_number INTEGER;
  v_po_number VARCHAR(20);
BEGIN
  -- Get next sequence number
  SELECT nextval('po_number_seq') INTO v_sequence_number;
  
  -- Format: PO-001000
  v_po_number := 'PO-' || LPAD(v_sequence_number::TEXT, 6, '0');
  
  RETURN v_po_number;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 5. PO TOTAL CALCULATION FUNCTION
-- ========================================

CREATE OR REPLACE FUNCTION calculate_po_totals(p_po_id UUID)
RETURNS VOID AS $$
DECLARE
  v_subtotal DECIMAL(15,2);
  v_tax_total DECIMAL(15,2);
  v_grand_total DECIMAL(15,2);
BEGIN
  -- Calculate totals from line items
  SELECT 
    COALESCE(SUM(line_amount), 0),
    COALESCE(SUM(tax_amount), 0),
    COALESCE(SUM(line_amount + tax_amount), 0)
  INTO v_subtotal, v_tax_total, v_grand_total
  FROM purchase_order_items
  WHERE po_id = p_po_id;
  
  -- Update PO header
  UPDATE purchase_orders 
  SET 
    subtotal_amount = v_subtotal,
    tax_amount = v_tax_total,
    total_amount = v_grand_total,
    updated_at = CURRENT_TIMESTAMP
  WHERE id = p_po_id;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 6. INDEXES
-- ========================================

CREATE INDEX IF NOT EXISTS idx_po_supplier_id ON purchase_orders(supplier_id);
CREATE INDEX IF NOT EXISTS idx_po_status ON purchase_orders(status);
CREATE INDEX IF NOT EXISTS idx_po_items_po_id ON purchase_order_items(po_id);

-- ========================================
-- 7. AUTHORIZATION OBJECTS
-- ========================================

INSERT INTO authorization_objects (object_name, description, module, is_active) VALUES
('PO_CREATE', 'Purchase Order Create', 'MM', true),
('PO_VIEW', 'Purchase Order View', 'MM', true)
ON CONFLICT (object_name) DO NOTHING;

-- ========================================
-- 8. SAMPLE DATA
-- ========================================

INSERT INTO purchase_orders (
  po_number, supplier_id, po_date, status, 
  subtotal_amount, tax_amount, total_amount, created_by
) 
SELECT 
  'PO-001000', v.id, CURRENT_DATE, 'DRAFT',
  50000.00, 9000.00, 59000.00, gen_random_uuid()
FROM vendors v 
WHERE v.vendor_code = 'V001'
LIMIT 1
ON CONFLICT (po_number) DO NOTHING;

SELECT 'MINIMAL PURCHASE ORDER SCHEMA CREATED' as status;