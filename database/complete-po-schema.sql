-- COMPLETE PURCHASE ORDER SCHEMA WITH ALL FUNCTIONALITIES

-- Enhanced Purchase Orders table with all fields
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
ADD COLUMN IF NOT EXISTS revision_number INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS original_po_id INTEGER,
ADD COLUMN IF NOT EXISTS priority VARCHAR(10) DEFAULT 'NORMAL',
ADD COLUMN IF NOT EXISTS department VARCHAR(50),
ADD COLUMN IF NOT EXISTS cost_center VARCHAR(20),
ADD COLUMN IF NOT EXISTS budget_code VARCHAR(20);

-- Enhanced Purchase Order Items table
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
ADD COLUMN IF NOT EXISTS asset_number VARCHAR(20),
ADD COLUMN IF NOT EXISTS received_quantity DECIMAL(10,3) DEFAULT 0,
ADD COLUMN IF NOT EXISTS invoiced_quantity DECIMAL(10,3) DEFAULT 0,
ADD COLUMN IF NOT EXISTS item_status VARCHAR(20) DEFAULT 'OPEN';

-- PO Approval Workflow table
CREATE TABLE IF NOT EXISTS po_approvals (
    id SERIAL PRIMARY KEY,
    po_id INTEGER REFERENCES purchase_orders(id),
    approver_level INTEGER,
    approver_id VARCHAR(50),
    approval_status VARCHAR(20) DEFAULT 'PENDING',
    approved_at TIMESTAMP,
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- PO Revision History table
CREATE TABLE IF NOT EXISTS po_revisions (
    id SERIAL PRIMARY KEY,
    po_id INTEGER REFERENCES purchase_orders(id),
    revision_number INTEGER,
    changed_by VARCHAR(50),
    change_reason TEXT,
    old_values JSONB,
    new_values JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Goods Receipt table
CREATE TABLE IF NOT EXISTS goods_receipts (
    id SERIAL PRIMARY KEY,
    gr_number VARCHAR(20) UNIQUE,
    po_id INTEGER REFERENCES purchase_orders(id),
    vendor_code VARCHAR(20),
    gr_date DATE DEFAULT CURRENT_DATE,
    delivery_note VARCHAR(50),
    total_amount DECIMAL(15,2),
    status VARCHAR(20) DEFAULT 'POSTED',
    created_by VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Goods Receipt Items table
CREATE TABLE IF NOT EXISTS goods_receipt_items (
    id SERIAL PRIMARY KEY,
    gr_id INTEGER REFERENCES goods_receipts(id),
    po_item_id INTEGER REFERENCES purchase_order_items(id),
    material_code VARCHAR(50),
    received_quantity DECIMAL(10,3),
    unit VARCHAR(10),
    unit_price DECIMAL(12,2),
    line_total DECIMAL(15,2),
    storage_location VARCHAR(10),
    batch_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Invoice Verification table
CREATE TABLE IF NOT EXISTS invoice_verification (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(20),
    po_id INTEGER REFERENCES purchase_orders(id),
    gr_id INTEGER REFERENCES goods_receipts(id),
    vendor_code VARCHAR(20),
    invoice_date DATE,
    invoice_amount DECIMAL(15,2),
    tax_amount DECIMAL(15,2),
    verification_status VARCHAR(20) DEFAULT 'PENDING',
    verified_by VARCHAR(50),
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- PO Budget Control table
CREATE TABLE IF NOT EXISTS po_budget_control (
    id SERIAL PRIMARY KEY,
    po_id INTEGER REFERENCES purchase_orders(id),
    budget_code VARCHAR(20),
    budget_amount DECIMAL(15,2),
    committed_amount DECIMAL(15,2),
    available_amount DECIMAL(15,2),
    check_status VARCHAR(20) DEFAULT 'PASSED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Material Price History table
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

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_po_vendor ON purchase_orders(vendor_code);
CREATE INDEX IF NOT EXISTS idx_po_project ON purchase_orders(project_code);
CREATE INDEX IF NOT EXISTS idx_po_status ON purchase_orders(status);
CREATE INDEX IF NOT EXISTS idx_po_date ON purchase_orders(po_date);
CREATE INDEX IF NOT EXISTS idx_poi_material ON purchase_order_items(material_code);
CREATE INDEX IF NOT EXISTS idx_gr_po ON goods_receipts(po_id);

SELECT 'COMPLETE PO SCHEMA CREATED' as status;