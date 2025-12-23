-- Additional tables for complete Material Management workflow

-- Purchase Requisitions table
CREATE TABLE IF NOT EXISTS purchase_requisitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pr_number VARCHAR(10) UNIQUE NOT NULL,
    pr_date DATE NOT NULL,
    requested_by UUID,
    department VARCHAR(20),
    priority VARCHAR(10) DEFAULT 'NORMAL',
    status VARCHAR(10) DEFAULT 'OPEN',
    total_amount DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Purchase Requisition Items table
CREATE TABLE IF NOT EXISTS purchase_requisition_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pr_id UUID REFERENCES purchase_requisitions(id) ON DELETE CASCADE,
    item_number INTEGER NOT NULL,
    material_id UUID REFERENCES materials(id),
    quantity DECIMAL(13,3) NOT NULL,
    estimated_price DECIMAL(11,2) DEFAULT 0,
    required_date DATE,
    justification TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(pr_id, item_number)
);

-- Goods Receipts table
CREATE TABLE IF NOT EXISTS goods_receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gr_number VARCHAR(10) UNIQUE NOT NULL,
    po_id UUID REFERENCES purchase_orders(id),
    gr_date DATE NOT NULL,
    delivery_note VARCHAR(20),
    received_by UUID,
    total_amount DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(10) DEFAULT 'POSTED',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Goods Receipt Items table
CREATE TABLE IF NOT EXISTS goods_receipt_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gr_id UUID REFERENCES goods_receipts(id) ON DELETE CASCADE,
    po_item_id UUID REFERENCES purchase_order_items(id),
    material_id UUID REFERENCES materials(id),
    quantity_received DECIMAL(13,3) NOT NULL,
    unit_price DECIMAL(11,2) NOT NULL,
    storage_location VARCHAR(4) DEFAULT '0001',
    batch_number VARCHAR(10),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Movement Types reference table
CREATE TABLE IF NOT EXISTS movement_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_type VARCHAR(3) UNIQUE NOT NULL,
    movement_name VARCHAR(40) NOT NULL,
    movement_indicator VARCHAR(1) NOT NULL, -- '+' for receipt, '-' for issue
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert movement types
INSERT INTO movement_types (movement_type, movement_name, movement_indicator, description) VALUES
('101', 'GR for Purchase Order', '+', 'Goods Receipt for Purchase Order'),
('102', 'GR Reversal', '-', 'Goods Receipt Reversal'),
('201', 'Goods Issue to Cost Center', '-', 'Consumption to Cost Center'),
('261', 'Goods Issue to Order', '-', 'Issue to Production Order'),
('262', 'Goods Receipt from Order', '+', 'Receipt from Production Order'),
('301', 'Transfer Posting', '±', 'Stock Transfer Between Locations'),
('501', 'Receipt without PO', '+', 'Free Goods Receipt'),
('502', 'Issue without Order', '-', 'Free Goods Issue')
ON CONFLICT (movement_type) DO NOTHING;

-- Insert sample purchase requisitions
INSERT INTO purchase_requisitions (pr_number, pr_date, department, priority, status) VALUES
('PR-001', CURRENT_DATE, 'CONSTRUCTION', 'HIGH', 'OPEN'),
('PR-002', CURRENT_DATE - 1, 'ELECTRICAL', 'NORMAL', 'APPROVED'),
('PR-003', CURRENT_DATE - 2, 'PLUMBING', 'LOW', 'OPEN')
ON CONFLICT (pr_number) DO NOTHING;

-- Insert sample PR items
INSERT INTO purchase_requisition_items (pr_id, item_number, material_id, quantity, estimated_price, required_date)
SELECT pr.id, 10, m.id, 50.0, 8.50, CURRENT_DATE + 7
FROM purchase_requisitions pr, materials m 
WHERE pr.pr_number = 'PR-001' AND m.material_code = 'MAT-001'
ON CONFLICT (pr_id, item_number) DO NOTHING;

-- Insert sample purchase orders
INSERT INTO purchase_orders (po_number, vendor_id, po_date, delivery_date, total_amount, status)
SELECT 'PO-001', v.id, CURRENT_DATE, CURRENT_DATE + 14, 425.00, 'OPEN'
FROM vendors v WHERE v.vendor_code = 'VEN-001'
ON CONFLICT (po_number) DO NOTHING;

-- Insert sample PO items
INSERT INTO purchase_order_items (po_id, item_number, material_id, quantity, unit_price, total_price, delivery_date)
SELECT po.id, 10, m.id, 50.0, 8.50, 425.00, CURRENT_DATE + 14
FROM purchase_orders po, materials m 
WHERE po.po_number = 'PO-001' AND m.material_code = 'MAT-001'
ON CONFLICT (po_id, item_number) DO NOTHING;