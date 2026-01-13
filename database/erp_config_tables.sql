-- ERP Configuration Tables
-- Add missing tables for ERP Configuration module

-- Material Groups
CREATE TABLE IF NOT EXISTS material_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_code VARCHAR(10) UNIQUE NOT NULL,
    group_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Vendor Categories
CREATE TABLE IF NOT EXISTS vendor_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_code VARCHAR(10) UNIQUE NOT NULL,
    category_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payment Terms
CREATE TABLE IF NOT EXISTS payment_terms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    term_code VARCHAR(10) UNIQUE NOT NULL,
    term_name VARCHAR(255) NOT NULL,
    net_days INTEGER NOT NULL,
    discount_days INTEGER DEFAULT 0,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- UOM Groups
CREATE TABLE IF NOT EXISTS uom_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    base_uom VARCHAR(10) UNIQUE NOT NULL,
    uom_name VARCHAR(255) NOT NULL,
    dimension VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Material Status
CREATE TABLE IF NOT EXISTS material_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    status_code VARCHAR(10) UNIQUE NOT NULL,
    status_name VARCHAR(255) NOT NULL,
    allow_procurement BOOLEAN DEFAULT true,
    allow_consumption BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Valuation Classes
CREATE TABLE IF NOT EXISTS valuation_classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_code VARCHAR(10) UNIQUE NOT NULL,
    class_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Movement Types
CREATE TABLE IF NOT EXISTS movement_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_type VARCHAR(10) UNIQUE NOT NULL,
    movement_name VARCHAR(255) NOT NULL,
    movement_indicator VARCHAR(1) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Account Keys
CREATE TABLE IF NOT EXISTS account_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_key_code VARCHAR(10) UNIQUE NOT NULL,
    account_key_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Account Determination
CREATE TABLE IF NOT EXISTS account_determination (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    valuation_class_id UUID NOT NULL REFERENCES valuation_classes(id),
    account_key_id UUID NOT NULL REFERENCES account_keys(id),
    gl_account_id UUID NOT NULL REFERENCES chart_of_accounts(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(company_code_id, valuation_class_id, account_key_id)
);

-- Insert sample data
INSERT INTO material_groups (group_code, group_name, description) VALUES
('CEMENT', 'Cement Products', 'All cement related materials'),
('STEEL', 'Steel Products', 'Steel bars, sheets, structures'),
('AGGREGATE', 'Aggregates', 'Sand, gravel, crushed stone')
ON CONFLICT (group_code) DO NOTHING;

INSERT INTO vendor_categories (category_code, category_name, description) VALUES
('SUPPLIER', 'Material Supplier', 'Suppliers of construction materials'),
('SUBCON', 'Subcontractor', 'Construction subcontractors')
ON CONFLICT (category_code) DO NOTHING;

INSERT INTO payment_terms (term_code, term_name, net_days) VALUES
('NET30', 'Net 30 Days', 30),
('NET15', 'Net 15 Days', 15)
ON CONFLICT (term_code) DO NOTHING;

INSERT INTO uom_groups (base_uom, uom_name, dimension) VALUES
('KG', 'Kilogram', 'WEIGHT'),
('M', 'Meter', 'LENGTH'),
('M3', 'Cubic Meter', 'VOLUME')
ON CONFLICT (base_uom) DO NOTHING;

INSERT INTO material_status (status_code, status_name, allow_procurement, allow_consumption) VALUES
('ACTIVE', 'Active', true, true),
('BLOCKED', 'Blocked', false, false)
ON CONFLICT (status_code) DO NOTHING;

INSERT INTO valuation_classes (class_code, class_name, description) VALUES
('MAT001', 'Raw Materials', 'Raw construction materials'),
('MAT002', 'Finished Goods', 'Finished construction products')
ON CONFLICT (class_code) DO NOTHING;

INSERT INTO movement_types (movement_type, movement_name, movement_indicator, description) VALUES
('101', 'Goods Receipt', '+', 'Receipt of goods'),
('201', 'Goods Issue', '-', 'Issue of goods')
ON CONFLICT (movement_type) DO NOTHING;

INSERT INTO account_keys (account_key_code, account_key_name, description) VALUES
('BSX', 'Stock Account', 'Inventory stock account'),
('GBB', 'Stock Offset', 'Inventory offset account')
ON CONFLICT (account_key_code) DO NOTHING;