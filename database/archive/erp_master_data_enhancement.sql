-- ERP Master Data Enhancement
-- Material Master Configuration

-- Material Groups (MATKL)
CREATE TABLE material_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_code VARCHAR(9) UNIQUE NOT NULL,
    group_name VARCHAR(40) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Unit of Measure Groups
CREATE TABLE uom_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    base_uom VARCHAR(3) NOT NULL, -- EA, KG, M, etc.
    uom_name VARCHAR(30) NOT NULL,
    dimension VARCHAR(6), -- LENGTH, WEIGHT, VOLUME, etc.
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE alternative_uoms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    base_uom_id UUID REFERENCES uom_groups(id),
    alt_uom VARCHAR(3) NOT NULL,
    alt_uom_name VARCHAR(30) NOT NULL,
    conversion_factor DECIMAL(13,6) NOT NULL, -- 1 base = X alternative
    is_active BOOLEAN DEFAULT true
);

-- Material Status Configuration
CREATE TABLE material_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    status_code VARCHAR(2) UNIQUE NOT NULL,
    status_name VARCHAR(30) NOT NULL,
    allow_procurement BOOLEAN DEFAULT true,
    allow_consumption BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true
);

-- Vendor Master Configuration
CREATE TABLE vendor_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_code VARCHAR(4) UNIQUE NOT NULL,
    category_name VARCHAR(40) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

-- Payment Terms
CREATE TABLE payment_terms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    term_code VARCHAR(4) UNIQUE NOT NULL,
    term_name VARCHAR(50) NOT NULL,
    net_days INTEGER NOT NULL,
    discount_days INTEGER DEFAULT 0,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true
);

-- Vendor Evaluation Criteria
CREATE TABLE vendor_evaluation_criteria (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    criteria_code VARCHAR(4) UNIQUE NOT NULL,
    criteria_name VARCHAR(40) NOT NULL,
    weight_percentage DECIMAL(5,2) NOT NULL,
    max_score INTEGER DEFAULT 100,
    is_active BOOLEAN DEFAULT true
);

-- Vendor Classification
CREATE TABLE vendor_classifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    classification_code VARCHAR(2) UNIQUE NOT NULL,
    classification_name VARCHAR(30) NOT NULL,
    min_score DECIMAL(5,2) DEFAULT 0,
    max_score DECIMAL(5,2) DEFAULT 100,
    is_active BOOLEAN DEFAULT true
);

-- Procurement Configuration
CREATE TABLE purchase_requisition_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pr_type VARCHAR(4) UNIQUE NOT NULL,
    type_name VARCHAR(40) NOT NULL,
    requires_approval BOOLEAN DEFAULT true,
    auto_convert_po BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true
);

-- Approval Workflows
CREATE TABLE approval_levels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level_code VARCHAR(2) UNIQUE NOT NULL,
    level_name VARCHAR(30) NOT NULL,
    min_amount DECIMAL(15,2) NOT NULL,
    max_amount DECIMAL(15,2),
    approver_role VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true
);

-- Sample Data
INSERT INTO material_groups (group_code, group_name, description) VALUES
('CEMENT', 'Cement & Binding Materials', 'Portland cement, fly ash, admixtures'),
('STEEL', 'Steel & Reinforcement', 'Rebar, structural steel, mesh'),
('AGGR', 'Aggregates', 'Sand, gravel, crushed stone'),
('ELECT', 'Electrical Materials', 'Cables, switches, panels'),
('PLUMB', 'Plumbing Materials', 'Pipes, fittings, fixtures'),
('TOOLS', 'Tools & Equipment', 'Hand tools, power tools, machinery');

INSERT INTO uom_groups (base_uom, uom_name, dimension) VALUES
('EA', 'Each', 'PIECE'),
('KG', 'Kilogram', 'WEIGHT'),
('M', 'Meter', 'LENGTH'),
('M2', 'Square Meter', 'AREA'),
('M3', 'Cubic Meter', 'VOLUME'),
('L', 'Liter', 'VOLUME');

INSERT INTO alternative_uoms (base_uom_id, alt_uom, alt_uom_name, conversion_factor) VALUES
((SELECT id FROM uom_groups WHERE base_uom = 'KG'), 'TON', 'Metric Ton', 0.001),
((SELECT id FROM uom_groups WHERE base_uom = 'M'), 'CM', 'Centimeter', 100),
((SELECT id FROM uom_groups WHERE base_uom = 'M'), 'MM', 'Millimeter', 1000),
((SELECT id FROM uom_groups WHERE base_uom = 'L'), 'ML', 'Milliliter', 1000);

INSERT INTO material_status (status_code, status_name, allow_procurement, allow_consumption) VALUES
('01', 'Active', true, true),
('02', 'Blocked for Procurement', false, true),
('03', 'Blocked for Consumption', true, false),
('04', 'Discontinued', false, false),
('05', 'Under Review', false, false);

INSERT INTO vendor_categories (category_code, category_name, description) VALUES
('MATL', 'Material Supplier', 'Suppliers of construction materials'),
('SERV', 'Service Provider', 'Professional services, consulting'),
('SUBC', 'Subcontractor', 'Specialized construction work'),
('EQUIP', 'Equipment Rental', 'Machinery and equipment rental'),
('UTIL', 'Utilities', 'Power, water, telecommunications');

INSERT INTO payment_terms (term_code, term_name, net_days, discount_days, discount_percent) VALUES
('N30', 'Net 30 Days', 30, 0, 0),
('N15', 'Net 15 Days', 15, 0, 0),
('2N30', '2/10 Net 30', 30, 10, 2.00),
('ADV', 'Advance Payment', 0, 0, 0),
('COD', 'Cash on Delivery', 0, 0, 0);

INSERT INTO vendor_evaluation_criteria (criteria_code, criteria_name, weight_percentage) VALUES
('QUAL', 'Quality Performance', 40.00),
('DELV', 'Delivery Performance', 30.00),
('COST', 'Cost Competitiveness', 20.00),
('SERV', 'Service Level', 10.00);

INSERT INTO vendor_classifications (classification_code, classification_name, min_score, max_score) VALUES
('A', 'Preferred Vendor', 90.00, 100.00),
('B', 'Approved Vendor', 70.00, 89.99),
('C', 'Conditional Vendor', 50.00, 69.99),
('D', 'Restricted Vendor', 0.00, 49.99);

INSERT INTO purchase_requisition_types (pr_type, type_name, requires_approval, auto_convert_po) VALUES
('STD', 'Standard Purchase', true, false),
('URG', 'Urgent Purchase', true, false),
('SRV', 'Service Purchase', true, false),
('SUBC', 'Subcontract Work', true, false),
('CONS', 'Consignment', false, true);

INSERT INTO approval_levels (level_code, level_name, min_amount, max_amount, approver_role) VALUES
('L1', 'Supervisor Approval', 0.00, 10000.00, 'SUPERVISOR'),
('L2', 'Manager Approval', 10000.01, 50000.00, 'MANAGER'),
('L3', 'Director Approval', 50000.01, 200000.00, 'DIRECTOR'),
('L4', 'Executive Approval', 200000.01, NULL, 'EXECUTIVE');

-- Indexes for performance
CREATE INDEX idx_material_groups_code ON material_groups(group_code);
CREATE INDEX idx_vendor_categories_code ON vendor_categories(category_code);
CREATE INDEX idx_payment_terms_code ON payment_terms(term_code);
CREATE INDEX idx_approval_levels_amount ON approval_levels(min_amount, max_amount);