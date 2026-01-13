-- SAP Configuration Tables
-- Run this in your Supabase SQL Editor to create the required tables

-- Company Codes (Legal Entities)
CREATE TABLE IF NOT EXISTS company_codes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    company_code VARCHAR(4) NOT NULL UNIQUE,
    company_name VARCHAR(100) NOT NULL,
    legal_entity_name VARCHAR(100),
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    is_active BOOLEAN DEFAULT true,
    controlling_area_code VARCHAR(4),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Controlling Areas
CREATE TABLE IF NOT EXISTS controlling_areas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cocarea_code VARCHAR(4) NOT NULL UNIQUE,
    cocarea_name VARCHAR(100) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    fiscal_year_variant VARCHAR(2) DEFAULT 'K4',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Cost Centers
CREATE TABLE IF NOT EXISTS cost_centers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cost_center_code VARCHAR(10) NOT NULL,
    cost_center_name VARCHAR(100) NOT NULL,
    cost_center_category VARCHAR(20) DEFAULT 'STANDARD',
    responsible_person VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    company_code_id UUID REFERENCES company_codes(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(cost_center_code, company_code_id)
);

-- Profit Centers
CREATE TABLE IF NOT EXISTS profit_centers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    profit_center_code VARCHAR(10) NOT NULL,
    profit_center_name VARCHAR(100) NOT NULL,
    profit_center_group VARCHAR(20),
    responsible_person VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    controlling_area_id UUID REFERENCES controlling_areas(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(profit_center_code, controlling_area_id)
);

-- Purchasing Organizations
CREATE TABLE IF NOT EXISTS purchasing_organizations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    porg_code VARCHAR(4) NOT NULL UNIQUE,
    porg_name VARCHAR(100) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    is_active BOOLEAN DEFAULT true,
    company_code_id UUID REFERENCES company_codes(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Plants
CREATE TABLE IF NOT EXISTS plants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    plant_code VARCHAR(4) NOT NULL UNIQUE,
    plant_name VARCHAR(100) NOT NULL,
    address TEXT,
    is_active BOOLEAN DEFAULT true,
    company_code_id UUID REFERENCES company_codes(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Storage Locations
CREATE TABLE IF NOT EXISTS storage_locations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    storage_location_code VARCHAR(4) NOT NULL,
    storage_location_name VARCHAR(100) NOT NULL,
    storage_type VARCHAR(20) DEFAULT 'STANDARD',
    is_active BOOLEAN DEFAULT true,
    plant_id UUID REFERENCES plants(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(storage_location_code, plant_id)
);

-- Insert sample data
INSERT INTO company_codes (company_code, company_name, legal_entity_name, currency, controlling_area_code) VALUES
('1000', 'Construction Corp', 'Construction Corporation Ltd', 'USD', '1000'),
('2000', 'Engineering Ltd', 'Engineering Solutions Ltd', 'USD', '1000')
ON CONFLICT (company_code) DO NOTHING;

INSERT INTO controlling_areas (cocarea_code, cocarea_name, currency) VALUES
('1000', 'Main Controlling Area', 'USD'),
('2000', 'Secondary Controlling', 'USD')
ON CONFLICT (cocarea_code) DO NOTHING;

INSERT INTO cost_centers (cost_center_code, cost_center_name, cost_center_category, company_code_id) VALUES
('CC001', 'Project Management', 'OVERHEAD', (SELECT id FROM company_codes WHERE company_code = '1000')),
('CC002', 'Site Operations', 'PRODUCTION', (SELECT id FROM company_codes WHERE company_code = '1000')),
('CC003', 'Quality Control', 'SERVICE', (SELECT id FROM company_codes WHERE company_code = '1000'))
ON CONFLICT (cost_center_code, company_code_id) DO NOTHING;

INSERT INTO profit_centers (profit_center_code, profit_center_name, profit_center_group, controlling_area_id) VALUES
('PC001', 'Residential Projects', 'RESIDENTIAL', (SELECT id FROM controlling_areas WHERE cocarea_code = '1000')),
('PC002', 'Commercial Projects', 'COMMERCIAL', (SELECT id FROM controlling_areas WHERE cocarea_code = '1000'))
ON CONFLICT (profit_center_code, controlling_area_id) DO NOTHING;

INSERT INTO purchasing_organizations (porg_code, porg_name, currency, company_code_id) VALUES
('P001', 'Main Purchasing Org', 'USD', (SELECT id FROM company_codes WHERE company_code = '1000')),
('P002', 'Regional Purchasing', 'USD', (SELECT id FROM company_codes WHERE company_code = '2000'))
ON CONFLICT (porg_code) DO NOTHING;

INSERT INTO plants (plant_code, plant_name, address, company_code_id) VALUES
('PL01', 'Main Construction Site', '123 Construction Ave, City, State', (SELECT id FROM company_codes WHERE company_code = '1000')),
('PL02', 'Secondary Site', '456 Building St, City, State', (SELECT id FROM company_codes WHERE company_code = '1000'))
ON CONFLICT (plant_code) DO NOTHING;

INSERT INTO storage_locations (storage_location_code, storage_location_name, storage_type, plant_id) VALUES
('SL01', 'Main Warehouse', 'WAREHOUSE', (SELECT id FROM plants WHERE plant_code = 'PL01')),
('SL02', 'Site Storage', 'SITE_STORAGE', (SELECT id FROM plants WHERE plant_code = 'PL01')),
('SL03', 'Tool Storage', 'TOOL_STORAGE', (SELECT id FROM plants WHERE plant_code = 'PL02'))
ON CONFLICT (storage_location_code, plant_id) DO NOTHING;