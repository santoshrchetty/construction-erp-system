-- STEP 1: FIX PO SCHEMA DATA TYPE COMPATIBILITY

-- First, add missing fields to purchase_orders (without foreign key issues)
ALTER TABLE purchase_orders 
ADD COLUMN IF NOT EXISTS delivery_date DATE,
ADD COLUMN IF NOT EXISTS payment_terms VARCHAR(50) DEFAULT 'NET30',
ADD COLUMN IF NOT EXISTS tax_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS net_amount DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'INR',
ADD COLUMN IF NOT EXISTS delivery_address TEXT,
ADD COLUMN IF NOT EXISTS terms_conditions TEXT,
ADD COLUMN IF NOT EXISTS remarks TEXT,
ADD COLUMN IF NOT EXISTS approved_by VARCHAR(50),
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS priority VARCHAR(10) DEFAULT 'NORMAL',
ADD COLUMN IF NOT EXISTS department VARCHAR(50),
ADD COLUMN IF NOT EXISTS cost_center VARCHAR(20),
ADD COLUMN IF NOT EXISTS budget_code VARCHAR(20);

-- Add missing fields to purchase_order_items
ALTER TABLE purchase_order_items
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

-- Create supporting tables without foreign key constraints (use po_number instead)
CREATE TABLE IF NOT EXISTS goods_receipts (
    id SERIAL PRIMARY KEY,
    gr_number VARCHAR(20) UNIQUE,
    po_number VARCHAR(20),
    vendor_code VARCHAR(20),
    gr_date DATE DEFAULT CURRENT_DATE,
    delivery_note VARCHAR(50),
    total_amount DECIMAL(15,2),
    status VARCHAR(20) DEFAULT 'POSTED',
    created_by VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS material_price_history (
    id SERIAL PRIMARY KEY,
    material_code VARCHAR(50),
    vendor_code VARCHAR(20),
    price DECIMAL(12,2),
    unit VARCHAR(10),
    valid_from DATE,
    valid_to DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add basic indexes
CREATE INDEX IF NOT EXISTS idx_po_vendor ON purchase_orders(vendor_code);
CREATE INDEX IF NOT EXISTS idx_po_project ON purchase_orders(project_code);
CREATE INDEX IF NOT EXISTS idx_po_status ON purchase_orders(status);

SELECT 'STEP 1 COMPLETE - BASIC PO SCHEMA ENHANCED' as status;