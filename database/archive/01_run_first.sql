-- SCRIPT 1: SAP Organizational Structure
-- Copy and paste this entire script into Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Company Codes (Legal Entities)
CREATE TABLE IF NOT EXISTS company_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code VARCHAR(4) UNIQUE NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    legal_entity_name VARCHAR(255) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    country VARCHAR(2) DEFAULT 'IN',
    address TEXT,
    tax_number VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Purchasing Organizations
CREATE TABLE IF NOT EXISTS purchasing_organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    porg_code VARCHAR(4) UNIQUE NOT NULL,
    porg_name VARCHAR(255) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    is_active BOOLEAN DEFAULT true
);

-- Plants (Project Sites)
CREATE TABLE IF NOT EXISTS plants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    plant_code VARCHAR(4) UNIQUE NOT NULL,
    plant_name VARCHAR(255) NOT NULL,
    plant_type VARCHAR(20) DEFAULT 'PROJECT',
    address TEXT,
    project_id UUID REFERENCES projects(id),
    is_active BOOLEAN DEFAULT true
);

-- Storage Locations
CREATE TABLE IF NOT EXISTS storage_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plant_id UUID NOT NULL REFERENCES plants(id),
    sloc_code VARCHAR(4) NOT NULL,
    sloc_name VARCHAR(255) NOT NULL,
    location_type VARCHAR(20) DEFAULT 'WAREHOUSE',
    is_active BOOLEAN DEFAULT true,
    UNIQUE(plant_id, sloc_code)
);

-- Sample company data
INSERT INTO company_codes (company_code, company_name, legal_entity_name) VALUES
('C001', 'ABC Construction Ltd', 'ABC Construction Limited'),
('C002', 'ABC Infrastructure', 'ABC Infrastructure Private Limited'),
('C003', 'ABC MEP Services', 'ABC MEP Services Limited'),
('C004', 'ABC Equipment', 'ABC Equipment Rental Limited')
ON CONFLICT (company_code) DO NOTHING;

-- Sample purchasing organizations
INSERT INTO purchasing_organizations (company_code_id, porg_code, porg_name) VALUES
((SELECT id FROM company_codes WHERE company_code = 'C001'), 'PO01', 'Construction Materials'),
((SELECT id FROM company_codes WHERE company_code = 'C001'), 'PO02', 'Equipment & Services'),
((SELECT id FROM company_codes WHERE company_code = 'C002'), 'PO03', 'Infrastructure Materials'),
((SELECT id FROM company_codes WHERE company_code = 'C003'), 'PO04', 'MEP Materials')
ON CONFLICT (porg_code) DO NOTHING;