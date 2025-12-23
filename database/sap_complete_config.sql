-- Complete SAP Configuration for Construction ERP
-- Organizational Structure across all modules

-- =====================================================
-- FINANCE (FI) ORGANIZATIONAL UNITS
-- =====================================================

-- Controlling Areas (CO)
CREATE TABLE controlling_areas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cocarea_code VARCHAR(4) UNIQUE NOT NULL, -- 1000, 2000
    cocarea_name VARCHAR(255) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    fiscal_year_variant VARCHAR(2) DEFAULT 'K4',
    is_active BOOLEAN DEFAULT true
);

-- Business Areas (Cross-company reporting)
CREATE TABLE business_areas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_area_code VARCHAR(4) UNIQUE NOT NULL, -- 1000, 2000
    business_area_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

-- Cost Centers
CREATE TABLE cost_centers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    controlling_area_id UUID NOT NULL REFERENCES controlling_areas(id),
    cost_center_code VARCHAR(10) UNIQUE NOT NULL, -- CC001, CC002
    cost_center_name VARCHAR(255) NOT NULL,
    cost_center_category VARCHAR(1) DEFAULT 'A', -- A=Actual, P=Plan, S=Statistical
    responsible_person VARCHAR(255),
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE DEFAULT '9999-12-31',
    is_active BOOLEAN DEFAULT true
);

-- Profit Centers
CREATE TABLE profit_centers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    controlling_area_id UUID NOT NULL REFERENCES controlling_areas(id),
    profit_center_code VARCHAR(10) UNIQUE NOT NULL, -- PC001, PC002
    profit_center_name VARCHAR(255) NOT NULL,
    profit_center_group VARCHAR(10),
    responsible_person VARCHAR(255),
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE DEFAULT '9999-12-31',
    is_active BOOLEAN DEFAULT true
);

-- =====================================================
-- LOGISTICS (MM/WM) ORGANIZATIONAL UNITS
-- =====================================================

-- Warehouse Numbers (WM)
CREATE TABLE warehouses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plant_id UUID NOT NULL REFERENCES plants(id),
    warehouse_number VARCHAR(3) UNIQUE NOT NULL, -- 001, 002
    warehouse_name VARCHAR(255) NOT NULL,
    warehouse_type VARCHAR(20) DEFAULT 'STANDARD', -- STANDARD, HAZMAT, COLD
    is_active BOOLEAN DEFAULT true
);

-- Storage Types within Warehouses
CREATE TABLE storage_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    storage_type_code VARCHAR(3) NOT NULL, -- 001, 002, 999
    storage_type_name VARCHAR(255) NOT NULL,
    storage_class VARCHAR(20) DEFAULT 'BULK', -- BULK, RACK, FLOOR
    UNIQUE(warehouse_id, storage_type_code)
);

-- Purchasing Groups (Buyer Groups)
CREATE TABLE purchasing_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    purchasing_org_id UUID NOT NULL REFERENCES purchasing_organizations(id),
    pgroup_code VARCHAR(3) UNIQUE NOT NULL, -- 001, 002
    pgroup_name VARCHAR(255) NOT NULL,
    buyer_name VARCHAR(255),
    phone VARCHAR(50),
    email VARCHAR(255),
    is_active BOOLEAN DEFAULT true
);

-- =====================================================
-- SALES & DISTRIBUTION (SD) ORGANIZATIONAL UNITS
-- =====================================================

-- Sales Organizations
CREATE TABLE sales_organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    sales_org_code VARCHAR(4) UNIQUE NOT NULL, -- 1000, 2000
    sales_org_name VARCHAR(255) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    is_active BOOLEAN DEFAULT true
);

-- Distribution Channels
CREATE TABLE distribution_channels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dist_channel_code VARCHAR(2) UNIQUE NOT NULL, -- 01, 02
    dist_channel_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

-- Divisions (Product Groups)
CREATE TABLE divisions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    division_code VARCHAR(2) UNIQUE NOT NULL, -- 01, 02
    division_name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

-- =====================================================
-- PROJECT SYSTEM (PS) ORGANIZATIONAL UNITS
-- =====================================================

