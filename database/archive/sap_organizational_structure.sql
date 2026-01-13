-- SAP-Style Organizational Structure for Construction Group
-- Multi-company support with sister companies

-- Company Codes (Legal Entities)
CREATE TABLE company_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code VARCHAR(4) UNIQUE NOT NULL, -- C001, C002, C003
    company_name VARCHAR(255) NOT NULL,
    legal_entity_name VARCHAR(255) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    country VARCHAR(2) DEFAULT 'IN',
    address TEXT,
    tax_number VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Purchasing Organizations (Procurement Authority)
CREATE TABLE purchasing_organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    porg_code VARCHAR(4) UNIQUE NOT NULL, -- PO01, PO02
    porg_name VARCHAR(255) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    is_active BOOLEAN DEFAULT true
);

-- Plants (Project Sites + Central Locations)
CREATE TABLE plants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    plant_code VARCHAR(4) UNIQUE NOT NULL, -- P001, P002
    plant_name VARCHAR(255) NOT NULL,
    plant_type VARCHAR(20) DEFAULT 'PROJECT', -- PROJECT, WAREHOUSE, OFFICE
    address TEXT,
    project_id UUID REFERENCES projects(id), -- Link to project if project plant
    is_active BOOLEAN DEFAULT true
);

-- Storage Locations within Plants
CREATE TABLE storage_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plant_id UUID NOT NULL REFERENCES plants(id),
    sloc_code VARCHAR(4) NOT NULL, -- 0001, 0002
    sloc_name VARCHAR(255) NOT NULL,
    location_type VARCHAR(20) DEFAULT 'WAREHOUSE', -- WAREHOUSE, YARD, OFFICE
    is_active BOOLEAN DEFAULT true,
    UNIQUE(plant_id, sloc_code)
);

-- Update projects table with SAP organizational data
ALTER TABLE projects 
ADD COLUMN IF NOT EXISTS company_code_id UUID REFERENCES company_codes(id),
ADD COLUMN IF NOT EXISTS purchasing_org_id UUID REFERENCES purchasing_organizations(id),
ADD COLUMN IF NOT EXISTS plant_id UUID REFERENCES plants(id);

-- Update stores to link with storage locations
ALTER TABLE stores
ADD COLUMN IF NOT EXISTS storage_location_id UUID REFERENCES storage_locations(id);

-- Inter-company relationships (Sister companies)
CREATE TABLE inter_company_relations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    related_company_id UUID NOT NULL REFERENCES company_codes(id),
    relation_type VARCHAR(20) NOT NULL, -- SISTER, SUBSIDIARY, PARENT
    transfer_pricing_method VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(company_code_id, related_company_id)
);

-- Sample data for construction group
INSERT INTO company_codes (company_code, company_name, legal_entity_name) VALUES
('C001', 'ABC Construction Ltd', 'ABC Construction Limited'),
('C002', 'ABC Infrastructure', 'ABC Infrastructure Private Limited'),
('C003', 'ABC MEP Services', 'ABC MEP Services Limited'),
('C004', 'ABC Equipment', 'ABC Equipment Rental Limited');

INSERT INTO purchasing_organizations (company_code_id, porg_code, porg_name) VALUES
((SELECT id FROM company_codes WHERE company_code = 'C001'), 'PO01', 'Construction Materials'),
((SELECT id FROM company_codes WHERE company_code = 'C001'), 'PO02', 'Equipment & Services'),
((SELECT id FROM company_codes WHERE company_code = 'C002'), 'PO03', 'Infrastructure Materials'),
((SELECT id FROM company_codes WHERE company_code = 'C003'), 'PO04', 'MEP Materials');

-- Sister company relationships
INSERT INTO inter_company_relations (company_code_id, related_company_id, relation_type) VALUES
((SELECT id FROM company_codes WHERE company_code = 'C001'), (SELECT id FROM company_codes WHERE company_code = 'C002'), 'SISTER'),
((SELECT id FROM company_codes WHERE company_code = 'C001'), (SELECT id FROM company_codes WHERE company_code = 'C003'), 'SISTER'),
((SELECT id FROM company_codes WHERE company_code = 'C001'), (SELECT id FROM company_codes WHERE company_code = 'C004'), 'SISTER');

-- Indexes
CREATE INDEX idx_plants_company_code ON plants(company_code_id);
CREATE INDEX idx_storage_locations_plant ON storage_locations(plant_id);
CREATE INDEX idx_projects_company_code ON projects(company_code_id);