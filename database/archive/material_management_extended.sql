-- Material Management Extended Schema

-- Materials table (actual material records)
CREATE TABLE IF NOT EXISTS materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_code VARCHAR(18) UNIQUE NOT NULL,
    material_name VARCHAR(40) NOT NULL,
    description TEXT,
    material_group_id UUID REFERENCES material_groups(id),
    material_status_id UUID REFERENCES material_status(id),
    base_uom VARCHAR(3) NOT NULL,
    material_type VARCHAR(4) DEFAULT 'ROH',
    standard_price DECIMAL(15,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Vendors table (vendor master data)
CREATE TABLE IF NOT EXISTS vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_code VARCHAR(10) UNIQUE NOT NULL,
    vendor_name VARCHAR(35) NOT NULL,
    vendor_category_id UUID REFERENCES vendor_categories(id),
    payment_terms_id UUID REFERENCES payment_terms(id),
    contact_person VARCHAR(30),
    phone VARCHAR(16),
    email VARCHAR(241),
    address TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Purchase Orders table
CREATE TABLE IF NOT EXISTS purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_number VARCHAR(10) UNIQUE NOT NULL,
    vendor_id UUID REFERENCES vendors(id),
    po_date DATE NOT NULL,
    delivery_date DATE,
    total_amount DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(10) DEFAULT 'OPEN',
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Purchase Order Items table
CREATE TABLE IF NOT EXISTS purchase_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_id UUID REFERENCES purchase_orders(id) ON DELETE CASCADE,
    item_number INTEGER NOT NULL,
    material_id UUID REFERENCES materials(id),
    quantity DECIMAL(13,3) NOT NULL,
    unit_price DECIMAL(11,2) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    delivery_date DATE,
    received_quantity DECIMAL(13,3) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(po_id, item_number)
);

-- Stock Levels table
CREATE TABLE IF NOT EXISTS stock_levels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID REFERENCES materials(id),
    storage_location VARCHAR(4) DEFAULT '0001',
    current_stock DECIMAL(13,3) DEFAULT 0,
    reserved_stock DECIMAL(13,3) DEFAULT 0,
    available_stock DECIMAL(13,3) DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(material_id, storage_location)
);

-- Material Movements table
CREATE TABLE IF NOT EXISTS material_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID REFERENCES materials(id),
    movement_type VARCHAR(3) NOT NULL,
    quantity DECIMAL(13,3) NOT NULL,
    unit_price DECIMAL(11,2) DEFAULT 0,
    storage_location VARCHAR(4) DEFAULT '0001',
    reference_doc VARCHAR(10),
    movement_date DATE NOT NULL,
    posting_date DATE NOT NULL,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Movement Types table
CREATE TABLE IF NOT EXISTS movement_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_type VARCHAR(3) UNIQUE NOT NULL,
    movement_name VARCHAR(40) NOT NULL,
    movement_indicator VARCHAR(1) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- GL Accounts table
CREATE TABLE IF NOT EXISTS gl_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_code VARCHAR(10) UNIQUE NOT NULL,
    account_name VARCHAR(50) NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Valuation Classes table
CREATE TABLE IF NOT EXISTS valuation_classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_code VARCHAR(4) UNIQUE NOT NULL,
    class_name VARCHAR(40) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample materials
INSERT INTO materials (material_code, material_name, description, base_uom, standard_price) VALUES
('MAT-001', 'Portland Cement 50kg', 'Ordinary Portland Cement Type I', 'BAG', 8.50),
('MAT-002', 'Steel Rebar 12mm', '12mm diameter steel reinforcement bar', 'M', 2.75),
('MAT-003', 'Concrete Sand', 'Fine aggregate for concrete mixing', 'M3', 25.00),
('MAT-004', 'Electrical Cable 2.5mm', '2.5mm copper electrical cable', 'M', 1.20),
('MAT-005', 'PVC Pipe 4inch', '4 inch PVC drainage pipe', 'M', 8.90)
ON CONFLICT (material_code) DO NOTHING;