-- Project Profiles (Templates)
CREATE TABLE project_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_code VARCHAR(8) UNIQUE NOT NULL, -- CONST001, INFRA001
    profile_name VARCHAR(255) NOT NULL,
    project_type VARCHAR(20) NOT NULL,
    wbs_numbering_scheme VARCHAR(20) DEFAULT 'HIERARCHICAL',
    activity_numbering_scheme VARCHAR(20) DEFAULT 'SEQUENTIAL',
    default_currency VARCHAR(3) DEFAULT 'INR',
    is_active BOOLEAN DEFAULT true
);

-- Work Centers (Resource Centers)
CREATE TABLE work_centers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plant_id UUID NOT NULL REFERENCES plants(id),
    work_center_code VARCHAR(8) UNIQUE NOT NULL, -- WC001, WC002
    work_center_name VARCHAR(255) NOT NULL,
    work_center_category VARCHAR(1) DEFAULT 'A', -- A=Machine, P=Person, T=Tool
    capacity_per_day DECIMAL(8,2) DEFAULT 8.0,
    cost_center_id UUID REFERENCES cost_centers(id),
    is_active BOOLEAN DEFAULT true
);

-- =====================================================
-- ORGANIZATIONAL ASSIGNMENTS
-- =====================================================

-- Company Code to Controlling Area Assignment
CREATE TABLE company_controlling_assignment (
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    controlling_area_id UUID NOT NULL REFERENCES controlling_areas(id),
    PRIMARY KEY (company_code_id, controlling_area_id)
);

-- Plant to Company Code Assignment (already exists in plants table)
-- Sales Org to Distribution Channel to Division Assignment
CREATE TABLE sales_org_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sales_org_id UUID NOT NULL REFERENCES sales_organizations(id),
    dist_channel_id UUID NOT NULL REFERENCES distribution_channels(id),
    division_id UUID NOT NULL REFERENCES divisions(id),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(sales_org_id, dist_channel_id, division_id)
);

-- Update projects table with complete organizational assignment
ALTER TABLE projects 
ADD COLUMN IF NOT EXISTS controlling_area_id UUID REFERENCES controlling_areas(id),
ADD COLUMN IF NOT EXISTS business_area_id UUID REFERENCES business_areas(id),
ADD COLUMN IF NOT EXISTS cost_center_id UUID REFERENCES cost_centers(id),
ADD COLUMN IF NOT EXISTS profit_center_id UUID REFERENCES profit_centers(id),
ADD COLUMN IF NOT EXISTS project_profile_id UUID REFERENCES project_profiles(id),
ADD COLUMN IF NOT EXISTS sales_org_id UUID REFERENCES sales_organizations(id),
ADD COLUMN IF NOT EXISTS dist_channel_id UUID REFERENCES distribution_channels(id),
ADD COLUMN IF NOT EXISTS division_id UUID REFERENCES divisions(id);

-- =====================================================
-- SAMPLE CONFIGURATION DATA
-- =====================================================

-- Controlling Areas
INSERT INTO controlling_areas (cocarea_code, cocarea_name) VALUES
('1000', 'ABC Construction Group Controlling'),
('2000', 'ABC Infrastructure Controlling');

-- Business Areas
INSERT INTO business_areas (business_area_code, business_area_name) VALUES
('1000', 'Construction Projects'),
('2000', 'Infrastructure Projects'),
('3000', 'MEP Services'),
('4000', 'Equipment Rental');

-- Cost Centers
INSERT INTO cost_centers (company_code_id, controlling_area_id, cost_center_code, cost_center_name) VALUES
((SELECT id FROM company_codes WHERE company_code = 'C001'), (SELECT id FROM controlling_areas WHERE cocarea_code = '1000'), 'CC001', 'Project Management'),
((SELECT id FROM company_codes WHERE company_code = 'C001'), (SELECT id FROM controlling_areas WHERE cocarea_code = '1000'), 'CC002', 'Site Operations'),
((SELECT id FROM company_codes WHERE company_code = 'C001'), (SELECT id FROM controlling_areas WHERE cocarea_code = '1000'), 'CC003', 'Quality Control'),
((SELECT id FROM company_codes WHERE company_code = 'C002'), (SELECT id FROM controlling_areas WHERE cocarea_code = '2000'), 'CC101', 'Infrastructure PM'),
((SELECT id FROM company_codes WHERE company_code = 'C003'), (SELECT id FROM controlling_areas WHERE cocarea_code = '1000'), 'CC201', 'MEP Operations');

