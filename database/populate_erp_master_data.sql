-- Check if ERP master data tables exist and create them with sample data

-- Create material_groups table if not exists
CREATE TABLE IF NOT EXISTS material_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_code VARCHAR(9) UNIQUE NOT NULL,
    group_name VARCHAR(40) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create vendor_categories table if not exists
CREATE TABLE IF NOT EXISTS vendor_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_code VARCHAR(4) UNIQUE NOT NULL,
    category_name VARCHAR(40) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create payment_terms table if not exists
CREATE TABLE IF NOT EXISTS payment_terms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    term_code VARCHAR(4) UNIQUE NOT NULL,
    term_name VARCHAR(50) NOT NULL,
    net_days INTEGER NOT NULL,
    discount_days INTEGER DEFAULT 0,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create uom_groups table if not exists
CREATE TABLE IF NOT EXISTS uom_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    base_uom VARCHAR(3) UNIQUE NOT NULL,
    uom_name VARCHAR(30) NOT NULL,
    dimension VARCHAR(10),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create material_status table if not exists
CREATE TABLE IF NOT EXISTS material_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    status_code VARCHAR(2) UNIQUE NOT NULL,
    status_name VARCHAR(30) NOT NULL,
    allow_procurement BOOLEAN DEFAULT true,
    allow_consumption BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample data for material_groups
INSERT INTO material_groups (group_code, group_name, description) VALUES
('CEMENT', 'Cement & Binding Materials', 'Portland cement, fly ash, admixtures'),
('STEEL', 'Steel & Reinforcement', 'Rebar, structural steel, mesh'),
('AGGR', 'Aggregates', 'Sand, gravel, crushed stone'),
('ELECT', 'Electrical Materials', 'Cables, switches, panels'),
('PLUMB', 'Plumbing Materials', 'Pipes, fittings, fixtures'),
('TOOLS', 'Tools & Equipment', 'Hand tools, power tools, machinery')
ON CONFLICT (group_code) DO NOTHING;

-- Insert sample data for vendor_categories
INSERT INTO vendor_categories (category_code, category_name, description) VALUES
('MATL', 'Material Supplier', 'Suppliers of construction materials'),
('SERV', 'Service Provider', 'Professional services, consulting'),
('SUBC', 'Subcontractor', 'Specialized construction work'),
('EQUP', 'Equipment Rental', 'Machinery and equipment rental'),
('UTIL', 'Utilities', 'Power, water, telecommunications')
ON CONFLICT (category_code) DO NOTHING;

-- Insert sample data for payment_terms
INSERT INTO payment_terms (term_code, term_name, net_days, discount_days, discount_percent) VALUES
('N30', 'Net 30 Days', 30, 0, 0),
('N15', 'Net 15 Days', 15, 0, 0),
('210N', '2/10 Net 30', 30, 10, 2.00),
('ADV', 'Advance Payment', 0, 0, 0),
('COD', 'Cash on Delivery', 0, 0, 0)
ON CONFLICT (term_code) DO NOTHING;

-- Insert sample data for uom_groups
INSERT INTO uom_groups (base_uom, uom_name, dimension) VALUES
('EA', 'Each', 'PIECE'),
('KG', 'Kilogram', 'WEIGHT'),
('M', 'Meter', 'LENGTH'),
('M2', 'Square Meter', 'AREA'),
('M3', 'Cubic Meter', 'VOLUME'),
('L', 'Liter', 'VOLUME')
ON CONFLICT (base_uom) DO NOTHING;

-- Insert sample data for material_status
INSERT INTO material_status (status_code, status_name, allow_procurement, allow_consumption) VALUES
('01', 'Active', true, true),
('02', 'Blocked for Procurement', false, true),
('03', 'Blocked for Consumption', true, false),
('04', 'Discontinued', false, false),
('05', 'Under Review', false, false)
ON CONFLICT (status_code) DO NOTHING;