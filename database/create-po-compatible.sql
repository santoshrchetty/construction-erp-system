-- COMPATIBLE PURCHASE ORDER SCHEMA
-- Works with existing database structure

-- Purchase Orders table
CREATE TABLE IF NOT EXISTS purchase_orders (
    id SERIAL PRIMARY KEY,
    po_number VARCHAR(20) UNIQUE NOT NULL,
    vendor_code VARCHAR(20),
    project_code VARCHAR(20),
    po_date DATE DEFAULT CURRENT_DATE,
    total_amount DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'DRAFT',
    created_by VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Purchase Order Items table
CREATE TABLE IF NOT EXISTS purchase_order_items (
    id SERIAL PRIMARY KEY,
    po_id INTEGER REFERENCES purchase_orders(id),
    material_code VARCHAR(50),
    description TEXT,
    quantity DECIMAL(10,3),
    unit_price DECIMAL(12,2),
    line_total DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add PO Management tile
INSERT INTO tiles (title, route, icon, roles) 
VALUES (
    'Purchase Order Management',
    '/purchase-orders',
    'ShoppingCart',
    ARRAY['ADMIN', 'PROCUREMENT']
);