-- Profit Centers
INSERT INTO profit_centers (controlling_area_id, profit_center_code, profit_center_name) VALUES
((SELECT id FROM controlling_areas WHERE cocarea_code = '1000'), 'PC001', 'Residential Projects'),
((SELECT id FROM controlling_areas WHERE cocarea_code = '1000'), 'PC002', 'Commercial Projects'),
((SELECT id FROM controlling_areas WHERE cocarea_code = '2000'), 'PC101', 'Roads & Highways'),
((SELECT id FROM controlling_areas WHERE cocarea_code = '2000'), 'PC102', 'Bridges & Structures');

-- Purchasing Groups
INSERT INTO purchasing_groups (purchasing_org_id, pgroup_code, pgroup_name, buyer_name) VALUES
((SELECT id FROM purchasing_organizations WHERE porg_code = 'PO01'), '001', 'Construction Materials', 'Materials Buyer'),
((SELECT id FROM purchasing_organizations WHERE porg_code = 'PO01'), '002', 'Equipment & Tools', 'Equipment Buyer'),
((SELECT id FROM purchasing_organizations WHERE porg_code = 'PO02'), '003', 'Services & Subcontracts', 'Services Buyer');

-- Sales Organizations
INSERT INTO sales_organizations (company_code_id, sales_org_code, sales_org_name) VALUES
((SELECT id FROM company_codes WHERE company_code = 'C001'), '1000', 'ABC Construction Sales'),
((SELECT id FROM company_codes WHERE company_code = 'C002'), '2000', 'ABC Infrastructure Sales');

-- Distribution Channels
INSERT INTO distribution_channels (dist_channel_code, dist_channel_name) VALUES
('01', 'Direct Sales'),
('02', 'Partner Channel'),
('03', 'Government Tenders');

-- Divisions
INSERT INTO divisions (division_code, division_name) VALUES
('01', 'Building Construction'),
('02', 'Infrastructure'),
('03', 'MEP Services'),
('04', 'Equipment Rental');

-- Project Profiles
INSERT INTO project_profiles (profile_code, profile_name, project_type) VALUES
('CONST001', 'Standard Construction Project', 'commercial'),
('INFRA001', 'Infrastructure Project', 'infrastructure'),
('RESID001', 'Residential Project', 'residential'),
('INDUS001', 'Industrial Project', 'industrial');

-- Company to Controlling Area Assignments
INSERT INTO company_controlling_assignment (company_code_id, controlling_area_id) VALUES
((SELECT id FROM company_codes WHERE company_code = 'C001'), (SELECT id FROM controlling_areas WHERE cocarea_code = '1000')),
((SELECT id FROM company_codes WHERE company_code = 'C002'), (SELECT id FROM controlling_areas WHERE cocarea_code = '2000')),
((SELECT id FROM company_codes WHERE company_code = 'C003'), (SELECT id FROM controlling_areas WHERE cocarea_code = '1000')),
((SELECT id FROM company_codes WHERE company_code = 'C004'), (SELECT id FROM controlling_areas WHERE cocarea_code = '1000'));

-- Indexes for performance
CREATE INDEX idx_cost_centers_company ON cost_centers(company_code_id);
CREATE INDEX idx_profit_centers_controlling ON profit_centers(controlling_area_id);
CREATE INDEX idx_purchasing_groups_org ON purchasing_groups(purchasing_org_id);
CREATE INDEX idx_projects_controlling_area ON projects(controlling_area_id);
CREATE INDEX idx_projects_cost_center ON projects(cost_center_id);
CREATE INDEX idx_projects_profit_center ON projects(profit_center_id);