-- Insert sample vendors
INSERT INTO vendors (vendor_code, vendor_name, contact_person, phone, email) VALUES
('VEN-001', 'ABC Construction Supply', 'John Smith', '555-0101', 'john@abcsupply.com'),
('VEN-002', 'Steel Works Ltd', 'Mary Johnson', '555-0102', 'mary@steelworks.com'),
('VEN-003', 'Electrical Solutions', 'Bob Wilson', '555-0103', 'bob@electrical.com'),
('VEN-004', 'Plumbing Pro', 'Sarah Davis', '555-0104', 'sarah@plumbingpro.com'),
('VEN-005', 'Tools & Equipment Co', 'Mike Brown', '555-0105', 'mike@toolsequip.com')
ON CONFLICT (vendor_code) DO NOTHING;

-- Insert sample stock levels
INSERT INTO stock_levels (material_id, current_stock, available_stock) 
SELECT m.id, 100.0, 100.0 
FROM materials m 
ON CONFLICT (material_id, storage_location) DO NOTHING;

-- Insert sample movement types
INSERT INTO movement_types (movement_type, movement_name, movement_indicator, description) VALUES
('101', 'GR from Purchase Order', '+', 'Goods Receipt from Purchase Order'),
('102', 'GR Reversal', '-', 'Goods Receipt Reversal'),
('261', 'Issue to Production', '-', 'Issue to Production Order'),
('262', 'Issue Reversal', '+', 'Issue to Production Reversal'),
('551', 'Transfer Posting', '±', 'Transfer Between Storage Locations'),
('601', 'Initial Stock Entry', '+', 'Initial Stock Entry')
ON CONFLICT (movement_type) DO NOTHING;

