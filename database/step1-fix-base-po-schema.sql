-- STEP 1: FIX BASE PO SCHEMA ISSUES

-- Add missing base columns to purchase_orders table
ALTER TABLE purchase_orders 
ADD COLUMN IF NOT EXISTS po_number VARCHAR(20) UNIQUE,
ADD COLUMN IF NOT EXISTS po_date DATE DEFAULT CURRENT_DATE,
ADD COLUMN IF NOT EXISTS vendor_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS project_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'DRAFT',
ADD COLUMN IF NOT EXISTS delivery_date DATE,
ADD COLUMN IF NOT EXISTS payment_terms VARCHAR(50) DEFAULT 'NET30',
ADD COLUMN IF NOT EXISTS tax_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS net_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'INR',
ADD COLUMN IF NOT EXISTS delivery_address TEXT,
ADD COLUMN IF NOT EXISTS terms_conditions TEXT,
ADD COLUMN IF NOT EXISTS remarks TEXT,
ADD COLUMN IF NOT EXISTS priority VARCHAR(10) DEFAULT 'NORMAL',
ADD COLUMN IF NOT EXISTS department VARCHAR(50),
ADD COLUMN IF NOT EXISTS cost_center VARCHAR(20),
ADD COLUMN IF NOT EXISTS budget_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS created_by VARCHAR(50),
ADD COLUMN IF NOT EXISTS approved_by VARCHAR(50),
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP;

-- Add missing fields to purchase_order_items table
ALTER TABLE purchase_order_items
ADD COLUMN IF NOT EXISTS material_code VARCHAR(50),
ADD COLUMN IF NOT EXISTS unit VARCHAR(10) DEFAULT 'EA',
ADD COLUMN IF NOT EXISTS tax_code VARCHAR(10) DEFAULT 'GST18',
ADD COLUMN IF NOT EXISTS tax_rate DECIMAL(5,2) DEFAULT 18.00,
ADD COLUMN IF NOT EXISTS tax_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS discount_percent DECIMAL(5,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS net_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS delivery_date DATE,
ADD COLUMN IF NOT EXISTS plant_code VARCHAR(10),
ADD COLUMN IF NOT EXISTS storage_location VARCHAR(10),
ADD COLUMN IF NOT EXISTS gl_account VARCHAR(20),
ADD COLUMN IF NOT EXISTS cost_center VARCHAR(20),
ADD COLUMN IF NOT EXISTS wbs_element VARCHAR(20),
ADD COLUMN IF NOT EXISTS received_quantity DECIMAL(10,3) DEFAULT 0,
ADD COLUMN IF NOT EXISTS invoiced_quantity DECIMAL(10,3) DEFAULT 0,
ADD COLUMN IF NOT EXISTS item_status VARCHAR(20) DEFAULT 'OPEN';

-- Create supporting tables using po_number (VARCHAR) instead of id (UUID) to avoid foreign key issues
CREATE TABLE IF NOT EXISTS goods_receipts (
    id SERIAL PRIMARY KEY,
    gr_number VARCHAR(20) UNIQUE NOT NULL,
    po_number VARCHAR(20) NOT NULL,
    vendor_code VARCHAR(20),
    gr_date DATE DEFAULT CURRENT_DATE,
    delivery_note VARCHAR(50),
    total_amount DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'POSTED',
    created_by VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS goods_receipt_items (
    id SERIAL PRIMARY KEY,
    gr_number VARCHAR(20) NOT NULL,
    po_number VARCHAR(20) NOT NULL,
    po_item_line INTEGER NOT NULL,
    material_code VARCHAR(50),
    received_quantity DECIMAL(10,3),
    unit VARCHAR(10),
    unit_price DECIMAL(12,2),
    line_total DECIMAL(15,2),
    storage_location VARCHAR(10),
    batch_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS material_price_history (
    id SERIAL PRIMARY KEY,
    material_code VARCHAR(50),
    vendor_code VARCHAR(20),
    price DECIMAL(12,2),
    unit VARCHAR(10),
    currency VARCHAR(3) DEFAULT 'INR',
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE DEFAULT '9999-12-31',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create PO number sequence function (simplified)
CREATE OR REPLACE FUNCTION generate_po_number() 
RETURNS VARCHAR(20) AS $$
DECLARE
    next_num INTEGER;
    po_number VARCHAR(20);
BEGIN
    -- Simple sequence number
    SELECT COALESCE(COUNT(*), 0) + 1 INTO next_num FROM purchase_orders;
    
    -- Format: POYYMMNNNN (e.g., PO26010001)
    po_number := 'PO' || TO_CHAR(CURRENT_DATE, 'YY') || TO_CHAR(CURRENT_DATE, 'MM') || LPAD(next_num::TEXT, 4, '0');
    
    RETURN po_number;
END;
$$ LANGUAGE plpgsql;

-- Add indexes for performance (only for columns that exist)
CREATE INDEX IF NOT EXISTS idx_po_vendor ON purchase_orders(vendor_code);
CREATE INDEX IF NOT EXISTS idx_po_project ON purchase_orders(project_code);
CREATE INDEX IF NOT EXISTS idx_po_status ON purchase_orders(status);
CREATE INDEX IF NOT EXISTS idx_po_date ON purchase_orders(po_date);
CREATE INDEX IF NOT EXISTS idx_poi_material ON purchase_order_items(material_code);
CREATE INDEX IF NOT EXISTS idx_gr_po ON goods_receipts(po_number);
CREATE INDEX IF NOT EXISTS idx_gri_po ON goods_receipt_items(po_number);

-- Update existing PO records (only if po_number column exists and is empty)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'purchase_orders' AND column_name = 'po_number') THEN
        UPDATE purchase_orders 
        SET po_number = generate_po_number() 
        WHERE po_number IS NULL OR po_number = '';
    END IF;
END $$;

-- Add constraints
ALTER TABLE purchase_orders 
ADD CONSTRAINT chk_po_status CHECK (status IN ('DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'SENT', 'RECEIVED', 'CLOSED')),
ADD CONSTRAINT chk_po_priority CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
ADD CONSTRAINT chk_po_currency CHECK (currency IN ('INR', 'USD', 'EUR'));

ALTER TABLE purchase_order_items
ADD CONSTRAINT chk_poi_status CHECK (item_status IN ('OPEN', 'PARTIALLY_RECEIVED', 'FULLY_RECEIVED', 'CLOSED', 'CANCELLED'));

SELECT 'STEP 1 COMPLETE - BASE PO SCHEMA FIXED' as status;