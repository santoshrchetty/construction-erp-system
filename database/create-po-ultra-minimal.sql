-- ULTRA-MINIMAL PURCHASE ORDER SCHEMA
-- No foreign key dependencies to avoid column issues

-- ========================================
-- 1. PURCHASE ORDERS TABLE
-- ========================================

CREATE TABLE IF NOT EXISTS purchase_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  po_number VARCHAR(20) NOT NULL UNIQUE,
  vendor_id UUID NOT NULL,
  vendor_name VARCHAR(255),
  
  -- PO Details
  po_date DATE NOT NULL DEFAULT CURRENT_DATE,
  delivery_date DATE,
  payment_terms VARCHAR(20) DEFAULT 'NET30',
  
  -- Status
  status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
  
  -- Amounts
  subtotal_amount DECIMAL(15,2) DEFAULT 0,
  tax_amount DECIMAL(15,2) DEFAULT 0,
  total_amount DECIMAL(15,2) DEFAULT 0,
  
  -- Additional Info
  remarks TEXT,
  created_by UUID NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
  
  -- Tax
  tax_rate DECIMAL(5,2) DEFAULT 18,
  tax_amount DECIMAL(15,2) DEFAULT 0,
  
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
BEGIN
  SELECT nextval('po_number_seq') INTO v_sequence_number;
  RETURN 'PO-' || LPAD(v_sequence_number::TEXT, 6, '0');
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 5. SAMPLE DATA
-- ========================================

INSERT INTO purchase_orders (
  po_number, vendor_id, po_date, status, 
  subtotal_amount, tax_amount, total_amount, created_by
) VALUES (
  'PO-001000', gen_random_uuid(), CURRENT_DATE, 'DRAFT',
  50000.00, 9000.00, 59000.00, gen_random_uuid()
) ON CONFLICT (po_number) DO NOTHING;

SELECT 'ULTRA-MINIMAL PO SCHEMA CREATED' as status;