-- Insert sample GL accounts
INSERT INTO gl_accounts (account_code, account_name, account_type, description) VALUES
-- ASSETS
('100000', 'Cash and Bank', 'ASSET', 'Cash and Bank Accounts'),
('110000', 'Accounts Receivable', 'ASSET', 'Trade Receivables'),
('120000', 'Retention Receivable', 'ASSET', 'Retention Money Receivable'),
('130000', 'Advances to Suppliers', 'ASSET', 'Advances Paid to Suppliers'),
('140000', 'Raw Materials', 'ASSET', 'Raw Materials Inventory'),
('141000', 'Work in Progress', 'ASSET', 'Work in Progress Inventory'),
('142000', 'Finished Goods', 'ASSET', 'Finished Goods Inventory'),
('150000', 'Plant & Equipment', 'ASSET', 'Plant and Equipment'),
('151000', 'Accumulated Depreciation', 'ASSET', 'Accumulated Depreciation'),
('160000', 'GR/IR Clearing', 'ASSET', 'Goods Receipt/Invoice Receipt Clearing'),
-- LIABILITIES
('200000', 'Accounts Payable', 'LIABILITY', 'Trade Payables'),
('210000', 'Retention Payable', 'LIABILITY', 'Retention Money Payable'),
('220000', 'Advances from Customers', 'LIABILITY', 'Customer Advances Received'),
('230000', 'Accrued Expenses', 'LIABILITY', 'Accrued Expenses'),
('240000', 'Bank Loans', 'LIABILITY', 'Bank Loans and Overdrafts'),
-- REVENUE
('400000', 'Project Revenue', 'REVENUE', 'Construction Project Revenue'),
('410000', 'Variation Revenue', 'REVENUE', 'Project Variation Revenue'),
('420000', 'Retention Revenue', 'REVENUE', 'Retention Revenue'),
('430000', 'Other Revenue', 'REVENUE', 'Other Operating Revenue'),
-- DIRECT COSTS
('500000', 'Material Costs', 'EXPENSE', 'Direct Material Costs'),
('501000', 'Cement & Concrete', 'EXPENSE', 'Cement and Concrete Costs'),
('502000', 'Steel & Reinforcement', 'EXPENSE', 'Steel and Reinforcement Costs'),
('503000', 'Electrical Materials', 'EXPENSE', 'Electrical Materials Costs'),
('504000', 'Plumbing Materials', 'EXPENSE', 'Plumbing Materials Costs'),
('505000', 'Finishing Materials', 'EXPENSE', 'Finishing Materials Costs'),
('510000', 'Labor Costs', 'EXPENSE', 'Direct Labor Costs'),
('511000', 'Skilled Labor', 'EXPENSE', 'Skilled Labor Costs'),
('512000', 'Unskilled Labor', 'EXPENSE', 'Unskilled Labor Costs'),
('513000', 'Overtime Costs', 'EXPENSE', 'Overtime Labor Costs'),
('520000', 'Subcontractor Costs', 'EXPENSE', 'Subcontractor Costs'),
('521000', 'Civil Subcontractors', 'EXPENSE', 'Civil Work Subcontractors'),
('522000', 'MEP Subcontractors', 'EXPENSE', 'MEP Work Subcontractors'),
('523000', 'Finishing Subcontractors', 'EXPENSE', 'Finishing Work Subcontractors'),
('530000', 'Equipment Costs', 'EXPENSE', 'Equipment and Machinery Costs'),
('531000', 'Equipment Rental', 'EXPENSE', 'Equipment Rental Costs'),
('532000', 'Equipment Fuel', 'EXPENSE', 'Equipment Fuel Costs'),
('533000', 'Equipment Maintenance', 'EXPENSE', 'Equipment Maintenance Costs'),
-- INDIRECT COSTS
('600000', 'Site Overhead', 'EXPENSE', 'Site Overhead Costs'),
('601000', 'Site Office Expenses', 'EXPENSE', 'Site Office Running Expenses'),
('602000', 'Site Utilities', 'EXPENSE', 'Site Utilities Costs'),
('603000', 'Site Security', 'EXPENSE', 'Site Security Costs'),
('604000', 'Site Insurance', 'EXPENSE', 'Site Insurance Costs'),
('610000', 'Project Management', 'EXPENSE', 'Project Management Costs'),
('611000', 'Project Staff Salaries', 'EXPENSE', 'Project Staff Salaries'),
('612000', 'Project Consultancy', 'EXPENSE', 'Project Consultancy Fees'),
('620000', 'General Overhead', 'EXPENSE', 'General Administrative Overhead'),
('621000', 'Head Office Expenses', 'EXPENSE', 'Head Office Administrative Costs'),
('622000', 'Marketing Expenses', 'EXPENSE', 'Marketing and Business Development'),
('623000', 'Finance Costs', 'EXPENSE', 'Interest and Finance Charges'),
-- WIP ACCOUNTS
('700000', 'WIP - Materials', 'WIP', 'Work in Progress - Materials'),
('701000', 'WIP - Labor', 'WIP', 'Work in Progress - Labor'),
('702000', 'WIP - Subcontractors', 'WIP', 'Work in Progress - Subcontractors'),
('703000', 'WIP - Equipment', 'WIP', 'Work in Progress - Equipment'),
('704000', 'WIP - Overheads', 'WIP', 'Work in Progress - Overheads'),
-- COST OF SALES
('800000', 'Cost of Sales - Materials', 'COGS', 'Cost of Sales - Materials'),
('801000', 'Cost of Sales - Labor', 'COGS', 'Cost of Sales - Labor'),
('802000', 'Cost of Sales - Subcontractors', 'COGS', 'Cost of Sales - Subcontractors'),
('803000', 'Cost of Sales - Equipment', 'COGS', 'Cost of Sales - Equipment'),
('804000', 'Cost of Sales - Overheads', 'COGS', 'Cost of Sales - Overheads')
ON CONFLICT (account_code) DO NOTHING;

-- Insert sample valuation classes
INSERT INTO valuation_classes (class_code, class_name, description) VALUES
('3000', 'Raw Materials', 'Valuation class for raw materials'),
('7920', 'Finished Products', 'Valuation class for finished products'),
('7900', 'Trading Goods', 'Valuation class for trading goods'),
('9000', 'Services', 'Valuation class for services')
ON CONFLICT (class_code) DO NOTHING;